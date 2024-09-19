import 'package:chats/common/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage1(String receiverId, String message) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final String currentUserId = currentUser.uid;
        final String currentUserEmail = currentUser.email ?? '';
        final Timestamp timestamp = Timestamp.now();

        final Map<String, dynamic> messageData = {
          'senderId': currentUserId,
          'senderEmail': currentUserEmail,
          'receiverId': receiverId,
          'message': message,
          'timestamp': timestamp,
        };

        final List<String> ids = [currentUserId, receiverId];
        ids.sort();
        final String chatRoomId = ids.join('_');
        await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .add(messageData);
      }


    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        final String currentUserId = currentUser.uid;
        final String currentUserEmail = currentUser.email ?? '';
        final Timestamp timestamp = Timestamp.now();

        final Map<String, dynamic> messageData = {
          'senderId': currentUserId,
          'senderEmail': currentUserEmail,
          'receiverId': receiverId,
          'message': message,
          'timestamp': timestamp,
          'isSeen': false,
        };

        final List<String> ids = [currentUserId, receiverId];
        ids.sort();
        final String chatRoomId = ids.join('_');

        // Add the message to the messages collection
        await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .add(messageData);

        // Update the unread count for the receiver
        final DocumentReference unreadCountRef = _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('unread_counts')
            .doc(receiverId);

        await _firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(unreadCountRef);

          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            int newCount = (data['count'] ?? 0) + 1;
            transaction.update(unreadCountRef, {'count': newCount});
          } else {
            transaction.set(unreadCountRef, {'count': 1});
          }
        });
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp',descending: false)
        .snapshots();
  }

  Future<void> removeData(
      String receiverId, DocumentSnapshot? messageSnapshot) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");
    _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageSnapshot?.id)
        .delete();
    print('Data removed from FirebaseFirestore successfully!');
  }
}
