import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/course_controller.dart';
import 'package:phloem_mentors/controller/mentor_controller.dart';
import 'package:phloem_mentors/controller/singout_controller.dart';
import 'package:provider/provider.dart';
import 'controller/chat_controller.dart';
import 'controller/signin_controller.dart';
import 'controller/videomodule_controller.dart';
import 'view/screens/splash screen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MentorProvider()),
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => SignInController()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(
          create: (_) => VideoController(),
          child: const MyApp(),
        ),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'E-Learning App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<MentorProvider>(
          builder: (context, mentorProvider, _) {
            return const SplashScreen();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
