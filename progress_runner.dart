import 'package:flutter/material.dart';

class CancelToken {
  bool _canceled = false;
  bool get isCanceled => _canceled;
  void cancel() => _canceled = true;
  void throwIfCanceled() {
    if (_canceled) throw const _CanceledException();
  }
}

class _CanceledException implements Exception {
  const _CanceledException();
}

class ProgressState extends ChangeNotifier {
  String title;
  String step;
  double? progress;
  final CancelToken cancelToken;

  ProgressState({
    required this.title,
    required this.step,
    required this.cancelToken,
    this.progress,
  });

  void update({String? step, double? progress}) {
    cancelToken.throwIfCanceled();
    if (step != null) this.step = step;
    this.progress = progress;
    notifyListeners();
  }
}

Future<T?> runWithProgressDialogCancelable<T>({
  required BuildContext context,
  required String title,
  required Future<T> Function(ProgressState p) task,
}) async {
  final token = CancelToken();
  final p = ProgressState(title: title, step: "Memulai…", cancelToken: token);

  bool closed = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProgressDialog(
      state: p,
      onCancel: () {
        token.cancel();
        if (!closed && Navigator.of(context).canPop()) {
          closed = true;
          Navigator.of(context).pop();
        }
      },
    ),
  );

  try {
    final result = await task(p);
    if (context.mounted && !closed) {
      closed = true;
      Navigator.of(context).pop();
    }
    return result;
  } on _CanceledException {
    return null;
  } catch (_) {
    if (context.mounted && !closed) {
      closed = true;
      Navigator.of(context).pop();
    }
    rethrow;
  }
}

class _ProgressDialog extends StatelessWidget {
  final ProgressState state;
  final VoidCallback onCancel;

  const _ProgressDialog({required this.state, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AnimatedBuilder(animation: state, builder: (_, __) => Text(state.title)),
      content: AnimatedBuilder(
        animation: state,
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.step),
            const SizedBox(height: 16),
            if (state.progress == null)
              const Center(child: CircularProgressIndicator())
            else
              LinearProgressIndicator(value: state.progress!.clamp(0.0, 1.0)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text("Cancel")),
      ],
    );
  }
}
