import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

// Chat service provider
final chatServiceProvider = Provider((ref) => ChatService());

Stream<List<ChatMessage>> getUserChats(String userId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: userId)
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .map((query) => query.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList());
}
