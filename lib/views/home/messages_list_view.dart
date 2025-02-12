import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tutoring/controllers/messages_controller.dart';
import 'package:tutoring/data/models/chat_model.dart';
import 'package:tutoring/views/home/chat_screen.dart';
import 'package:tutoring/controllers/auth_controller.dart';
import 'package:tutoring/data/models/user_model.dart';

class MessagesListView extends StatelessWidget {
  final MessagesController messagesController = Get.put(MessagesController());
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mesajlar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: messagesController.getChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade700,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Hata: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz mesaj yok.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: chats.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final receiverId = chat.participants
                  .firstWhere((id) => id != authController.user!.uid);

              return FutureBuilder<UserModel?>(
                future: authController.getUserById(receiverId),
                builder: (context, userSnapshot) {
                  Widget chatItem;
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    chatItem = _buildChatItemShimmer();
                  } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                    chatItem = _buildChatItem(
                      name: 'Bilinmeyen Kullanıcı',
                      lastMessage: chat.lastMessage,
                      time: chat.lastMessageTime.toDate(),
                      unreadCount: chat.unreadMessagesCount,
                      lastMessageSenderId: chat.lastMessageSenderId,
                      onTap: () {
                        Get.to(() => ChatScreen(
                              chatId: chat.chatId,
                              receiverId: receiverId,
                            ));
                      },
                    );
                  } else {
                    final user = userSnapshot.data!;
                    chatItem = _buildChatItem(
                      name: '${user.firstName} ${user.lastName}',
                      lastMessage: chat.lastMessage,
                      time: chat.lastMessageTime.toDate(),
                      unreadCount: chat.unreadMessagesCount,
                      lastMessageSenderId: chat.lastMessageSenderId,
                      onTap: () {
                        Get.to(() => ChatScreen(
                              chatId: chat.chatId,
                              receiverId: receiverId,
                            ));
                      },
                    );
                  }

                  // Long press ile sohbeti silme işlemi
                  return GestureDetector(
                    onLongPress: () {
                      Get.defaultDialog(
                        title: "Sohbeti Sil",
                        middleText: "Sohbeti silmek istediğinize emin misiniz?",
                        textConfirm: "Eminim",
                        textCancel: "İptal",
                        confirmTextColor: Colors.white,
                        // Async yapmadan, silme işlemi çağrıldıktan hemen sonra dialogu kapatıyoruz.
                        onConfirm: () {
                          messagesController.deleteChat(chat.chatId);
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }
                        },
                        onCancel: () {
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }
                        },
                      );
                    },
                    child: chatItem,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatItem({
    required String name,
    required String lastMessage,
    required DateTime time,
    required VoidCallback onTap,
    required int unreadCount,
    required String lastMessageSenderId,
  }) {
    final isMyMessage = lastMessageSenderId == authController.user!.uid;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Kullanıcı avatarı
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade100,
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.green.shade700,
              ),
            ),
            SizedBox(width: 16),
            // Mesaj bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Zaman ve okunmamış sayaç
            Column(
              children: [
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (!isMyMessage && unreadCount > 0) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItemShimmer() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}g';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}sa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}d';
    } else {
      return 'Az önce';
    }
  }
}
