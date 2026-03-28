import 'dart:developer';

import 'package:chat_app/Core/Network/call_service.dart';
import 'package:chat_app/Core/Network/local_notification_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsService {
static FirebaseMessaging messaging= FirebaseMessaging.instance;

static Future  init()async{
 await messaging.requestPermission();
String? token = await messaging.getToken();
log(token ?? 'null');
FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//forground
handleForegroundMessage();

}
static Future<void> handleBackgroundMessage(RemoteMessage message)async{
 await Firebase.initializeApp();
if(message.data['type']=='call'){
  await CallService().showIncomingCall(message.data);
}
 log(message.notification?.title ?? 'null');
}

static void handleForegroundMessage(){
  FirebaseMessaging.onMessage.listen(
  (RemoteMessage message){
LocalNotificationServices().showBasicNotification(
  title: message.notification?.title ?? 'null', body: message.notification?.body ?? 'null');
});
}
}
