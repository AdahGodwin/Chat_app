import 'package:chat_app/screens/chat_list_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseDatabase _realtime = FirebaseDatabase.instance;
  User? user;

  void updateUserPresence() async {
    Map<String, dynamic> online = {
      'active': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };
    Map<String, dynamic> offline = {
      'active': false,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };

    final connectedRef = _realtime.ref('.info/connected');

    connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value as bool? ?? false;
      if (isConnected) {
        await _realtime.ref().child(user!.uid).update(online);
      } else {
        _realtime.ref().child(user!.uid).onDisconnect().update(offline);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    updateUserPresence();

    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chats'),
        actions: [
          DropdownButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            items: [
              DropdownMenuItem(
                value: 'Logout',
                child: Row(
                  children: const <Widget>[
                    Icon(Icons.exit_to_app),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Logout'),
                  ],
                ),
              )
            ],
            onChanged: (value) {
              if (value == 'Logout') {
                FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('chats')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData == false) {
            return const Center(
              child: Text('You have no messages'),
            );
          }
          final chatList = snapshot.data?.docs;
          return ListView.builder(
            itemBuilder: (context, index) {
              final userIds = chatList?[index]['userIds'] as List<dynamic>;
              int otherIndex = userIds.indexOf(user?.uid) == 0 ? 1 : 0;
              var ref = _realtime.ref('${userIds[otherIndex]}/active').onValue;

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('chats')
                    .doc(userIds[otherIndex])
                    .collection('messages')
                    .orderBy(
                      'createdAt',
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: SizedBox(height: 10),
                    );
                  }
                  if (snapshot.hasData == false) {
                    return const Center(
                      child: SizedBox(height: 10),
                    );
                  }
                  final messages = snapshot.data?.docs;
                  final unreadMessagesCount = messages
                      ?.where((message) =>
                          message['seen'] == false &&
                          message['userId'] == userIds[otherIndex])
                      .length;
                  return StreamBuilder(
                      stream: ref,
                      builder: (context, event) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ChatScreen.routeName,
                              arguments: {
                                'id': chatList?[index].id,
                                'username': chatList?[index]['users']
                                    [otherIndex]['username'],
                                'image_url': chatList?[index]['users']
                                    [otherIndex]['image_url'],
                                'otherUserId': userIds[otherIndex]
                              },
                            );
                          },
                          child: ListTile(
                            key: ValueKey(
                                chatList?[index]['userIds'][otherIndex]),
                            leading: Stack(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    chatList?[index]['users'][otherIndex]
                                        ['image_url'],
                                  ),
                                ),
                                if (event.data?.snapshot.value == true)
                                  const Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 6,
                                      backgroundColor: Colors.green,
                                    ),
                                  )
                              ],
                            ),
                            title: Text(
                              chatList?[index]['users'][otherIndex]['username'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                              ),
                            ),
                            subtitle: messages!.isEmpty == true
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (messages[0]['userId'] == user?.uid)
                                        Icon(
                                          messages[0]['seen'] == true
                                              ? Icons.check_circle_rounded
                                              : Icons.check_circle_outline,
                                          color: messages[0]['seen'] == true
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Flexible(
                                        child: Text(
                                          messages[0]['text'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: messages[0]['seen'] ==
                                                          true ||
                                                      messages[0]['userId'] ==
                                                          user?.uid
                                                  ? Theme.of(context)
                                                      .disabledColor
                                                  : Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  messages.isEmpty
                                      ? ''
                                      : DateFormat('hh:mm, dd/MM/yy').format(
                                          messages[0]['createdAt'].toDate()),
                                  style: messages.isEmpty
                                      ? null
                                      : TextStyle(
                                          color: messages[0]['seen'] == true ||
                                                  messages[0]['userId'] ==
                                                      user?.uid
                                              ? Colors.black
                                              : Theme.of(context).accentColor),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                if (unreadMessagesCount != 0)
                                  CircleAvatar(
                                    radius: 9,
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                    child: Text(
                                      unreadMessagesCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      });
                },
              );
            },
            itemCount: chatList?.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {
          Navigator.of(context).pushNamed(ChatListScreen.routeName);
        },
      ),
    );
  }
}
