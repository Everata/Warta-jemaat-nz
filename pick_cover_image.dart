import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickCoverImageBytes() async {
  final picker = ImagePicker();
  final XFile? file = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 92,
  );
  if (file == null) return null;
  return file.readAsBytes();
}
