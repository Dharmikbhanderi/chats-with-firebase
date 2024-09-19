import 'package:chats/chat/chat_service.dart';
import 'package:chats/common/chatBubble.dart';
import 'package:chats/common/inputField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController =
      ScrollController(); // ScrollController
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    final chatRoomId = getChatRoomId(widget.receiverUserId, _firebaseAuth.currentUser!.uid);
    markMessagesAsSeen(chatRoomId);
  }

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Sort the IDs to ensure the same chat room ID is generated
    return ids.join('_'); // Concatenate the IDs with an underscore
  }

  void markMessagesAsSeen(String chatRoomId) {
    final messages = _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages');

    messages.where('isSeen', isEqualTo: false).get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.update({'isSeen': true});
      }
    });
  }
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserId, _messageController.text);
      _scrollToBottom();
    }
    _messageController.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        centerTitle: true,
      ),
      body: Column(
        children: [Expanded(child: messageList()), messageTextField()],
      ),
    );
  }

  Future<void> markMessagesAsSeen123(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    QuerySnapshot snapshot = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .where('isSeen', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(doc.id)
          .update({'isSeen': true});
    }
  }

  Widget messageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserId, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('on has error ===>>>>>>> ${snapshot.hasError}');
            return Text('Error ${snapshot.hasError}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            print(
                'on has connectionState ===>>>>>>> ${snapshot.connectionState}');

            return const Text('Loading.....');
          }
          print('on snapshot isss  ===>>>>>>> ');

          List<DocumentSnapshot> docs = snapshot.data!.docs;
          Map<String, List<DocumentSnapshot>> groupedMessages = {};

          // Group messages by date
          for (var doc in docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp;
            DateTime date = timestamp.toDate();
            String formattedDate = DateFormat('yyyy-MM-dd').format(date);

            if (groupedMessages.containsKey(formattedDate)) {
              groupedMessages[formattedDate]!.add(doc);
            } else {
              groupedMessages[formattedDate] = [doc];
            }
          }

          // Convert the grouped messages into a list of widgets
          List<Widget> messageWidgets = [];
          groupedMessages.forEach((date, messages) {
            DateTime dateTime = DateTime.parse(date);
            String dateLabel = _getDateLabel(dateTime);
            messageWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    dateLabel,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );

            for (var message in messages) {
              messageWidgets.add(messageItem(message));
            }
          });

          // Scroll to bottom when messages are loaded
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());

          return ListView(
            controller: _scrollController,
            children: messageWidgets,
          );

          // return ListView(
          //   children: snapshot.data!.docs.map((document) => messageItem(document)).toList(),
          // );
        });
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return "Today";
    } else if (date.isAtSameMomentAs(yesterday)) {
      return "Yesterday";
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  Widget messageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrent =
        (data['senderId'] == _firebaseAuth.currentUser?.uid) ? true : false;
    bool isCurrent1 = (data['senderId'] == _firebaseAuth.currentUser?.uid);
    var alignment =
        isCurrent == true ? Alignment.centerRight : Alignment.centerLeft;
    final timestamp = data['timestamp'] as Timestamp;
    bool isSeen = data['isSeen'] ?? false;
    print('on senderEmail  ===>>>>>>> ${data['senderEmail']}');
    if (kDebugMode) {
      print('on senderID  ===>>>>>>> ${data['senderId']}');
    }
    print('on message  ===>>>>>>> ${data['message']}');
    print('on Timestamp  ===>>>>>>> ${data['timestamp'].toString()}');

    return InkWell(
      onLongPress: () {
        print('on messageBox click=========>>>>${data['id'].toString()}');
        isCurrent == true
            ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Delete Message"),
                    content: const Text(
                        "Are you sure you want to delete this message?"),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("Delete"),
                        onPressed: () {
                          // Perform delete action here
                          _chatService.removeData(
                              widget.receiverUserId, document);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              )
            : Offstage();

        // removeData(data['id'].toString());
        print('on after messageBox click=========>>>>${data['senderId']}');
      },
      child: Container(
        alignment: alignment,
        child: Column(
          mainAxisAlignment: isCurrent == true
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: isCurrent == true
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              text: data['message'],
              isCurrentUser: isCurrent,
              timestamp: timestamp,
              isSeen: isSeen,
            ),
            isCurrent1?
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.check,
                color: isSeen ? Colors.green : Colors.red,
              ),
            ):const Offstage(),
          ],
        ),
      ),
    );
  }

  Widget messageTextField() {
    return Row(
      children: [
        Expanded(
          child: InputTextFieldWidget(_messageController, 'Enter Message',
              onTap: _scrollToBottom
              ),
        ),
        IconButton(
            onPressed: () {
              sendMessage();
            },
            icon: const Icon(Icons.send))
      ],
    );
  }
}
