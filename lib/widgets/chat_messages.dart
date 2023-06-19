import 'package:chat_app/widgets/message_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  ChatMessages({super.key});
  final authenticatedUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('user-chats')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No Messages Yet'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }
        final chats = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemBuilder: (context, index) {
            final currentUser = chats[index].data();
            final nextUser =
                index + 1 < chats.length ? chats[index + 1].data() : null;
            final nextUserIsSame =
                nextUser != null && currentUser['userId'] == nextUser['userId'];
            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: currentUser['message'],
                  isMe: currentUser['userID'] == authenticatedUser.uid);
            } else {
              return MessageBubble.first(
                  userImage: currentUser['userImage'],
                  username: currentUser['userName'],
                  message: currentUser['message'],
                  isMe: currentUser['userID'] == authenticatedUser.uid);
            }
          },
          itemCount: chats.length,
        );
      },
    );
  }
}
