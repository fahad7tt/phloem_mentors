// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/videomodule_controller.dart';
import 'package:phloem_mentors/model/mentor_model.dart';
import 'package:phloem_mentors/model/video_model.dart';
import 'package:phloem_mentors/view/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MyVideosPage extends StatefulWidget {
  final String email;

  const MyVideosPage({super.key, required this.email});

  @override
  // ignore: library_private_types_in_public_api
  _MyVideosPageState createState() => _MyVideosPageState();
}

class _MyVideosPageState extends State<MyVideosPage> {
  Future<void> _editVideoUrl(
      BuildContext context, String moduleName, String currentUrl) async {
    final TextEditingController urlController =
        TextEditingController(text: currentUrl);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Video URL'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'YouTube URL',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a YouTube URL.';
                }
                final RegExp regExp = RegExp(
                    r'^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$');
                if (!regExp.hasMatch(value)) {
                  return 'Please enter a valid YouTube URL.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newUrl = urlController.text;
                  context.read<VideoController>().updateVideoUrl(
                    VideoModule(
                      moduleName: moduleName,
                      moduleDescription:
                          '', // Description not needed for update
                      videoUrl: newUrl,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String moduleName) async {
    // Show confirmation dialog
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Video'),
          content:
              Text('Are you sure you want to delete the video for $moduleName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when canceled
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // If confirmed, delete the video
    if (confirmDelete == true) {
      await context.read<VideoController>().deleteVideo(context, moduleName);
      setState(() {}); // Refresh the state to reflect changes
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Video for $moduleName deleted successfully'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Videos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mentors')
            .where('email', isEqualTo: widget.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No mentor data found'));
          } else {
            final mentor = Mentor.fromSnapshot(snapshot.data!.docs.first);
            return ListView.builder(
              itemCount: mentor.selectedModules.length,
              itemBuilder: (context, index) {
                final moduleName = mentor.selectedModules[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0), // Adjust vertical spacing
                  child: FutureBuilder<String?>(
                    future: context
                        .read<VideoController>()
                        .getVideoUrlFromFirestore(moduleName),
                    builder: (context, urlSnapshot) {
                      if (urlSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (urlSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${urlSnapshot.error}'));
                      } else if (urlSnapshot.data == null) {
                        return ListTile(
                          title: Text(
                            moduleName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('No video recorded yet'),
                        );
                      } else {
                        final videoUrl = urlSnapshot.data!;
                        return GestureDetector(
                          onDoubleTap: () {
                            _confirmDelete(context, moduleName);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 252, 230, 198),
                            ),
                            child: ListTile(
                              title: Text(
                                moduleName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              YoutubePlayerPage(moduleName: moduleName),
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.play_circle_outline,
                                        size: 25),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 25),
                                    onPressed: () {
                                      _editVideoUrl(
                                          context, moduleName, videoUrl);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class YoutubePlayerPage extends StatelessWidget {
  final String moduleName;

  const YoutubePlayerPage({super.key, required this.moduleName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: context.read<VideoController>().getVideoUrlFromFirestore(moduleName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(moduleName),          
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(moduleName),
            ),
            body: const Center(
              child: Text('Error loading video.'),
            ),
          );
        } else {
          final videoUrl = snapshot.data!;
          final videoId = getYouTubeVideoIdFromUrl(videoUrl);
          return Scaffold(
            appBar: AppBar(
              title: Text(moduleName),
            ),
            body: YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: YoutubePlayerController(
                  initialVideoId: videoId!,
                  flags: const YoutubePlayerFlags(
                    autoPlay: true,
                    mute: false,
                  ),
                ),
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    Expanded(
                      child: Center(child: player),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}
