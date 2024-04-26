import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Mentor {
  final String id;
  final String name;
  final String email;
  final String password;
  String courses;
  final String imageUrl;
  List<String> selectedModules;
  File? selectedImage;

  Mentor({
    required this.name,
    required this.email,
    required this.password,
    required this.courses,
    required this.imageUrl,
    this.selectedImage,
    required String id,
    this.selectedModules = const [],
  }) : id = id.isNotEmpty ? id : const Uuid().v4();

  factory Mentor.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null!");
    }
    return Mentor(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      courses: data['courses'] ?? [],
      imageUrl: data['image'] ?? '',
      selectedModules: List<String>.from(data['modules'] ?? []),
    );
  }
}