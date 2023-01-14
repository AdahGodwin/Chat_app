import 'package:chat_app/widgets/chats/messag_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messages extends StatelessWidget {
  const Messages(this.id, this.userId, {super.key});
  final String id;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    Future<void> setChatMessageSeen(String chatId, String messageId) async {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(id)
            .collection('messages')
            .doc(messageId)
            .update(
          {
            'seen': true,
          },
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection('chats')
            .doc(userId)
            .collection('messages')
            .doc(messageId)
            .update(
          {
            'seen': true,
          },
        );
      } catch (e) {
        print(e);
      }
    }

    Future<void> deleteMessage(String chatId, String messageId) async {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(id)
            .collection('messages')
            .doc(messageId)
            .delete();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('an Error Occured'),
            backgroundColor: Theme.of(context).snackBarTheme.actionTextColor,
          ),
        );
      }
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(id)
          .collection('messages')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data?.docs;
        final lastMessage =
            chatDocs!.isEmpty ? '' : chatDocs[chatDocs.length - 1]['text'];
        final user = FirebaseAuth.instance.currentUser;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            if (chatDocs[index]['userId'] != user?.uid &&
                chatDocs[index]['seen'] == false) {
              setChatMessageSeen(id, chatDocs[index].id);
            }
            return GestureDetector(
              child: GestureDetector(
                onLongPress: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              'Are you sure you want to delete this message',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  deleteMessage(id, chatDocs[index].id);
                                },
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('No'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                child: MessageBubble(
                  chatDocs[index],
                  chatDocs[index]['userId'] == user!.uid,
                  chatDocs[index]['username'],
                  key: ValueKey(chatDocs[index].id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
