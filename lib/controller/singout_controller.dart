import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/course_controller.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void signOut() {
    _isAuthenticated = false;
    notifyListeners();

    CourseProvider.mentorCourses = '';
  }
}
