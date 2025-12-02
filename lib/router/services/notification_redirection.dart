import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:leavify/core/storage/app_storage.dart';
import 'package:leavify/router/app_navigator.dart';
import 'package:leavify/router/route_names.dart';

class NotificationRedirection {
  static Future<void> handleNotification(RemoteMessage message) async {
    final data = message.data;
    final isLoggedIn = await AppStorage.getBoolean("USER_IS_ALREADY_LOGGED_IN") ?? false;
    debugPrint('CALLING IS LOGGED IN FROM THE NOTIFICATION REDIRECTION : $isLoggedIn');

    final String? screen = data["screen"];
    final String? leaveId = data["leaveId"];

    final userId = await AppStorage.getString("USER_ID") ?? "";

    /// ----------------------
    /// CASE A: Not Logged In
    /// case A.1 : if the user id is not there in the shared prefs then he/she should login again.
    /// ----------------------
    if (!isLoggedIn || userId.isEmpty) {
      AppNavigator.setRootView(RouteNames.login);
      return;
    }

    /// ----------------------
    /// CASE B: Logged In
    /// ----------------------
    switch (screen) {
      case "Home":
        AppNavigator.setRootView(RouteNames.home);
        break;

      case "ManagerLeave":
        AppNavigator.setRootView(
          RouteNames.pendingRequestDetail,
          arguments: {
            "leaveId": leaveId,
            "user": null,
          },
        );
        break;

      case "EmployeeLeave":
        AppNavigator.setRootView(
          RouteNames.leaveDetail,
           arguments: {
            "leaveId": leaveId,
             "userId" : userId
           }
        );
        break;

      default:
        AppNavigator.setRootView(RouteNames.home);
        break;
    }
  }
}
