import 'package:permission_handler/permission_handler.dart';

class PermissionsUtil {
  /// 检查并请求单个权限
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result.isGranted;
    }
  }

  /// 批量请求多个权限
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions) async {
    return await permissions.request();
  }

  /// 检查权限是否已授予
  static Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.status.isGranted;
  }

  /// 跳转到应用权限设置页面
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// 请求位置权限
  static Future<bool> requestLocationPermission() async {
    return await requestPermission(Permission.location);
  }

  /// 请求相机权限
  static Future<bool> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }

  /// 请求存储权限（安卓）/ 照片权限（iOS）
  static Future<bool> requestStoragePermission() async {
    return await requestPermission(Permission.storage);
  }

  /// 请求麦克风权限
  static Future<bool> requestMicrophonePermission() async {
    return await requestPermission(Permission.microphone);
  }
}
