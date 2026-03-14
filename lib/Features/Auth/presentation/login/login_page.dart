import 'package:chat_app/Core/Network/firebase_auth_service.dart';
import 'package:chat_app/Features/Auth/presentation/register/create_account_page.dart';
import 'package:custom_form_w/custom_form_w.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
   LoginPage({super.key});
   final TextEditingController emailController = TextEditingController();
   final TextEditingController passwordController = TextEditingController();
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
          )
        ],
      ),
    );
  }
}