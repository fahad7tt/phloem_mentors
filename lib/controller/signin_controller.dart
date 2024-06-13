// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phloem_mentors/model/mentor_model.dart';
import 'package:phloem_mentors/model/users_model.dart';
import 'package:phloem_mentors/view/screens/mentor/home/mentor_home.dart';

class SignInController extends ChangeNotifier {
  static String? mentorEmail = FirebaseAuth.instance.currentUser!.email;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final signInModel = UserModel(id: '', name: '', email: '', password: '');

  Future<bool> isEmailValid(String enteredEmail) async {
  try {
    final mentorSnapshot = await FirebaseFirestore.instance
        .collection('mentors')
        .where('email', isEqualTo: enteredEmail.toLowerCase()) // to ensure case-insensitive comparison
        .get();

    return mentorSnapshot.docs.isNotEmpty;
  } catch (error) {
    log('Error validating email: $error');
    return false;
  }
}

// In signIn method
Future<void> signIn(BuildContext context) async {
  if (formKey.currentState!.validate()) {
    formKey.currentState!.save();

    if (await isEmailValid(emailController.text.trim())) {
      try {
        final mentorSnapshot = await FirebaseFirestore.instance
            .collection('mentors')
            .where('email', isEqualTo: emailController.text.trim().toLowerCase()) // Ensure case-insensitive comparison
            .get();

        if (mentorSnapshot.docs.isNotEmpty) {
          final mentorData = mentorSnapshot.docs.first.data();
          final mentorStoredPassword = mentorData['password'] as String;

          final enteredPassword = passwordController.text.trim();

          if (mentorStoredPassword == enteredPassword) {
            log('Mentor authenticated successfully.');

            // Create the Mentor object from the snapshot
            final mentor = Mentor.fromSnapshot(mentorSnapshot.docs.first);
            mentorEmail = emailController.text.trim().toLowerCase();
            notifyListeners();
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MentorHome(mentor: mentor, email: emailController.text.trim()),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid password. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mentor not found. Please check your email.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (error) {
        log('Sign-in failed: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in failed. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
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