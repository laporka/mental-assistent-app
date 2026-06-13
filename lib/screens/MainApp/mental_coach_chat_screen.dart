import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/typing_indicator.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


final ValueNotifier<String?> globalChatMessageNotifier = ValueNotifier(null);

class MentalCoachChatScreen extends StatefulWidget {
  const MentalCoachChatScreen({super.key});

  @override
  State<MentalCoachChatScreen> createState() => _MentalCoachChatScreenState();
}

class _MentalCoachChatScreenState extends State<MentalCoachChatScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false;

  Stream<QuerySnapshot>? _chatStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    if (uid != null) {
      _chatStream = FirebaseFirestore.instance
          .collection('users').doc(uid).collection('coach_chat')
          .orderBy('timestamp', descending: true)
          .snapshots();
    }

    globalChatMessageNotifier.addListener(_onGlobalMessageReceived);
    
    if (globalChatMessageNotifier.value != null) {
      _onGlobalMessageReceived();
    }
  }

  void _onGlobalMessageReceived() {
    final msg = globalChatMessageNotifier.value;
    if (msg != null && msg.isNotEmpty) {
      _messageController.text = msg;
      globalChatMessageNotifier.value = null;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage();
      });
    }
  }

  @override
  void dispose() {
    globalChatMessageNotifier.removeListener(_onGlobalMessageReceived);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || uid == null) return;

    _messageController.clear();

    final newMessageRef = await FirebaseFirestore.instance.collection('users').doc(uid).collection('coach_chat').add({
      'text': text,
      'isUser': true,
      'timestamp': Timestamp.now(),
    });

    setState(() => _isLoading = true);

    try {
      const storage = FlutterSecureStorage();
      String? userApiKey = await storage.read(key: 'gemini_api_key');

      final historySnapshot = await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('coach_chat')
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();

      List<Map<String, dynamic>> chatHistory = [];
      
      for (var doc in historySnapshot.docs.reversed) {
        if (doc.id == newMessageRef.id) continue;
        
        final data = doc.data();
        chatHistory.add({
          "role": data['isUser'] == true ? "user" : "model",
          "parts": [{"text": data['text'] ?? ""}]
        });
      }

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('chatWithMentalCoach');
      final result = await callable.call({
        'text': text,
        'history': chatHistory,
        'apiKey': userApiKey,
      });
      
      final aiResponse = result.data['response'];

      await FirebaseFirestore.instance.collection('users').doc(uid).collection('coach_chat').add({
        'text': aiResponse,
        'isUser': false,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка з\'єднання: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFF041219),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(84),
        child: Container(
          padding: const EdgeInsets.only(top: 40, bottom: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF041319),
            border: Border(bottom: BorderSide(color: Color(0xFF1D2A30), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 48), 
              const Expanded(
                child: Center(
                  child: Text('Розмова', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans')),
                ),
              ),
              IconButton(
                icon: const Text('?', style: TextStyle(color: Color(0xFFF9FFFA), fontSize: 24, fontFamily: 'Tenor Sans')),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF041219),
              border: Border(bottom: BorderSide(color: Color(0xFF1D2A30), width: 1)),
            ),
            alignment: Alignment.center,
            child: Text(
              DateFormat('dd.MM.yyyy').format(DateTime.now()),
              style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300),
            ),
          ),

          Expanded(
            child: uid == null || _chatStream == null
                ? const Center(child: Text('Помилка авторизації'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _chatStream, 
                    builder: (context, snapshot) {
                      
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF2BBBFF)));
                      }

                      final messages = snapshot.data?.docs ?? [];

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoading && index == 0) {
                            return _buildAIMessageBubble(null, isTyping: true);
                          }

                          final msgIndex = _isLoading ? index - 1 : index;
                          final data = messages[msgIndex].data() as Map<String, dynamic>;
                          final text = data['text'] ?? '';
                          final isUser = data['isUser'] ?? true;
                          final timestamp = data['timestamp'] as Timestamp?;
                          final timeString = timestamp != null 
                              ? DateFormat('HH:mm').format(timestamp.toDate()) 
                              : DateFormat('HH:mm').format(DateTime.now());

                          return isUser 
                              ? _buildUserMessageBubble(text, timeString) 
                              : _buildAIMessageBubble(text, timeString: timeString);
                        },
                      );
                    },
                  ),
          ),

          Container(
            padding: const EdgeInsets.only(left: 36, right: 36, top: 16, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x00041319), Color(0xFF041319)],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FFFA),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Color(0xFF041219), fontSize: 16, fontFamily: 'Inter'),
                      decoration: const InputDecoration(
                        hintText: 'Напиши ...',
                        hintStyle: TextStyle(color: Color(0xFFBCC4C2), fontSize: 16, fontFamily: 'Inter'),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const Icon(Icons.send_rounded, color: Color(0xFFBCC4C2), size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessageBubble(String text, String time) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1D2A30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', height: 1.3)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
          ],
        ),
      ),
    );
  }

  Widget _buildAIMessageBubble(String? text, {String timeString = '', bool isTyping = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 2,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Color(0xFF2BBBFF), Color(0xFF91FFA3)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16, right: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isTyping 
                        ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: TypingIndicator())
                        : MarkdownBody(
                            data: text ?? '',
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', height: 1.3),
                              strong: const TextStyle(color: Color(0xFFF9FFFA), fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                              listBullet: const TextStyle(color: Color(0xFF2BBBFF), fontSize: 16),
                              listIndent: 20,
                              blockSpacing: 8,
                            ),
                          ),
                    if (!isTyping) ...[
                      const SizedBox(height: 4),
                      Text(timeString, style: const TextStyle(color: Color(0xFFBCC4C2), fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w300)),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}