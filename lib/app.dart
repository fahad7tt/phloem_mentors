import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/mentor_controller.dart';
import 'package:phloem_mentors/view/splash_screen.dart';
import 'package:provider/provider.dart';
import 'controller/signin_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MentorProvider()),
        ChangeNotifierProvider(create: (context) => SignInController()),
      ],
      child: MaterialApp(
        title: 'E-Learning App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<MentorProvider>(
          builder: (context, mentorProvider, _) {
            // You can use mentorProvider here to decide which screen to show
            return const SplashScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}