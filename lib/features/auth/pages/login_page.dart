import 'package:chatbot_example/features/auth/bloc/auth_bloc.dart';
import 'package:chatbot_example/features/auth/bloc/auth_event.dart';
import 'package:chatbot_example/features/auth/bloc/auth_state.dart';
import 'package:chatbot_example/features/chat/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  void Function() togglePage;
  LoginPage({super.key, required this.togglePage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() {
    context.read<AuthBloc>().add(AuthLoginUserEvent(emailController.text, passwordController.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch(state.runtimeType) {
          case AuthLoginSuccess:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            break;
          case AuthLoginFailed:
            final loginstate = state as AuthLoginFailed;
            showDialog(context: context, builder: (context) => AlertDialog(content: Text(loginstate.msg),));
        }
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login Page",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Email",
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Password",
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {login();},
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have account? "),
                    GestureDetector(
                      onTap: widget.togglePage,
                      child: Text(
                        "Register Now",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
