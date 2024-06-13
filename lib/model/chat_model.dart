// chat_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String userName;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userName,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatMessage(
      id: snapshot.id,
      userName: data['userName'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'message': message,
      'timestamp': timestamp,
    };
  }
}