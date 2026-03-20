

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
  PushNotificationsService.init();
  /*
  FirebaseMessaging messaging =FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.notification != null) {
    print('Message title: ${message.notification!.title}');
    print('Message body: ${message.notification!.body}');
    // Show a local notification using flutter_local_notifications
  }
});
*/
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