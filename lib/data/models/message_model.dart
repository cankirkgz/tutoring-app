import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final String? fileUrl;
  final String messageType;
  final Timestamp timestamp;
  final bool isRead;
  final bool isEdited;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.fileUrl,
    required this.messageType,
    required this.timestamp,
    this.isRead = false,
    this.isEdited = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      fileUrl: json['fileUrl'],
      messageType: json['messageType'] ?? 'text',
      timestamp: json['timestamp'] ?? Timestamp.now(),
      isRead: json['isRead'] ?? false,
      isEdited: json['isEdited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'fileUrl': fileUrl,
      'messageType': messageType,
      'timestamp': timestamp,
      'isRead': isRead,
      'isEdited': isEdited,
    };
  }
}
