import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/providers/service_providers.dart';

/// Media type enum
enum MediaType {
  photo,
  video;

  String get value => name;
}

/// Uploaded media result
class UploadedMedia {
  final String storageId;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final MediaType type;

  UploadedMedia({
    required this.storageId,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.type,
  });
}

/// Media upload service
/// Handles the complete media upload workflow:
/// 1. Pick image/video from gallery or camera
/// 2. Generate upload URL from Convex
/// 3. Upload file to Convex storage
/// 4. Return storage ID for linking to session
class MediaUploadService {
  final Ref ref;
  final _picker = ImagePicker();

  MediaUploadService(this.ref);

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('❌ Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return images;
    } catch (e) {
      print('❌ Error picking multiple images from gallery: $e');
      rethrow;
    }
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      print('❌ Error taking photo: $e');
      rethrow;
    }
  }

  /// Pick video from gallery
  Future<XFile?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      return video;
    } catch (e) {
      print('❌ Error picking video from gallery: $e');
      rethrow;
    }
  }

  /// Pick video from camera
  Future<XFile?> pickVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      return video;
    } catch (e) {
      print('❌ Error recording video: $e');
      rethrow;
    }
  }

  /// Upload file to Convex storage
  /// Returns the storage ID that can be used to link the file to a session
  Future<UploadedMedia> uploadFile(XFile file, MediaType type) async {
    try {
      // Step 1: Get upload URL from Convex
      final apiService = ref.read(mcpApiServiceProvider);
      final uploadUrl = await apiService.generateMediaUploadUrl();

      // Step 2: Read file bytes
      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;

      // Step 3: Upload file to Convex storage
      final response = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': file.mimeType ?? 'application/octet-stream',
        },
        body: bytes,
      );

      if (response.statusCode != 200) {
        throw Exception('Upload failed: ${response.statusCode} ${response.body}');
      }

      // Step 4: Parse storage ID from response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final storageId = responseData['storageId'] as String;

      return UploadedMedia(
        storageId: storageId,
        fileName: file.name,
        fileSize: fileSize,
        mimeType: file.mimeType ?? 'application/octet-stream',
        type: type,
      );
    } catch (e) {
      print('❌ Error uploading file: $e');
      rethrow;
    }
  }

  /// Complete upload flow: pick and upload image from gallery
  Future<UploadedMedia?> pickAndUploadImageFromGallery() async {
    final file = await pickImageFromGallery();
    if (file == null) return null;

    return await uploadFile(file, MediaType.photo);
  }

  /// Complete upload flow: pick and upload multiple images from gallery
  Future<List<UploadedMedia>> pickAndUploadMultipleImagesFromGallery() async {
    final files = await pickMultipleImagesFromGallery();
    if (files.isEmpty) return [];

    final List<UploadedMedia> uploadedMedia = [];
    for (final file in files) {
      try {
        final uploaded = await uploadFile(file, MediaType.photo);
        uploadedMedia.add(uploaded);
      } catch (e) {
        print('❌ Error uploading file ${file.name}: $e');
        // Continue with other files even if one fails
      }
    }
    return uploadedMedia;
  }

  /// Complete upload flow: pick and upload image from camera
  Future<UploadedMedia?> pickAndUploadImageFromCamera() async {
    final file = await pickImageFromCamera();
    if (file == null) return null;

    return await uploadFile(file, MediaType.photo);
  }

  /// Complete upload flow: pick and upload video from gallery
  Future<UploadedMedia?> pickAndUploadVideoFromGallery() async {
    final file = await pickVideoFromGallery();
    if (file == null) return null;

    return await uploadFile(file, MediaType.video);
  }

  /// Complete upload flow: pick and upload video from camera
  Future<UploadedMedia?> pickAndUploadVideoFromCamera() async {
    final file = await pickVideoFromCamera();
    if (file == null) return null;

    return await uploadFile(file, MediaType.video);
  }

  /// Link uploaded media to an activity session
  Future<void> linkMediaToSession({
    required String sessionId,
    required UploadedMedia media,
  }) async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      await apiService.addMediaToSession(
        sessionId: sessionId,
        storageId: media.storageId,
        type: media.type.value,
        fileName: media.fileName,
        fileSize: media.fileSize,
        mimeType: media.mimeType,
      );
    } catch (e) {
      print('❌ Error linking media to session: $e');
      rethrow;
    }
  }

  /// Get display URL for media
  Future<String> getMediaUrl(String storageId) async {
    final apiService = ref.read(mcpApiServiceProvider);
    return await apiService.getMediaFileUrl(storageId);
  }

  /// Remove media from session
  Future<void> removeMedia({
    required String sessionId,
    required String mediaId,
  }) async {
    try {
      final apiService = ref.read(mcpApiServiceProvider);
      await apiService.removeMediaFromSession(
        sessionId: sessionId,
        mediaId: mediaId,
      );
    } catch (e) {
      print('❌ Error removing media: $e');
      rethrow;
    }
  }
}

/// Media upload service provider
final mediaUploadServiceProvider = Provider<MediaUploadService>((ref) {
  return MediaUploadService(ref);
});
