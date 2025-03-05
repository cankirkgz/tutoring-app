import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/messages_controller.dart';
import 'package:tutoring/core/services/notification_service.dart';
import 'package:tutoring/data/models/message_model.dart';
import 'package:tutoring/controllers/auth_controller.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;

  const ChatScreen({Key? key, required this.chatId, required this.receiverId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagesController messagesController = Get.put(MessagesController());
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAndMarkMessagesAsRead();
  }

  void _checkAndMarkMessagesAsRead() async {
    final String? lastSenderId =
        await messagesController.getLastMessageSenderId(widget.chatId);
    if (authController.user!.uid != lastSenderId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messagesController.markMessagesAsRead(widget.chatId);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: authController.getUserById(widget.receiverId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Yükleniyor...');
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Sohbet');
            } else {
              final user = snapshot.data!;
              return Text(
                '${user.firstName} ${user.lastName}',
                style: TextStyle(color: Colors.white),
              );
            }
          },
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                // Profil ekranına yönlendirme
              } else if (value == 'notification') {
                Get.snackbar('Bildirim', 'Bu özellik henüz aktif değil.',
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile Git'),
              ),
              const PopupMenuItem<String>(
                value: 'notification',
                child: Text('Bildir'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: messagesController.getMessages(widget.chatId),
              initialData: const [],
              builder: (context, snapshot) {
                // Eğer hata varsa hata mesajı göster.
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                // İlk yükleme sırasında (veri yoksa) progress indicator veya placeholder gösterebilirsiniz.
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data!.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Eğer veri gelmiş fakat boşsa, placeholder mesajı göster.
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Henüz mesaj yok. İlk mesajı göndererek sohbeti başlatın!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!;

                // Listeyi en son mesaja kaydırma işlemi
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == authController.user!.uid;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey[600],
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          onPressed: () async {
                            final String? token =
                                await NotificationService.instance.getToken();
                            print('LALALALA $token');
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Mesaj yaz...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {
                            // Dosya ekleme işlemi
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final message = _messageController.text.trim();
                        if (message.isNotEmpty) {
                          // Immediately clear the input field and hide keyboard
                          _messageController.clear();
                          FocusScope.of(context).unfocus();

                          // Get user info synchronously
                          final user = authController.user!;
                          final userName = '${user.firstName} ${user.lastName}';

                          // Send message in background
                          messagesController.sendMessage(
                            widget.chatId,
                            message,
                            widget.receiverId,
                          );

                          // Send notification in background
                          authController
                              .getFcmTokenByUserId(widget.receiverId)
                              .then((token) {
                            if (token != null) {
                              NotificationService.instance
                                  .sendTokenNotification(
                                token,
                                userName,
                                message,
                                widget.chatId,
                                widget.receiverId,
                              );
                            }
                          }).catchError((error) {
                            print('Notification error: $error');
                          });
                        }
                      },
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
