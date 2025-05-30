// screens/chat_home_screen.dart
import 'package:chatbot_example/features/new%20chat/service/firestore_service.dart';
import 'package:chatbot_example/features/new%20chat/widget/user_tile.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class ChatHomeScreen extends StatelessWidget {
  final String currentUid;
  final FirestoreService firestore = FirestoreService();

  ChatHomeScreen({super.key, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: firestore.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final allUsers = snapshot.data!;
          final currentUser = allUsers.firstWhere((u) => u.uid == currentUid);

          final friendList = allUsers
              .where((u) => currentUser.friends.contains(u.uid))
              .toList();

          if (friendList.isEmpty) {
            return Center(child: Text("No friends yet. Accept or send requests!"));
          }

          return ListView.builder(
            itemCount: friendList.length,
            itemBuilder: (context, index) {
              final friend = friendList[index];

              return UserTile(
                // email: friend.email,
                name: friend.name,
                actionLabel: 'Chat',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen1(
                        currentUid: currentUid,
                        friendUid: friend.uid,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
