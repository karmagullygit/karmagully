import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class FileUploadService {
  static final ImagePicker _imagePicker = ImagePicker();
  
  // Request necessary permissions
  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();
    
    return statuses.values.every((status) => 
        status == PermissionStatus.granted || 
        status == PermissionStatus.limited);
  }

  // Pick single image from gallery or camera
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? imageQuality = 80,
  }) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Permission denied');
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Pick multiple images
  static Future<List<File>> pickMultipleImages({
    int? imageQuality = 80,
    int? limit = 5,
  }) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Permission denied');
      }

      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: 1920,
        maxHeight: 1080,
        limit: limit,
      );

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  // Pick video from gallery or camera
  static Future<File?> pickVideo({
    ImageSource source = ImageSource.gallery,
    Duration? maxDuration = const Duration(minutes: 5),
  }) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Permission denied');
      }

      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking video: $e');
      return null;
    }
  }

  // Pick files using file picker (for more control)
  static Future<List<File>> pickFiles({
    FileType type = FileType.media,
    List<String>? allowedExtensions,
    bool allowMultiple = false,
  }) async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Permission denied');
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
        withData: false,
        withReadStream: false,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error picking files: $e');
      return [];
    }
  }

  // Save file to app directory with unique name
  static Future<String?> saveFileToAppDirectory(File file, {
    String? customName,
    String subfolder = 'uploads',
  }) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory uploadDir = Directory('${appDir.path}/$subfolder');
      
      // Create directory if it doesn't exist
      if (!await uploadDir.exists()) {
        await uploadDir.create(recursive: true);
      }

      // Generate unique filename
      final String extension = path.extension(file.path);
      final String fileName = customName ?? 
          '${DateTime.now().millisecondsSinceEpoch}$extension';
      
      final String newPath = '${uploadDir.path}/$fileName';
      
      // Copy file to new location
      final File newFile = await file.copy(newPath);
      
      return newFile.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  // Delete file from storage
  static Future<bool> deleteFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Get file size in MB
  static Future<double> getFileSizeInMB(String filePath) async {
    try {
      final File file = File(filePath);
      final int bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0.0;
    }
  }

  // Validate file type
  static bool isValidImageFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  static bool isValidVideoFile(String filePath) {
    final String extension = path.extension(filePath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp'].contains(extension);
  }

  // Show image picker dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImage(source: ImageSource.camera);
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickImage(source: ImageSource.gallery);
                  Navigator.of(context).pop(file);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show video picker dialog
  static Future<File?> showVideoPickerDialog(BuildContext context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Video Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickVideo(source: ImageSource.camera);
                  Navigator.of(context).pop(file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickVideo(source: ImageSource.gallery);
                  Navigator.of(context).pop(file);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}