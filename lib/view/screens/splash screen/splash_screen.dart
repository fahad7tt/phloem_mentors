import 'dart:async';
import 'package:flutter/material.dart';
import '../sign in/sign_in.dart';

class SplashScreen extends StatelessWidget {
   const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    Timer(const Duration(seconds: 3), () async{
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx){
        return const SignInPage();
      }));
    });
    return  Scaffold(
      body: Center(
        child: Image.asset('images/phloem_logo.png'),
      ),
    );
  }
}