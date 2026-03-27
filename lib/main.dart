

import 'package:chat_app/Core/Network/local_notification_services.dart';
import 'package:chat_app/Core/Network/push_notifications_service.dart';
import 'package:chat_app/Features/Auth/presentation/register/create_account_page.dart';
import 'package:chat_app/Features/Users/users_screen.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.wait([
    LocalNotificationServices().init(),
    PushNotificationsService.init()
  ]) ;
  
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.data['type'] == 'call') {
  String callerName=message.data['callerName'];
  String channelId=message.data['channelId'];
  }
  
});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,useMaterial3: true
      ),
      home:  StreamBuilder<User?>(
        stream:FirebaseAuth.instance.authStateChanges() ,
        builder: (context,snapshot){
          if(snapshot.hasData){
            return UsersScreen();
          }
          return CreateAccountPage();
        },
      ),
    );
  }
}