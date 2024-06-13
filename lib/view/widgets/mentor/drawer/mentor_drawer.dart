import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phloem_mentors/model/mentor_model.dart';
import 'package:phloem_mentors/view/screens/mentor/chat/course_selection_screen.dart';
import 'package:phloem_mentors/view/screens/mentor/home/mentor_home.dart';
import 'package:phloem_mentors/view/screens/mentor/videos/mentor_videos.dart';
import 'package:phloem_mentors/view/screens/sign%20in/sign_in.dart';
import 'package:phloem_mentors/view/widgets/mentor/profile%20list/profile_details.dart';
import 'package:provider/provider.dart';
import 'package:phloem_mentors/controller/singout_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MentorDrawer extends StatelessWidget {
  final Mentor mentor;
  final String email;

  const MentorDrawer({required this.mentor, required this.email, super.key});

  Future<String> _fetchVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mentors')
            .where('email', isEqualTo: email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No mentor data found'));
          }
          final mentorData = snapshot.data?.docs.isNotEmpty == true
              ? snapshot.data!.docs.first.data() as Map<String, dynamic>
              : null;

          if (mentorData == null) {
            return const Center(child: Text('No mentor data found'));
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(mentorData['name']),
                accountEmail: Text(mentorData['email']),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: NetworkImage(mentorData['image']),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(6),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MentorHome(mentor: mentor, email: email),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: const Text('My Videos'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyVideosPage(email: email),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text('Chat'),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CourseSelectionScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  // Navigate to profile page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(mentor: mentor)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Sign Out'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Sign Out"),
                        content:
                            const Text("Are you sure you want to sign out?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Call the signOut method from AuthProvider
                              Provider.of<AuthProvider>(context, listen: false)
                                  .signOut();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignInPage()),
                              );
                            },
                            child: const Text("Sign Out"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 220),
              FutureBuilder<String>(
                future: _fetchVersionInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching version'));
                  } else {
                    return ListTile(
                      subtitle: Center(
                        child: Text('Version: ${snapshot.data}',
                            style: const TextStyle(fontSize: 16.0)),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
