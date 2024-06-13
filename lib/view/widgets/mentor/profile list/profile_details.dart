import 'package:flutter/material.dart';
import 'package:phloem_mentors/model/mentor_model.dart';
import 'profile_list_items.dart';

// ignore: must_be_immutable
class ProfilePage extends StatelessWidget {
  final Mentor mentor; 

  const ProfilePage({
    super.key,
    required this.mentor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Profile'),
        centerTitle: true
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          SizedBox(
            width: 150,
            height: 150,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(mentor.imageUrl),
                  radius: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  mentor.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 180.0),
            child: Text(
              'Profile Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const ProfileList(),
        ],
      ),
    );
  }
}