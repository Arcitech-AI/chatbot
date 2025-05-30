// screens/friend_requests_screen.dart
import 'package:chatbot_example/features/new%20chat/service/firestore_service.dart';
import 'package:chatbot_example/features/new%20chat/widget/user_tile.dart';
import 'package:flutter/material.dart';
// import '../services/firestore_service.dart';
import '../models/user_model.dart';
// import '../widgets/user_tile.dart';

class FriendRequestsScreen extends StatelessWidget {
  final String currentUid;
  final FirestoreService firestore = FirestoreService();

  FriendRequestsScreen({super.key, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friend Requests")),
      body: StreamBuilder<List<AppUser>>(
        stream: firestore.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final allUsers = snapshot.data!;
          final currentUser = allUsers.firstWhere((u) => u.uid == currentUid);
          final senders =
              allUsers
                  .where((u) => currentUser.receivedRequests.contains(u.uid))
                  .toList();

          if(senders.length == 0) {
            return Center(
              child: Text("No Friend Request"),
            );
          }
          else {
            return ListView.builder(
            itemCount: senders.length,
            itemBuilder: (_, i) {
              final sender = senders[i];

              // return UserTile(
              //   // email: sender.email,
              //   name: sender.name,
              //   actionLabel: 'Accept',
              //   onTap:
              //       () => firestore.acceptFriendRequest(currentUid, sender.uid),
              // );

              return Container(
                child: Row(
                  children: [
                    Text(sender.name),
                    Spacer(),
                    ElevatedButton(onPressed: () {firestore.acceptFriendRequest(currentUid, sender.uid);}, child: Text("Accept")),
                    ElevatedButton(onPressed: () {firestore.rejectFriendRequest(sender.uid, currentUid);}, child: Text("Reject")),
                  ],
                ),
              );
            },
          );
          }
        },
      ),
    );
  }
}
