import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class LocalNotificationServices {
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

static StreamController<NotificationResponse>streamController= StreamController();
static onTap(NotificationResponse notificationResaponse){
streamController.add(notificationResaponse);
}
  Future init() async {
     InitializationSettings settings =  const
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher")
            ,
            iOS: DarwinInitializationSettings());

    flutterLocalNotificationsPlugin.initialize(settings: settings,onDidReceiveBackgroundNotificationResponse: onTap,onDidReceiveNotificationResponse: onTap);  }

  void showBasicNotification({required String title, required String body}) async {
     AndroidNotificationDetails android = AndroidNotificationDetails(
        "Id1", "Basic Notifications",
        importance: Importance.max, 
        priority: Priority.high
       
        );
     NotificationDetails details =
        NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(
        id: 0,
         title:'$title',
         body: '$body',
          notificationDetails: details,
        payload: "Default_Sound"
        );
  }
}
