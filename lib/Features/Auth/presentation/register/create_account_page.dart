import 'package:chat_app/Core/Network/biometric_service.dart';
import 'package:chat_app/Core/Network/firebase_auth_service.dart';
import 'package:chat_app/Features/Auth/presentation/login/login_page.dart';
import 'package:chat_app/Features/Users/users_screen.dart';
import 'package:custom_form_w/custom_form_w.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatelessWidget {
   CreateAccountPage({super.key});
   final TextEditingController emailController = TextEditingController();
   final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
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
            buttonText: 'Create Account',
            onSubmit: () {
              FirebaseAuthService().createAccount(
                emailController.text,
                passwordController.text,
                nameController.text
              );
              
            },
            children: [
  CustomTextField(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
           controller: nameController,
              label: 'Name',
              hint: 'Enter Your Name',
              suffixIcon: const Icon(Icons.email),
            ),
            

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
              Text('Already have an account?'),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              }, child: Text('Login'))
            ],
          ),
        ],
      ),
    );
  }
}