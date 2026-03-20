import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show FirebaseMessaging;
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
}