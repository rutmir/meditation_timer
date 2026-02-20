import 'package:package_info_plus/package_info_plus.dart';
import '../../service/device_service.dart';

class AppDeviceService extends DeviceService {
  @override
  Future<String> getAppVersion() async {
    final package = await PackageInfo.fromPlatform();

    return package.version;
  }
}
