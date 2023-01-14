import 'dart:convert';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const routeName = 'chat-list';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User's List"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No users found'));
            }
            final userList = snapshot.data?.docs
                .where((currentUser) => user?.uid != currentUser.id)
                .toList();
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(
                          ChatScreen.routeName,
                          arguments: {
                            'id': userList?[index].id,
                            'username': userList?[index]['username'],
                            'image_url': userList?[index]['profileImageUrl'],
                          });
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage(userList?[index]['profileImageUrl']),
                    ),
                    title: Text(
                      userList?[index]['username'],
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ),
              itemCount: userList?.length,
            );
          }),
    );
  }
}
