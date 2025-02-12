import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSenderId;
  final Timestamp lastMessageTime;
  final int unreadMessagesCount;
  final String lastMessageType;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    this.unreadMessagesCount = 0,
    this.lastMessageType = 'text',
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      lastMessageTime: json['lastMessageTime'] ?? Timestamp.now(),
      unreadMessagesCount: json['unreadMessagesCount'] ?? 0,
      lastMessageType: json['lastMessageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime,
      'unreadMessagesCount': unreadMessagesCount,
      'lastMessageType': lastMessageType,
    };
  }
}
