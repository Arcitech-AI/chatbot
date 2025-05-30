import 'package:chatbot_example/features/new%20chat/service/firestore_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void saveToken(String uid) async {
  final fcm = FirebaseMessaging.instance;
  final token = await fcm.getToken();
  if (token != null) {
    await FirestoreService().saveFcmToken(uid, token);
  }
}

