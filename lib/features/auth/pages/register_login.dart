import 'package:chatbot_example/features/auth/pages/login_page.dart';
import 'package:chatbot_example/features/auth/pages/register_page.dart';
import 'package:flutter/material.dart';

class RegisterLoginPage extends StatefulWidget {
  RegisterLoginPage({super.key});

  @override
  State<RegisterLoginPage> createState() => _RegisterLoginPageState();
}

class _RegisterLoginPageState extends State<RegisterLoginPage> {    
  bool isLogin = true;

  void togglePage() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(isLogin) {
      return LoginPage(togglePage: togglePage,);
    }
    else {
      return RegisterPage(togglePage: togglePage,);
    }
  }
}