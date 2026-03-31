import 'package:chat_app/Core/Network/biometric_service.dart';
import 'package:chat_app/Core/Network/firebase_auth_service.dart';
import 'package:chat_app/Features/Auth/presentation/register/create_account_page.dart';
import 'package:chat_app/Features/Users/users_screen.dart';
import 'package:custom_form_w/custom_form_w.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class LoginPage extends StatefulWidget {
 
   LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {

   final TextEditingController emailController = TextEditingController();
   final TextEditingController passwordController = TextEditingController();

 @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomFormW(
            showValidationSnackBar: false,
            spacing: 30,
            buttonText: 'Login',
            onSubmit: () {
              FirebaseAuthService().login(
                emailController.text,
                passwordController.text
              );
              Navigator.push(context, MaterialPageRoute(builder: (context)=>UsersScreen()));
            },
            children: [
            CustomTextField(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
           controller: emailController,
              label: 'Email',
              hint: 'Enter Your Email',
              suffixIcon: const Icon(Icons.email),
            ),
            
            CustomTextField(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              controller: passwordController,
              label: 'Password',
              hint: 'Enter Your Password',
              type: CustomTextFieldType.password,
              maxLines: 1,
              suffixIcon: const Icon(Icons.password_sharp),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?"),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
              }, child: Text('Create Account'))
            ],
            
          ),
          
        ],
      ),
    );
  }
  Future<void> loginWithBiometric()async{
  bool authenticated= await BiometricService().authenticate();
  if(authenticated){
  // ignore: non_constant_identifier_names
  final  user = FirebaseAuth.instance.currentUser;
    if(user !=null){
     
      Navigator.push(context, MaterialPageRoute(builder: (context)=>UsersScreen()));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in'))
      );
    }
  }
 }
}

