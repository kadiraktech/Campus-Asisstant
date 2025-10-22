import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from gallery or camera
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      return pickedFile;
    } catch (e) {
      // print("Error picking image: $e");
      return null;
    }
  }

  // Method to compress image
  Future<Uint8List?> compressImage(
    String filePath, {
    int quality = 70,
    int minWidth = 800,
    int minHeight = 800,
  }) async {
    try {
      final Uint8List? result = await FlutterImageCompress.compressWithFile(
        filePath,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
      );
      return result;
    } catch (e) {
      // print("Error compressing image: $e");
      return null;
    }
  }

  // Method to upload image to Firebase Storage and get URL
  Future<String?> uploadProfilePicture({
    required String userId,
    required Uint8List imageBytes,
    String? fileName, // Optional: specify a file name
  }) async {
    try {
      fileName ??= '${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Construct the full path for Firebase Storage
      // Example path: profile_pictures/user_id/filename.jpg
      final Reference ref = _storage.ref('profile_pictures/$userId/$fileName');

      final UploadTask uploadTask = ref.putData(imageBytes);
      // final TaskSnapshot snapshot = await uploadTask; // Original line
      // return await snapshot.ref.getDownloadURL(); // Original line

      // Ensure the upload is fully complete
      await uploadTask.whenComplete(() => null);

      // Get the download URL using the reference *after* completion
      return await ref.getDownloadURL();
    } catch (e) {
      // print("Error uploading profile picture to Firebase Storage: $e");
      // It's better to rethrow the original exception or a custom one
      // that wraps it, so the UI layer can decide how to inform the user.
      rethrow; // Changed from 'return null;' to 'rethrow;'
    }
  }
}
