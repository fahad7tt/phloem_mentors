// ignore_for_file: avoid_print
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phloem_mentors/model/course_model.dart';
import 'package:phloem_mentors/model/mentor_model.dart';

class MentorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Mentor> _mentors = [];
  final List<String> _selectedCourses = [];
  final List<String> _selectedModules = [];
  String? _selectedCourse;
  List<String> _selectedCourseModules = [];
  File? _selectedImage;

   String? get selectedCourse => _selectedCourse;
  List<String> get selectedCourseModules => _selectedCourseModules;
  List<Mentor> get mentors => _mentors;
  List<String> get selectedCourses => _selectedCourses;
  List<String> get selectedModules => _selectedModules;
  File? get selectedImage => _selectedImage;

  // Method to toggle selected modules
  void toggleSelectedModule(String module) {
    if (_selectedModules.contains(module)) {
      _selectedModules.remove(module);
    } else {
      _selectedModules.add(module);
    }
    notifyListeners();
  }

  // Method to reset selected modules
  void resetSelectedModules() {
    _selectedModules.clear();
    notifyListeners();
  }

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  void resetSelectedCourses() {
    _selectedCourses.clear();
    notifyListeners();
  }

  void setMentors(List<Mentor> mentors) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mentors.clear();
      _mentors.addAll(mentors);
      notifyListeners();
    });
  }

  void addMentor(Mentor mentor) {
    _mentors.add(mentor);
    notifyListeners();
  }

  void setSelectedCourse(String courseName, List<String> modules) {
    _selectedCourse = courseName;
    _selectedCourseModules = modules;
    notifyListeners();
  }

  void deleteMentor(String idDel) async {
    try {
      await FirebaseFirestore.instance
          .collection('mentors')
          .doc(idDel)
          .delete();
      notifyListeners();
    } catch (error) {
      print('Error deleting mentor from Firestore: $error');
    }
  }

  void resetState() {
    _selectedCourses.clear();
    _selectedModules.clear();
    _selectedImage = null;
    notifyListeners();
  }

  void toggleSelectedCourse(String course) {
    if (_selectedCourses.contains(course)) {
      _selectedCourses.remove(course);
      _selectedModules.clear(); // Clear modules when course is deselected
    } else {
      _selectedCourses.add(course);
    }
    notifyListeners();
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('mentor_images/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> addMentorToFirestore(Mentor mentor) async {
    if (await isEmailUnique(mentor.email)) {
      try {
        await _firestore.collection('mentors').doc(mentor.id).set({
          'name': mentor.name,
          'email': mentor.email,
          'password': mentor.password,
          'courses': mentor.courses,
          'image': mentor.imageUrl,
          'modules': mentor.selectedModules,
        });
        print('Mentor added to Firestore with ID: ${mentor.id}');
        // Add the mentor to the local list and notify listeners
        _mentors.add(mentor);
        notifyListeners();
      } catch (error) {
        print('Error adding mentor to Firestore: $error');
      }
    } else {
      print('Email already exists');
    }
  }

  Future<void> editMentorInFirestore(String index, Mentor updatedMentor) async {
      try {
        await _firestore.collection('mentors').doc(index).update({
          'name': updatedMentor.name,
          'email': updatedMentor.email,
          'password': updatedMentor.password,
          'courses': updatedMentor.courses,
          'image': updatedMentor.imageUrl,
          'modules': updatedMentor.selectedModules,
        });
        print('Mentor updated in Firestore');
        notifyListeners(); // Notify listeners to update UI
      } catch (error) {
        print('Error updating mentor in Firestore: $error');
      }
  }

  Future<List<Course>> fetchCourses() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('courses').get();
      List<Course> courses =
          querySnapshot.docs.map((doc) => Course.fromSnapshot(doc)).toList();
      return courses;
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<bool> isEmailUnique(String email) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('mentors').get();

    return !querySnapshot.docs.any((doc) => doc['email'] == email);
  }

  Future<bool> isPasswordUnique(String password) async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('mentors').get();

  return !querySnapshot.docs.any((doc) => doc['password'] == password);
}

Future<bool> isModuleAvailableForCourse(String courseName, List<String> selectedModules) async {
  try {
    // Fetch the course from Firestore
    DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance.collection('courses').doc(courseName).get();
    Map<String, dynamic>? courseData = courseSnapshot.data() as Map<String, dynamic>?;
    if (courseData != null) {
      List<String> courseModules = List<String>.from(courseData['modules'] ?? []);

      // Check if any of the selected modules are already assigned to another mentor
      QuerySnapshot mentorSnapshot = await FirebaseFirestore.instance.collection('mentors').get();
      for (DocumentSnapshot doc in mentorSnapshot.docs) {
        Map<String, dynamic>? mentorData = doc.data() as Map<String, dynamic>?;
        if (mentorData != null) {
          List<String> mentorModules = List<String>.from(mentorData['modules'] ?? []);
          if (selectedModules.any((module) => mentorModules.contains(module))) {
            return false; // Return false if any of the selected modules are already assigned to another mentor
          }
        }
      }
      // Check if the selected modules are available for the course
      return selectedModules.every((module) => courseModules.contains(module));
    }
    return false;
  } catch (e) {
    print('Error checking module availability: $e');
    return false;
  }
}

void updateMentor(Mentor updatedMentor) {
  final index = _mentors.indexWhere((mentor) => mentor.id == updatedMentor.id);
  if (index != -1) {
    _mentors[index] = updatedMentor;
    notifyListeners();
  }
}
}