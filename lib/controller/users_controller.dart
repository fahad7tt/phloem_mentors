import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phloem_mentors/model/users_model.dart';

class SignUpController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final signUpModel = UserModel(id: '', name: '', email: '', password: '');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      try {
        // Create user account with Firebase Authentication
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password' : passwordController.text.trim(),
        });
      } catch (error) {
        // Handle sign-up error
        // ignore: avoid_print
        print('Sign-up failed: $error');
        Get.snackbar(
          'Error',
          'Sign-up failed. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}