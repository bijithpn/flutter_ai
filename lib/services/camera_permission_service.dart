import 'package:camera/camera.dart';

/// Service for handling camera permissions
class CameraPermissionService {
  /// Check if camera permission is granted
  static Future<bool> hasPermission() async {
    try {
      // Try to get available cameras - this will trigger permission request on first use
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Request camera permission
  static Future<bool> requestPermission() async {
    try {
      // On mobile platforms, calling availableCameras() will automatically
      // request permissions if not already granted
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if camera permission is permanently denied
  static Future<bool> isPermanentlyDenied() async {
    try {
      await availableCameras();
      return false; // If no exception, permission is granted
    } on CameraException catch (e) {
      // Check if the error indicates permanently denied permission
      return e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt';
    } catch (e) {
      return false;
    }
  }

  /// Get permission status as enum
  static Future<CameraPermissionStatus> getPermissionStatus() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        return CameraPermissionStatus.granted;
      } else {
        return CameraPermissionStatus.denied;
      }
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt') {
        return CameraPermissionStatus.permanentlyDenied;
      }
      return CameraPermissionStatus.denied;
    } catch (e) {
      return CameraPermissionStatus.denied;
    }
  }
}

/// Camera permission status enum
enum CameraPermissionStatus { granted, denied, permanentlyDenied }
