import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  final String id;
  final String otherUserName;
  final String imageUrl;
  const NewMessage(this.id, this.createChat, this.otherUserName, this.imageUrl,
      {super.key});
  final Future<String> Function(
    User user,
    String otherUserId,
    String otherUserName,
    String otherUserImage,
  ) createChat;
  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  bool? chatExists;
  final _messageController = TextEditingController();
  Future<void> isExistingChat(String userId, String otherUserId) async {
    final mychat = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(otherUserId)
        .get();
    final otherChat = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .collection('chats')
        .doc(userId)
        .get();

    if (mychat.exists && otherChat.exists) {
      setState(() {
        chatExists = true;
      });
    } else {
      setState(() {
        chatExists = false;
      });
    }
  }

  void _sendMessage(String messageId) async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    await isExistingChat(user.uid, widget.id);
    if (chatExists! == false) {
      await widget.createChat(
        user,
        widget.id,
        widget.otherUserName,
        widget.imageUrl,
      );
    }
    _messageController.clear();
    var createdAt = DateTime.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(widget.id)
        .collection(
          'messages',
        )
        .doc(messageId)
        .set({
      'text': _enteredMessage,
      'createdAt': createdAt,
      'userId': user.uid,
      'username': userData.data()!['username'],
      'seen': false,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .collection('chats')
        .doc(user.uid)
        .collection(
          'messages',
        )
        .doc(messageId)
        .set({
      'text': _enteredMessage,
      'createdAt': createdAt,
      'userId': user.uid,
      'username': userData.data()!['username'],
      'seen': false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              maxLines: null,
              decoration: const InputDecoration(labelText: "Send a Message"),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
              controller: _messageController,
            ),
          ),
          IconButton(
            onPressed: _enteredMessage.trim().isEmpty
                ? null
                : () {
                    String messageId =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    _sendMessage(messageId);
                  },
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
