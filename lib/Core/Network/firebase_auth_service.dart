import 'package:firebase_auth/firebase_auth.dart';
  class FirebaseAuthService {
 
  final FirebaseAuth _auth = FirebaseAuth.instance ;
    Future<UserCredential>  createAccount(String email,String password)async{
   try{
     final UserCredential userCredential =await _auth.
     createUserWithEmailAndPassword(email: email.trim(), 
     password: password.trim()
     );
     return userCredential;
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
}