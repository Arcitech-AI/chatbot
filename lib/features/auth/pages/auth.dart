import 'package:chatbot_example/features/auth/pages/register_login.dart';
import 'package:chatbot_example/features/chat/presentation/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return HomePage();
        }
        return RegisterLoginPage();
      },
    );
  }
}
