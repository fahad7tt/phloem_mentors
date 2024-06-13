 import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  String name;
  List<String> modules;
  String payment;
  List<String> descriptions;
  String amount;
  List<String>? enrolledUsers;

  Course({
    required this.id,
    required this.name,
    required this.modules,
    required this.payment,
    required this.descriptions,
    required this.amount,
    this.enrolledUsers
  });

  factory Course.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null!");
    }
    return Course(
      id: snapshot.id,
      name: data['name'] ?? '', // Using ?? to provide a default value if name is null
      modules: List<String>.from(data['modules'] ?? []),
      payment: data['payment'] ?? '',
      descriptions: _getDescription(data['descriptions']),
      amount: data['amount'] ?? '',
      enrolledUsers: List<String>.from(data['enrolledUsers'] ?? [])
    );
  }

  static List<String> _getDescription(dynamic description) {
  if (description is String) {
    return [description]; // Convert the string to a single-item list
  } else if (description is List<dynamic>) {
    return description.cast<String>(); // Ensure it's a List<String>
  }
  return []; // Default empty list
}

  static Course get empty => Course(
        id: '',
        name: '',
        modules: [],
        payment: '',
        descriptions: [],
        amount: '',
        enrolledUsers: []
      );
}