import 'package:permission_handler/permission_handler.dart';
import 'package:raven/repository/preferences/internal.dart';

class PermissionsProvider {
  Future<void> requestStoragePermission() async {
    if (Internal.sdkVersion >= 33) {
      await Permission.manageExternalStorage.request();
    } else {
      await Permission.storage.request();
    }
  }
}
