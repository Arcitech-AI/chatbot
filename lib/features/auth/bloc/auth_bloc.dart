import 'package:chatbot_example/features/new%20chat/service/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance.collection("users");
  final fcm = FirebaseMessaging.instance;

  AuthBloc() : super(AuthInitialState()) {
    on<AuthRegisterUserEvent>(authRegisterUserEvent);
    on<AuthLoginUserEvent>(authLoginUserEvent);
  }

  Future<void> authRegisterUserEvent(
    AuthRegisterUserEvent event,
    Emitter emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      await _firestore.doc(user.user!.uid).set({
        'uid': user.user!.uid,
        'email': event.email,
        'name': event.name,
      });

      final token = await fcm.getToken();
      if (token != null) {
        await FirestoreService().saveFcmToken(user.user!.uid, token);
      }

      emit(AuthRegistrationSucccess());
    } catch (e) {
      emit(AuthRegistrationFailed("Registratin Failed : $e"));
    }
  }

  Future<void> authLoginUserEvent(
    AuthLoginUserEvent event,
    Emitter emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final token = await fcm.getToken();
      if (token != null) {
        await FirestoreService().saveFcmToken(user.user!.uid, token);
      }

      emit(AuthLoginSuccess());
    } catch (e) {
      emit(AuthLoginFailed("Login Failed : $e"));
    }
  }

  void saveToken(String uid) async {
    final fcm = FirebaseMessaging.instance;
    final token = await fcm.getToken();
    if (token != null) {
      await FirestoreService().saveFcmToken(uid, token);
    }
  }
}
