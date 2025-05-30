import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime timestamp;

  ChatSession({
    required this.id,
    required this.title,
    required this.timestamp,
  });

  factory ChatSession.fromMap(String id, Map<String, dynamic> data) {
    return ChatSession(
      id: id,
      title: data['title'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
