// import 'package:chatbot_example/features/chat/model/app_user.dart';
import 'package:chatbot_example/features/chat/presentation/chat_history_page.dart';
import 'package:chatbot_example/features/new%20chat/models/user_model.dart';
import 'package:chatbot_example/features/new%20chat/screen/chat_home.dart';
import 'package:chatbot_example/features/new%20chat/screen/chat_screen.dart';
import 'package:chatbot_example/features/new%20chat/screen/friend_requests_screen.dart';
import 'package:chatbot_example/features/new%20chat/screen/frient_request_sent_screen.dart';
import 'package:chatbot_example/features/new%20chat/screen/home_screen.dart';
import 'package:chatbot_example/features/new%20chat/service/firestore_service.dart';
import 'package:chatbot_example/features/new%20chat/widget/user_tile.dart';
import 'package:chatbot_example/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final uuid = const Uuid();
  var currentUserName = "";
  final FirestoreService firestore = FirestoreService();
  final currentUser = FirebaseAuth.instance.currentUser;
  final users = FirebaseFirestore.instance.collection("users");

  @override
  void initState() {
    getUserName();
    super.initState();
  }

  Future<void> getUserName() async {
    DocumentSnapshot docRef = await users.doc(currentUser!.uid).get();
    setState(() {
      currentUserName = docRef.get('name');
    });
    // return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello, $currentUserName",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Home", style: TextStyle()),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                final newSessionId = uuid.v4();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(chatSessionId: newSessionId),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("New Bot Chat"),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatHistoryPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Chat History"),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HomeScreen1(currentUid: currentUser!.uid),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("All Users"),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            FriendRequestsScreen(currentUid: currentUser!.uid),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Friend Requests"),
              ),
            ),
            GestureDetector(
              // onTap: () {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder:
              //           (context) => FrientRequestSentScreen(
              //             currentUid: currentUser!.uid,
              //           ),
              //     ),
              //   );
              // },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Requests sent"),
              ),
            ),
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("Sign out"),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: firestore.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final allUsers = snapshot.data!;
          final currentUsers = allUsers.firstWhere(
            (u) => u.uid == currentUser!.uid,
          );

          final friendList =
              allUsers
                  .where((u) => currentUsers.friends.contains(u.uid))
                  .toList();

          if (friendList.isEmpty) {        
            return Center(
              child: Text("No friends yet. Accept or send requests!"),
            );
          }

          return ListView.builder(
            itemCount: friendList.length,
            itemBuilder: (context, index) {
              final friend = friendList[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatScreen1(
                            currentUid: currentUser!.uid,
                            friendUid: friend.uid,
                          ),
                    ),
                  );
                },
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen1(
                                currentUid: currentUser!.uid,
                                friendUid: friend.uid,
                              ),
                        ),
                      ),
                  child: UserTile(
                    // email: friend.email,
                    actionLabel: 'Chat',
                    name: friend.name,
                    // onTap: () {},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
