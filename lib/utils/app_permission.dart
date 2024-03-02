import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  Permission permission = Permission.storage;

  Future<void> askPermission({required Function showDialog}) async {
    try {
      PermissionStatus status = await permission.request();

      while (status != PermissionStatus.granted) {
        if (status == PermissionStatus.permanentlyDenied) {
          showDialog();
          break; // Break out of the loop as permission won't be granted.
        }

        // If not permanently denied, keep asking for permission.
        status = await permission.request();
      }

      print(status);
    } catch (e) {
      print('Error While getting Perssion $e');
    }
  }
}
