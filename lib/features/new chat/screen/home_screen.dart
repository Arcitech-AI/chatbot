// screens/home_screen.dart
import 'package:chatbot_example/features/new%20chat/service/firestore_service.dart';
import 'package:chatbot_example/features/new%20chat/widget/user_tile.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'friend_requests_screen.dart';

class HomeScreen1 extends StatelessWidget {
  final String currentUid;
  final FirestoreService firestore = FirestoreService();

  HomeScreen1({super.key, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        actions: [
          IconButton(
            icon: Icon(Icons.mail),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FriendRequestsScreen(currentUid: currentUid)),
            ),
          )
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: firestore.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final users = snapshot.data!.where((u) => u.uid != currentUid).toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, i) {
              final user = users[i];

              return UserTile(
                // email: user.email,
                name: user.name,
                actionLabel: 'Request',
                onTap: () => firestore.sendFriendRequest(fromUid: currentUid, toUid:  user.uid,  fromUsername: user.name),
              );
            },
          );
        },
      ),
    );
  }
}
