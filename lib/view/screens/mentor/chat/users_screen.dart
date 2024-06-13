import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/course_controller.dart';

class ParticipantsScreen extends StatefulWidget {

  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: CourseProvider.enrolledUser.isEmpty
      ? const Center(child: Text('No enrolled users'))
      : ListView.builder(
        itemCount: CourseProvider.enrolledUser.length,
        itemBuilder: (context, index){
          return Container(
                  color: index % 2 == 0 ? Colors.grey[200] : Colors.white, 
                  child: ListTile(
                    title: Text(CourseProvider.enrolledUser[index]),
                  ),
                );
        },
        ),
    );
  }
}