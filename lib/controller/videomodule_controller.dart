// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phloem_mentors/model/video_model.dart';

class VideoController extends ChangeNotifier {
  final Map<String, VideoModule> _videoModules = {};

  Map<String, VideoModule> get videoModules => _videoModules;

  Future<void> updateVideoUrl(VideoModule videoModule) async {
    _videoModules[videoModule.moduleName] = videoModule;
    notifyListeners();

    // Find and update the video module in Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('recordings')
        .where('moduleName', isEqualTo: videoModule.moduleName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('recordings')
          .doc(docId)
          .update({
        'videoUrl': videoModule.videoUrl,
      });
    } else {
      await FirebaseFirestore.instance.collection('recordings').add({
        'moduleName': videoModule.moduleName,
        'moduleDescription': videoModule.moduleDescription,
        'videoUrl': videoModule.videoUrl,
      });
    }
  }

  Future<void> deleteVideo(BuildContext context, String moduleName) async {
    _videoModules.remove(moduleName);
    notifyListeners();

    // Find and delete the video module in Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('recordings')
        .where('moduleName', isEqualTo: moduleName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('recordings')
          .doc(docId)
          .delete();
    }
    notifyListeners();
  }

  // Method to fetch video URL from Firestore using moduleName
  Future<String?> getVideoUrlFromFirestore(String moduleName) async {
    try {
      // Query Firestore for the document matching moduleName
      final querySnapshot = await FirebaseFirestore.instance
          .collection('recordings')
          .where('moduleName', isEqualTo: moduleName)
          .get();

      // If document exists, return the videoUrl
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['videoUrl'];
      } else {
        // If document doesn't exist, return null or handle accordingly
        return null;
      }
    } catch (e) {
      // Handle any errors
      print('Error fetching video URL: $e');
      return null;
    }
  }
}