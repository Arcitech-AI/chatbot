import 'package:chatbot_example/features/chat/model/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllUsers extends StatelessWidget {
  AllUsers({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;
  Future<void> sendFriendRequest(String toUserId, String fromName) async {
    if (currentUser == null) return;

    final fromUserId = currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(toUserId)
        .collection('friendRequests')
        .doc(fromUserId)
        .set({
          'fromUserId': fromUserId,
          'timestamp': FieldValue.serverTimestamp(),
          'name': fromName,
        });
  }

  Stream<List<AppUser>> getAllUsers() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => AppUser(
                      uid: doc['uid'],
                      name: doc['name'],
                      email: doc['email'],
                    ),
                  )
                  .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Users")),
      body: StreamBuilder<List<AppUser>>(
        stream: getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          final requestIds = snapshot.data!;

          if (requestIds.isEmpty) {
            return Center(child: Text("No requests"));
          }

          return ListView.builder(
            itemCount: requestIds.length,
            itemBuilder: (context, index) {
              final fromUserId = requestIds[index].name;
              if (currentUser!.uid != requestIds[index].uid) {
                return ListTile(
                  title: Text(
                    fromUserId,
                  ), // You can fetch name using another query
                  trailing: ElevatedButton(
                    onPressed: () async {
                      DocumentSnapshot toUserName =
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser!.uid)
                              .get();
                      final name = toUserName['name'];
                      sendFriendRequest(requestIds[index].uid, name);
                    },
                    child: Text("Add Friend"),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
