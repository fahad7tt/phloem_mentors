import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/course_controller.dart';
import 'package:phloem_mentors/controller/videomodule_controller.dart';
import 'package:phloem_mentors/model/video_model.dart';
import 'package:phloem_mentors/controller/mentor_controller.dart';
import 'package:phloem_mentors/model/course_model.dart';
import 'package:phloem_mentors/model/mentor_model.dart';
import 'package:phloem_mentors/view/screens/mentor/videos/videomodule_screen.dart';
import 'package:phloem_mentors/view/widgets/mentor/drawer/mentor_drawer.dart';
import 'package:provider/provider.dart';

class MentorHome extends StatelessWidget {
  final Mentor mentor;
  final String email;

  const MentorHome({required this.mentor, required this.email, super.key});

  Future<bool> _hasRecordedVideo(BuildContext context, String moduleName) async {
    final videoUrl = await context.read<VideoController>().getVideoUrlFromFirestore(moduleName);
    return videoUrl != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Home'),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.58, // drawer width to 60% of screen width
        child: MentorDrawer(mentor: mentor, email: email),
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
            future: MentorProvider().fetchCourses(),
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

              CourseProvider.mentorCourses = mentor.courses;

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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
                              text: mentorCourse?.payment == 'free'
                                  ? ' (Free)'
                                  : ' (Paid)',
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (mentorCourse != null && mentorCourse.payment != 'free')
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: const Color.fromARGB(255, 87, 96, 177),
                          ),
                          child: Text(
                            '₹${mentorCourse.amount}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Modules:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                      Consumer<VideoController>(
                        builder: (context, videoController, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                mentor.selectedModules.asMap().entries.map((entry) {
                              int index = entry.key + 1;
                              String module = entry.value;
                              String? description;

                              if (mentorCourse?.descriptions.isNotEmpty ?? false) {
                                description = mentorCourse?.descriptions[entry.key];
                              }

                              return FutureBuilder<bool>(
                                future: _hasRecordedVideo(context, module),
                                builder: (context, snapshot) {
                                  final hasRecordedVideo = snapshot.data ?? false;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: ExpansionTileCard(
                                      initialPadding: EdgeInsets.zero,
                                      title: Text('$index. $module',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400)),
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 20),
                                            child: Text(description ?? ''),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 20),
                                                child: SizedBox(
                                                  width: 87,
                                                  height: 30,
                                                  child: ElevatedButton(
                                                    onPressed: hasRecordedVideo
                                                        ? null
                                                        : () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    AddVideoModulePage(
                                                                  module: VideoModule(
                                                                    moduleName: module,
                                                                    moduleDescription:
                                                                        description!,
                                                                    videoUrl: '',
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                    child: const Text('Record',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.only(right: 10),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
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