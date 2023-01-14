import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(this.message, this.isMe, this.username, {super.key});
  final QueryDocumentSnapshot<Map<String, dynamic>> message;
  final bool isMe;
  final String username;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[300] : Theme.of(context).accentColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
                  !isMe ? const Radius.circular(0) : const Radius.circular(12),
              bottomRight:
                  isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        message['text'],
                        style: TextStyle(
                          color: isMe
                              ? Colors.black
                              : Theme.of(context)
                                  .accentTextTheme
                                  .headline1!
                                  .color,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat('hh:mm')
                              .format(message['createdAt'].toDate()),
                          style: TextStyle(
                            color: isMe
                                ? Colors.black
                                : Theme.of(context)
                                    .accentTextTheme
                                    .headline1!
                                    .color,
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        if (isMe)
                          Icon(
                            message['seen'] == true
                                ? Icons.check_circle_rounded
                                : Icons.check_circle_outline,
                            color: message['seen'] == true
                                ? Colors.green
                                : Colors.grey,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
