import 'package:chatbot_example/features/chat/model/app_user.dart';
import 'package:chatbot_example/features/new%20chat/service/firestore_service.dart';
import 'package:flutter/material.dart';

class FrientRequestSentScreen extends StatelessWidget {
  FrientRequestSentScreen({super.key, required this.currentUid});

  final String currentUid;
  final FirestoreService firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Request Sent"),),
      body: StreamBuilder(
          stream: firestore.getAllUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
      
            final allUsers = snapshot.data!;
            final currentUser = allUsers.firstWhere((u) => u.uid == currentUid);
            final senders =
                allUsers
                    .where((u) => currentUser.sentRequests.contains(u.uid))
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
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(sender.name),
                      Spacer(),
                      // ElevatedButton(onPressed: () {firestore.acceptFriendRequest(currentUid, sender.uid);}, child: Text("Accept")),
                      ElevatedButton(onPressed: () {firestore.revokeSentRequest(sender.uid, currentUid);}, child: Text("Revoke Request")),
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