import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/mentor_controller.dart';
import 'package:phloem_mentors/model/course_model.dart';
import 'package:phloem_mentors/model/mentor_model.dart';

class MentorHome extends StatelessWidget {
  final String email;

  const MentorHome({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Home'),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width *
            0.58, // drawer width to 60% of screen width
        child: Drawer(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mentors')
                .where('email', isEqualTo: email)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                log('No mentor data found for email: $email');
                return const CircularProgressIndicator();
              }

              final mentorData =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(mentorData['name']),
                    accountEmail: Text(email),
                    currentAccountPicture: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: NetworkImage(mentorData['image']),
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                            BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      // Navigate to home or handle the action
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Sign Out'),
                    onTap: () {
                      // Implement sign out functionality
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mentors')
            .where('email', isEqualTo: email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No mentor data found'));
          }

          final mentor = Mentor.fromSnapshot(snapshot.data!.docs.first);

          // Fetch course details for the mentor
    return FutureBuilder<List<Course>>(
      future: MentorProvider().fetchCourses(), // Fetch courses from Firestore
      builder: (context, courseSnapshot) {
        if (!courseSnapshot.hasData || courseSnapshot.data!.isEmpty) {
          return const Center(child: Text('No course data found'));
        }

        Course? mentorCourse;
        for (var course in courseSnapshot.data!) {
          if (course.name == mentor.courses) {
            mentorCourse = course;
            break;
          }
        }
        
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Card(
                      elevation: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome ${mentor.name} !!!',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'A platform to record your classes...',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  RichText(
                    textAlign: TextAlign.left,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        const TextSpan(text: 'Course alotted: '),
                        TextSpan(
                          text: mentor.courses,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 243, 33, 44),
                          ),
                        ),
                        TextSpan(
                        text: mentorCourse?.payment == 'free' ? ' (Free)' : ' (Paid)',
                        style: const TextStyle(
                          color: Colors.green,
                        ),
                      ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Modules:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        mentor.selectedModules.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      String module = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text('$index. $module',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: SizedBox(
                              width: 87,
                              height: 27,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle record action
                                },
                                child: const Text('Record',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      );
        },
      ),
    );
  }
}
