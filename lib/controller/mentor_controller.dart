// ignore_for_file: avoid_print
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phloem_mentors/model/course_model.dart';
import 'package:phloem_mentors/model/mentor_model.dart';

class MentorProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Mentor> _mentors = [];
  final Map<String, List<bool>> _moduleExpansionMap =
      {}; // Map to track expansion state for each mentor's modules
  final List<String> _selectedCourses = [];
  final List<String> _selectedModules = [];
  String? _selectedCourse;
  List<String> _selectedCourseModules = [];
  File? _selectedImage;
  // var enrolledCourses = <Course>[].obs;
  var isLoadingState = false.obs;

  String? get selectedCourse => _selectedCourse;
  List<String> get selectedCourseModules => _selectedCourseModules;
  List<Mentor> get mentors => _mentors;
  List<String> get selectedCourses => _selectedCourses;
  List<String> get selectedModules => _selectedModules;
  File? get selectedImage => _selectedImage;

    bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<String?> getMentorName(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('mentors').where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['name'];
      }
      return null;
    } catch (e) {
      print('Error fetching mentor name: $e');
      return null;
    }
  }
  
//   Future<void> enrollCourse(Course course, UserModel user) async {
//   try {
//     // notifyListeners();

//     // Store the enrolled course data in Firestore
//     await _firestore.collection('enrolledCourses').doc().collection('courses').doc(course.id).set({
//       'courseId': course.id,
//       'email': user.email,
//       'name': course.name,
//       'modules': course.modules,
//       'payment': course.payment,
//       'descriptions': course.descriptions,
//       'amount': course.amount,
//     });
//         enrolledCourses.add(course);

//   } catch (e) {
//     print('Error enrolling in course: $e');
//   }
// }

// Future<void> fetchEnrolledCourses(UserModel user) async {
//   isLoadingState.value = true; // Set loading to true
//   try {
//     // Clear the local list of enrolled courses
//     enrolledCourses.clear();

//     // Fetch the enrolled courses from Firestore
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('enrolledCourses')
//         .doc(user.email)
//         .collection('courses')
//         .get();

//     // Add the fetched courses to the local list
//      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
//       Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
//       if (data != null) {
//         enrolledCourses.add(
//           Course(
//             id: doc.id,
//             name: data['name'] ?? '',
//             modules: List<String>.from(data['modules'] ?? []),
//             payment: data['payment'] ?? '',
//             descriptions: List<String>.from(data['descriptions'] ?? []),
//             amount: data['amount'] ?? '',
//           ),
//         );
//       }
//     }
//   } catch (e) {
//     print('Error fetching enrolled courses: $e');
//   }  finally {
//       isLoadingState.value = false; // Set loading to false
//     }
// }

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
      _moduleExpansionMap
          .clear(); // Clear expansion state when mentors are updated
      for (var mentor in mentors) {
        _moduleExpansionMap[mentor.id] = List<bool>.filled(
            mentor.selectedModules.length,
            false); // Initialize expansion state for modules
      }
      notifyListeners();
    });
  }

  List<bool> getModuleExpansionList(String mentorId) {
    return _moduleExpansionMap[mentorId] ?? [];
  }

  void toggleModuleExpansion(String mentorId, int moduleIndex) {
    if (_moduleExpansionMap.containsKey(mentorId)) {
      final moduleExpansions = _moduleExpansionMap[mentorId]!;
      moduleExpansions[moduleIndex] = !moduleExpansions[moduleIndex];
      notifyListeners();
    }
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

  Future<bool> isModuleAvailableForCourse(
      String courseName, List<String> selectedModules) async {
    try {
      // Fetch the course from Firestore
      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseName)
          .get();
      Map<String, dynamic>? courseData =
          courseSnapshot.data() as Map<String, dynamic>?;
      if (courseData != null) {
        List<String> courseModules =
            List<String>.from(courseData['modules'] ?? []);

        // Check if any of the selected modules are already assigned to another mentor
        QuerySnapshot mentorSnapshot =
            await FirebaseFirestore.instance.collection('mentors').get();
        for (DocumentSnapshot doc in mentorSnapshot.docs) {
          Map<String, dynamic>? mentorData =
              doc.data() as Map<String, dynamic>?;
          if (mentorData != null) {
            List<String> mentorModules =
                List<String>.from(mentorData['modules'] ?? []);
            if (selectedModules
                .any((module) => mentorModules.contains(module))) {
              return false; // Return false if any of the selected modules are already assigned to another mentor
            }
          }
        }
        // Check if the selected modules are available for the course
        return selectedModules
            .every((module) => courseModules.contains(module));
      }
      return false;
    } catch (e) {
      print('Error checking module availability: $e');
      return false;
    }
  }

  void updateMentor(Mentor updatedMentor) {
    final index =
        _mentors.indexWhere((mentor) => mentor.id == updatedMentor.id);
    if (index != -1) {
      _mentors[index] = updatedMentor;
      notifyListeners();
    }
  }
}