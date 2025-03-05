import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:tutoring/core/services/notification_service.dart';
import 'package:tutoring/data/models/chat_model.dart';
import 'package:tutoring/data/models/message_model.dart';
import 'package:tutoring/controllers/auth_controller.dart';

class MessagesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.find<AuthController>();

  // Kullanıcının tüm sohbetlerini getir
  Stream<List<ChatModel>> getChats() {
    final userId = authController.user!.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatModel.fromJson(doc.data());
      }).toList();
    });
  }

  // Belirli bir sohbetin mesajlarını getir
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromJson(doc.data());
      }).toList();
    });
  }

  // Mesaj gönder
  Future<void> sendMessage(
    String chatId,
    String content,
    String receiverId,
  ) async {
    final userId = authController.user!.uid;
    final message = MessageModel(
      id: _firestore.collection('messages').doc().id,
      chatId: chatId,
      senderId: userId,
      receiverId: receiverId,
      content: content,
      messageType: 'text',
      timestamp: Timestamp.now(),
      isRead: false,
      isEdited: false,
    );

    print(
        "🟢 Mesaj gönderme işlemi başladı. Chat ID: $chatId, Alıcı ID: $receiverId");

    try {
      // 1) Mesajı Firestore'a kaydet
      print("🔵 Mesaj Firestore'a kaydediliyor...");
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toJson());
      print("🟢 Mesaj Firestore'a başarıyla kaydedildi.");

      // 2) Okunmamış mesaj sayacı güncelle
      print("🔵 Okunmamış mesaj sayacı güncelleniyor...");
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': message.timestamp,
        'lastMessageSenderId': userId,
        'unreadMessagesCount': FieldValue.increment(1),
      });
      print("🟢 Okunmamış mesaj sayacı başarıyla güncellendi.");
    } catch (e) {
      print("❌ Mesaj gönderilirken hata oluştu: $e");
      Get.snackbar('Hata', 'Mesaj gönderilirken bir hata oluştu: $e');
    }
  }

  Future<String?> getLastMessageSenderId(String chatId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['lastMessageSenderId'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Son mesajı gönderen kişi ID'si alınırken hata oluştu: $e");
      return null;
    }
  }

  // Yeni bir sohbet başlat
  Future<String?> startNewChat(String receiverId) async {
    final userId = authController.user!.uid;
    final chatId = _firestore.collection('chats').doc().id;

    final chat = ChatModel(
      chatId: chatId,
      participants: [userId, receiverId],
      lastMessage: '',
      lastMessageSenderId: '',
      lastMessageTime: Timestamp.now(),
      unreadMessagesCount: 0,
      lastMessageType: 'text',
    );

    try {
      await _firestore.collection('chats').doc(chatId).set(chat.toJson());
      return chatId;
    } catch (e) {
      print("❌ Sohbet başlatılamadı: $e");
      Get.snackbar('Hata', 'Sohbet başlatılamadı: $e');
      return null;
    }
  }

  Future<String?> getExistingChatId(String receiverId) async {
    final userId = authController.user!.uid;
    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(receiverId)) {
          return doc.id;
        }
      }
      return null;
    } catch (e) {
      print("❌ Mevcut sohbet ID'si alınırken hata oluştu: $e");
      return null;
    }
  }

  // Sohbeti sil
  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).delete();
      Get.snackbar('Başarılı', 'Sohbet başarıyla silindi.');
    } catch (e) {
      print("❌ Sohbet silinirken hata oluştu: $e");
      Get.snackbar('Hata', 'Sohbet silinirken bir hata oluştu: $e');
    }
  }

  // Mesajı sil
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
      Get.snackbar('Başarılı', 'Mesaj başarıyla silindi.');
    } catch (e) {
      print("❌ Mesaj silinirken hata oluştu: $e");
      Get.snackbar('Hata', 'Mesaj silinirken bir hata oluştu: $e');
    }
  }

  // Mesajı güncelle (örneğin, düzenleme işlemi)
  Future<void> updateMessage(
      String chatId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'isEdited': true,
      });
      Get.snackbar('Başarılı', 'Mesaj başarıyla güncellendi.');
    } catch (e) {
      print("❌ Mesaj güncellenirken hata oluştu: $e");
      Get.snackbar('Hata', 'Mesaj güncellenirken bir hata oluştu: $e');
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final String currentUserId = authController.user!.uid;
    WriteBatch batch = _firestore.batch();

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (DocumentSnapshot doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {'unreadMessagesCount': 0});

      await batch.commit();
      print("Mesajlar başarıyla okundu olarak işaretlendi.");
    } catch (e) {
      print("Okundu olarak işaretleme sırasında hata: $e");
    }
  }
}
