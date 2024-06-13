 import 'package:flutter/material.dart';
import 'package:phloem_mentors/controller/videomodule_controller.dart';
import 'package:phloem_mentors/model/video_model.dart';
import 'package:provider/provider.dart';
import 'video_display.dart';

class AddVideoModulePage extends StatelessWidget {
  final VideoModule module;

  const AddVideoModulePage({
    super.key,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController youTubeUrlController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          module.moduleName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey.shade200,
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  module.moduleDescription,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: youTubeUrlController,
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final String youTubeUrl = youTubeUrlController.text;
                      final videoModule = VideoModule(
                        moduleName: module.moduleName,
                        moduleDescription: module.moduleDescription,
                        videoUrl: youTubeUrl,
                      );
                      context.read<VideoController>().updateVideoUrl(videoModule);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoDisplayPage(
                            moduleName: module.moduleName,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}