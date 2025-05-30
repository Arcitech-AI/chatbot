// domain/chat_message.dart

enum Sender { user, bot }

class ChatMessage {
  final DateTime timestamp;
  final String message;
  final Sender sender;

  ChatMessage({
    required this.timestamp,
    required this.message,
    required this.sender,
  });

  ChatMessage copyWith({String? message}) {
    return ChatMessage(
      timestamp: timestamp,
      message: message ?? this.message,
      sender: sender,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'isUser': sender == Sender.user ? "user" : "bot" ,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        message: json['message'],
        sender: json['isUser'] == "user" ? Sender.user : Sender.bot,
        timestamp: DateTime.parse(json['timestamp']),
      );
}
