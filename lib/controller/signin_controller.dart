// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phloem_mentors/model/users_model.dart';
import 'package:phloem_mentors/view/mentor_home.dart';

class SignInController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final signInModel = UserModel(email: '', password: '');

  Future<bool> isEmailValid(String enteredEmail) async {
    try {
      final mentorSnapshot = await FirebaseFirestore.instance
          .collection('mentors')
          .where('email', isEqualTo: enteredEmail)
          .get();

      return mentorSnapshot.docs.isNotEmpty;
    } catch (error) {
      log('Error validating email: $error');
      return false;
    }
  }

  Future<void> signIn(BuildContext context) async {
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();

    if (await isEmailValid(emailController.text.trim())) {
      // Proceed with sign-in
      try {
        // Retrieve mentor data from Firestore
        final mentorSnapshot = await FirebaseFirestore.instance
            .collection('mentors')
            .where('email', isEqualTo: emailController.text.trim())
            .get();

        if (mentorSnapshot.docs.isNotEmpty) {
          final mentorData = mentorSnapshot.docs.first.data();
          final mentorStoredPassword = mentorData['password'] as String;

          // Retrieve entered password
          final enteredPassword = passwordController.text.trim();

          // Verify password
          if (mentorStoredPassword == enteredPassword) {
            log('Mentor authenticated successfully.');
            // Notify listeners that the sign-in was successful
            notifyListeners();

            // Navigate to home page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MentorHome(email: emailController.text.trim()),
              ),
            );
          } else {
            // Password mismatch
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid password. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Mentor not found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mentor not found. Please check your email.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (error) {
        // Handle sign-in error
        log('Sign-in failed: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in failed. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Email not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found. Please check your email.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}