// course_selection_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/course_controller.dart';
import 'package:phloem_mentors/controller/mentor_controller.dart';
import 'package:phloem_mentors/controller/signin_controller.dart';
import 'package:phloem_mentors/model/course_model.dart';
import 'package:phloem_mentors/model/mentor_model.dart';
import 'package:phloem_mentors/view/screens/mentor/chat/module_chat_page.dart';
import 'package:phloem_mentors/view/screens/mentor/chat/users_screen.dart';

class CourseSelectionScreen extends StatelessWidget {
  const CourseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mentorProvider = MentorProvider();
    return FutureBuilder<Course?>(
      future: _fetchCourseDetails(CourseProvider.mentorCourses),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text('No course data found'),
            ),
          );
        }

        final course = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(CourseProvider.mentorCourses),
            actions: [
                  IconButton(
                    icon: const Icon(Icons.people),
                    onPressed: () async {
                      print('id: ${course.id}');
                      CourseProvider.enrolledUser = [];
                      CourseProvider.enrolledUser = await CourseProvider().getEnrolledUser(course.id);
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParticipantsScreen(),
                        ),
                      );
                    },
                  ),
                ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mentors')
                .where('email', isEqualTo: SignInController.mentorEmail)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No mentor data found'));
              }
        
              final mentor = Mentor.fromSnapshot(snapshot.data!.docs.first);
        
              // Fetch course details for the mentor
              return FutureBuilder<List<Course>>(
                future: MentorProvider().fetchCourses(),
                builder: (context, courseSnapshot) {
                  CourseProvider.mentorCourses = mentor.courses;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            mentor.selectedModules.asMap().entries.map((entry) {
                         
                          String module = entry.value;
                      
                                return Column(
                                  children: [
                                   GestureDetector(
                                onTap: () async {
                                  final mentorName = await mentorProvider.getMentorName(SignInController.mentorEmail!);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ModuleChatPage(moduleName: module, mentorName: mentorName),
                                    ),
                                  );
                                },
                                child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                child: ListTile(
                  title: Text(module),
                ),
              ),
            ),
                              ),
                                ],
                            );                            
                        }).toList()
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    );
  }

  Future<Course?> _fetchCourseDetails(String courseName) async {
    final courses = await MentorProvider().fetchCourses();
    return courses.firstWhere(
      (course) => course.name == courseName,
      orElse: () => Course(
        id: '',
        name: '',
        modules: [],
        descriptions: [],
        payment: '',
        amount: '',
      ),
    );
  }
}