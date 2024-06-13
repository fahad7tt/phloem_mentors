import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ModuleChatPage extends StatefulWidget {
  final String moduleName;
  final String? mentorName;

  const ModuleChatPage({required this.moduleName, this.mentorName, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ModuleChatPageState createState() => _ModuleChatPageState();
}

class _ModuleChatPageState extends State<ModuleChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late DatabaseReference _messageRef;
  final List<Map<dynamic, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _messageRef = FirebaseDatabase.instance.ref().child('messages').child(widget.moduleName);
    _messageRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? value = event.snapshot.value as Map<dynamic, dynamic>?;

      if (value != null) {
        setState(() {
          _messages.add({...value, 'key': event.snapshot.key});
        });
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    try {
      await _messageRef.push().set({
        'message': message,
        'sender': widget.mentorName,
        'timestamp': ServerValue.timestamp,
      });
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _deleteMessage(String key) async {
    try {
      await _messageRef.child(key).remove();
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<bool?> _confirmDeleteMessage(BuildContext context, String key) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteMessage(key);
                setState(() {
                  _messages.removeWhere((message) => message['key'] == key);
                });
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleName),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSender = message['sender'] == widget.mentorName;
                return Dismissible(
                  key: Key(message['key'] ?? ''),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) {
                    return _confirmDeleteMessage(context, message['key'] ?? '');
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _messages.removeAt(index);
                    });
                  },
                  child: ListTile(
                    title: Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        message['sender'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSender
                                ? Theme.of(context).primaryColor.withOpacity(0.8)
                                : const Color.fromARGB(255, 116, 170, 252).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            message['message'] ?? '',
                            style: TextStyle(
                              color: isSender ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}