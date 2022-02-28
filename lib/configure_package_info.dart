import 'package:package_info_plus/package_info_plus.dart';
import 'pages/home/info_dialog.dart';

late final PackageInfo packageInfo;

/// Configure the package_info_plus package to be used in the [InfoDialog]
Future<void> configurePackageInfo() async {
  packageInfo = await PackageInfo.fromPlatform();
}
