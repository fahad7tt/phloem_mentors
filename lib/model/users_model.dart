import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String email;
  String password;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password
  });

  // Factory method to create a UserModel instance from a QueryDocumentSnapshot
  factory UserModel.fromSnapshot(QueryDocumentSnapshot snapshot) {
    // Get data from the snapshot
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    
    // Extract fields from the data map
    String id = snapshot.id;
    String name = data['name'];
    String email = data['email'];
    String password = data['password'];

    // Return a new UserModel instance
    return UserModel(
      id: id,
      name: name,
      email: email,
      password: password
    );
  }
}
