import 'package:chatbot_example/bloc/chat_bloc.dart';
import 'package:chatbot_example/bloc/chat_event.dart';
import 'package:chatbot_example/bloc/chat_state.dart';
import 'package:chatbot_example/chat_message.dart';
import 'package:chatbot_example/gemini_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String chatSessionId;

  const ChatPage({Key? key, required this.chatSessionId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc(GeminiApiService());
    _loadChatHistory();
  }

  void _loadChatHistory() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('chat_sessions')
            .doc(widget.chatSessionId)
            .collection('messages')
            .orderBy('timestamp')
            .get();

    final messages =
        snapshot.docs.map((doc) => ChatMessage.fromJson(doc.data())).toList();
    _chatBloc.emit(ChatState(messages));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _chatBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('ChatBot')),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToBottom(),
                  );
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isUser = msg.sender == Sender.user;
                      return Align(
                        alignment:
                            isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    isUser
                                        ? Colors.blue[100]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: MarkdownBody(data: msg.message),
                            ),
                            if (isUser)
                              IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                onPressed: () {
                                  _showEditDialog(
                                    context,
                                    msg,
                                    widget.chatSessionId,
                                    Uuid().v4(),
                                  ); // You need to store messageId
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask something...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        _chatBloc.add(
                          SendMessageEvent(
                            _controller.text.trim(),
                            widget.chatSessionId,
                          ),
                        );
                        _controller.clear();
                      }
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
            // ElevatedButton(
            //   onPressed: _scrollToBottom,
            //   child: const Text("Scroll to Bottom"),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showEditDialog(
    BuildContext context,
    ChatMessage message,
    String chatSessionId,
    String messageId,
  ) {
    final controller = TextEditingController(text: message.message);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Message"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newMessage = controller.text.trim();
                if (newMessage.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('chat_sessions')
                      .doc(chatSessionId)
                      .collection('messages')
                      .doc(messageId)
                      .set({'message': newMessage});
                  Navigator.pop(context);
                  print("@@@ ${widget.chatSessionId}");

                  _chatBloc.add(
                    SendMessageEvent(newMessage.trim(), widget.chatSessionId),
                  );
                  controller.clear();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
