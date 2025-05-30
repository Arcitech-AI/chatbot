import 'package:chatbot_example/chat_message.dart';
import 'package:chatbot_example/gemini_api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GeminiApiService apiService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userQuestion;
  ChatBloc(this.apiService) : super(ChatState([])) {
    on<SendMessageEvent>(_onSendMessage);
    on<UpdateBotTypingEvent>(_onUpdateBotTyping);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    userQuestion = event.message;
    final userMsg = ChatMessage(
      timestamp: Timestamp.now().toDate(),
      message: event.message,
      sender: Sender.user,
    );
    await _saveMessage(userMsg, event.chatSessionId);

    var botMessageContent = '';
    final botMsgId = Timestamp.now().toDate();
    final botTypingPlaceholder = ChatMessage(
      timestamp: botMsgId,
      message: '',
      sender: Sender.bot,
    );

    final updated = [...state.messages, userMsg, botTypingPlaceholder];
    emit(ChatState(updated));

    await for (final chunk in apiService.streamBotReply(event.message)) {
      botMessageContent = chunk;
      add(UpdateBotTypingEvent(partialMessage: chunk, messageId: botMsgId));
    }

    final finalBotMessage = ChatMessage(
      timestamp: botMsgId,
      message: botMessageContent,
      sender: Sender.bot,
    );
    await _saveMessage(finalBotMessage, event.chatSessionId);
  }

  Future<void> _saveMessage(ChatMessage message, String chatSessionId) async {
    await FirebaseFirestore.instance
        .collection('chat_sessions')
        .doc(chatSessionId.substring(0, 8))
        .set({'title': userQuestion, 'timestamp': Timestamp.now()});
    await _firestore
        .collection('chat_sessions')
        .doc(chatSessionId.substring(0, 8))
        .collection('messages')
        .add(message.toJson());
  }

  void _onUpdateBotTyping(UpdateBotTypingEvent event, Emitter<ChatState> emit) {
    final updatedMessages =
        state.messages.map((msg) {
          if (msg.timestamp == event.messageId) {
            return msg.copyWith(message: event.partialMessage);
          }
          return msg;
        }).toList();

    emit(ChatState(updatedMessages));
  }
}
