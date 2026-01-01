import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceInfo() async {
    Map<String, dynamic> deviceData = {};

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'deviceId': androidInfo.id,
          'deviceModel': androidInfo.model,
          'brand': androidInfo.brand,
          'osVersion': androidInfo.version.release,
          'sdkVersion': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'deviceId': iosInfo.identifierForVendor,
          'deviceModel': iosInfo.model,
          'osVersion': iosInfo.systemVersion,
          'name': iosInfo.name,
        };
      }

      // Get app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      deviceData['appVersion'] = packageInfo.version;
      deviceData['buildNumber'] = packageInfo.buildNumber;
      deviceData['packageName'] = packageInfo.packageName;

      return deviceData;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}