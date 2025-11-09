import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final _chatsRef = FirebaseFirestore.instance.collection('chats');

  Future<String> getUserName(String userId) async {
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists && userDoc.data()!.containsKey('name')) {
    return userDoc['name'] as String;
  } else {
    return 'Unknown User';
  }
}

  /// Create or get a chat between two users (optionally tied to a swap)
  Future<String> createOrGetChat({
    required String userA,
    required String userB,
    String? swapId,
  }) async {
    final query = await _chatsRef
        .where('participants', arrayContains: userA)
        .get();

    for (final doc in query.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(userB) &&
          (swapId == null || doc['swapId'] == swapId)) {
        return doc.id; // Chat already exists
      }
    }

    final newChat = await _chatsRef.add({
      'participants': [userA, userB],
      'swapId': swapId,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }

  /// Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chatRef = _chatsRef.doc(chatId).collection('messages');
    await chatRef.add({
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _chatsRef.doc(chatId).update({
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Stream user chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _chatsRef
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Chat.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream chat messages
  Stream<List<ChatMessage>> getChatMessages(String chatId) {
    return _chatsRef
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }
}
Future<String> getUserName(String userId) async {
  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists && userDoc.data()!.containsKey('name')) {
    return userDoc['name'] as String;
  } else {
    return 'Unknown User';
  }
}