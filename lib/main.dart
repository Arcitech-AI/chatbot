import 'package:chatbot_example/features/auth/bloc/auth_bloc.dart';
import 'package:chatbot_example/features/auth/pages/auth.dart';
import 'package:chatbot_example/features/auth/pages/register_login.dart';
import 'package:chatbot_example/firebase_options.dart';
import 'package:chatbot_example/gemini_api_service.dart';
import 'package:chatbot_example/features/chat/presentation/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/chat_bloc.dart';

import 'package:get_it/get_it.dart';
final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton(() => GeminiApiService());
  sl.registerFactory(() => ChatBloc(sl()));
}
void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Gemini Chat Streaming',
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<ChatBloc>(),),
          BlocProvider(create: (_) => AuthBloc(),),
        ],
        child: AuthPage(),
      ),
    );
  }
}
