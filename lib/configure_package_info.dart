import 'package:package_info_plus/package_info_plus.dart';

late final PackageInfo packageInfo;

Future<void> configurePackageInfo() async {
  packageInfo = await PackageInfo.fromPlatform();
}
