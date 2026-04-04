import 'package:chat_app/Core/Config/stream_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show FirebaseMessaging;
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'stream_config.dart';
  class FirebaseAuthService {
 
  final FirebaseAuth _auth = FirebaseAuth.instance ;
    Future<UserCredential>  createAccount(
      String email,
    String password,
    String name
    )async{
   try{
     final UserCredential credential =await _auth.
     createUserWithEmailAndPassword(email: email.trim(), 
     password: password.trim()
     ); //user created then create table in database
     FirebaseFirestore.instance.collection('users').doc(credential.user?.uid).set({
      'name':name,
      'email':email,
      'createdAt':FieldValue.serverTimestamp()
     });
     return credential;
   }on FirebaseAuthException catch(e){
   print(e.toString());
   rethrow;
   }
             }

                Future<UserCredential>  login(String email,String password)async{
   try{
     final UserCredential userCredential =await _auth.
     signInWithEmailAndPassword(email: email.trim(), 
     password: password.trim());
     print('Login successful: ${userCredential.user?.email}');
     return userCredential;
   }on FirebaseAuthException catch(e){
   print(e.toString());
   rethrow;
   }


             }
/*
             Future<void> saveDeviceToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String? token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmToken': token,
    });
  }
}

*/
/*
  /// Get Stream.io JWT token for the current user
  /// This token is required to connect to Stream Chat and Stream Video
  Future<String?> getStreamToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return null;
      }

      final idToken = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse(StreamConfig.tokenServerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken'
        },
      ).timeout(
        Duration(seconds: StreamConfig.requestTimeoutSeconds),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final token = jsonResponse['token'] as String?;
        if (token != null) {
          print('[FirebaseAuthService] Stream token obtained successfully');
          return token;
        } else {
          print('[FirebaseAuthService] Token not found in response');
          return null;
        }
      } else {
        print('[FirebaseAuthService] Failed to get Stream token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[FirebaseAuthService] Error getting Stream token: $e');
      rethrow;
    }
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('[FirebaseAuthService] User signed out');
    } catch (e) {
      print('[FirebaseAuthService] Sign out error: $e');
      rethrow;
    }
  }
*/
}
