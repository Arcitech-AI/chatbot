// abstract class ChatEvent {}

// class SendMessageEvent extends ChatEvent {
//   final String message;
//   SendMessageEvent(this.message);
// }

// class UpdateBotTypingEvent extends ChatEvent {
//   final String partialMessage;
//   final String messageId;

//   UpdateBotTypingEvent({required this.partialMessage, required this.messageId});
// }



abstract class ChatEvent {}

class InitialEvent extends ChatEvent{}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String chatSessionId;

  SendMessageEvent(this.message, this.chatSessionId);
}

class UpdateBotTypingEvent extends ChatEvent {
  final String partialMessage;
  final DateTime messageId;

  UpdateBotTypingEvent({required this.partialMessage, required this.messageId});
}

class EditMessageEvent extends ChatEvent {
  final String chatSessionId;
  final String messageId;
  final String updatedMessage;

  EditMessageEvent({
    required this.chatSessionId,
    required this.messageId,
    required this.updatedMessage,
  });
}