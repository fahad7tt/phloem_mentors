// // import 'package:firebase_database/firebase_database.dart';

// // class ChatRepository {
// //   final DatabaseReference _database = FirebaseDatabase.instance.ref();

// //   Future<void> sendMessage(
// //       String senderId, String receiverId, String messageText) async {
// //     var timeSend = DateTime.now().toUtc().toIso8601String();

// //     final messageRef =
// //         _database.child('users/$senderId/chats/$receiverId/messages').push();
// //     final message = {
// //       'text': messageText,
// //       'senderId': senderId,
// //       "timeSend": timeSend,
// //     };

// //     await messageRef.set(message);

// //     // To send the message to the receiver's side as well (if needed)
// //     _database
// //         .child('users/$receiverId/chats/$senderId/messages')
// //         .push()
// //         .set(message);
// //   }
// // }


// import 'package:firebase_database/firebase_database.dart';

// class ChatService {
//   final DatabaseReference _messageRef = FirebaseDatabase.instance.re-ference().child('messages');

//   Future<void> sendMessage(String moduleName, String userId, String message) async {
//     try {
//       await _messageRef.child(moduleName).push().set({
//         'userId': userId,
//         'message': message,
//         'timestamp': ServerValue.timestamp,
//       });
//     } catch (e) {
//       // ignore: avoid_print
//       print('Error sending message: $e');
//     }
//   }

//   Stream<DatabaseEvent> getMessages(String moduleName) {
//     return _messageRef.child(moduleName).onValue;
//   }
// }