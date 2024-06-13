import 'package:flutter/material.dart';

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('App Info'),
          centerTitle: true,
        ),
        body: const SingleChildScrollView(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(22.0),
              child: Text(
                'Phloem is your ultimate educational companion, designed to make your learning journey efficient and engaging. Whether you\'re a student eager to explore new subjects or a mentor guiding learners, Phloem has something for everyone. Discover a world of knowledge, intuitive learning tools, and academic inspiration all in one place.\n\n'
                'This app is designed for users who are passionate about education and personal development. We provide a variety of courses and resources to enhance your learning experience. It is an easy-to-use application with three main interfaces: admin, mentor, and user (students).\n\n'
                'Learning is a continuous process, whether you pursue it for personal growth or for professional advancement. Many prefer E-Learning for its flexibility, accessibility, and comprehensive resources.\n\n'
                'However, sticking to a routine can sometimes feel monotonous. To keep your learning journey exciting and fruitful, Phloem provides a diverse array of courses and interactive tools to keep you motivated and engaged.',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
    );
  }
}