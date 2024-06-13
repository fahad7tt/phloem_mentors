// chat_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat_model.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatProvider() {
    _fetchMessages();
  }

  void _fetchMessages() {
    _firestore.collection('chats').orderBy('timestamp').snapshots().listen((snapshot) {
      _messages = snapshot.docs.map((doc) => ChatMessage.fromSnapshot(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> sendMessage(String userName, String message) async {
    final newMessage = ChatMessage(
      id: '',
      userName: userName,
      message: message,
      timestamp: DateTime.now(),
    );
    await _firestore.collection('chats').add(newMessage.toMap());
  }
}