import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/widgets/chats/messages.dart';
import 'package:chat_app/widgets/chats/new_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  static const routeName = 'chat-screen';

  // @override
  // void initState() {
  //   super.initState();
  //   final fbm = FirebaseMessaging.instance;
  //   fbm.requestPermission();

  //   FirebaseMessaging.onMessage.listen((message) {
  //     print(message);
  //     return;
  //   });

  //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //     print(message);
  //     return;
  //   });

  //   fbm.subscribeToTopic('chat');
  // }
  Future<String> createChat(
    User user,
    String otherUserId,
    String otherUserName,
    String otherUserImage,
  ) async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .doc(otherUserId)
          .set({
        'userIds': [user.uid, otherUserId],
        'users': [
          {
            'username': userData.data()?['username'],
            'image_url': userData.data()?['profileImageUrl'],
          },
          {
            'username': otherUserName,
            'image_url': otherUserImage,
          }
        ],
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .collection('chats')
          .doc(user.uid)
          .set({
        'userIds': [user.uid, otherUserId],
        'users': [
          {
            'username': userData.data()?['username'],
            'image_url': userData.data()?['profileImageUrl'],
          },
          {
            'username': otherUserName,
            'image_url': otherUserImage,
          }
        ],
      });

      return otherUserId;
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    var routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var title = routeArgs['username'];
    var id = routeArgs['id'] as String;
    var imageUrl = routeArgs['image_url'] as String;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30.0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              children: <Widget>[
                Text(title!),
                StreamBuilder(
                  stream: FirebaseDatabase.instance.ref('$id/active').onValue,
                  builder: (context, snapshot) {
                    return snapshot.data?.snapshot.value == true
                        ? const Text(
                            'online',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.greenAccent,
                            ),
                          )
                        : const Text(
                            'offline',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Messages(id, user?.uid),
          ),
          NewMessage(id, createChat, title, imageUrl),
        ],
      ),
    );
  }
}
