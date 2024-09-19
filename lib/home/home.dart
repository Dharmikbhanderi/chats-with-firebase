import 'package:chats/auth/authService.dart';
import 'package:chats/chat%20page/chatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  String? email;

    HomeScreen({Key? key, this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade100,
        title: Text(widget.email.toString(),style: TextStyle(fontSize: 20,color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: (){
              AuthService().signOut();
              }, icon: const Icon(Icons.login_outlined))
        ],
      ),
      body:buildUserList(),
    );
  }

  Widget buildUserList() {
    return StreamBuilder(stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return const Text('error');
          }
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children: snapshot.data!.docs.map<Widget>((doc)=>buildListItem(doc)).toList(),
          );
        },
    );
  }

  Widget buildListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    final currentUserId = _auth.currentUser!.uid;
    if (_auth.currentUser?.email != data['email']) {
      // Generate chat room ID
      final List<String> ids = [currentUserId, data['uid']];
      ids.sort();
      final String chatRoomId = ids.join('_');

      return StreamBuilder(
        stream: _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('unread_counts')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          int unreadCount = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            unreadCount = snapshot.data!['count'];
          }
          print('object ----->>>>>> ${unreadCount.toString()}');
          return ListTile(
            title: Text(data['email']),
            trailing: unreadCount > 0
                ? CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Text(
                unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
                : null,
            onTap: () {
              _firestore
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('unread_counts')
                  .doc(currentUserId)
                  .set({'count': 0});
              Get.to(() => ChatPage(
                  receiverUserEmail: data['email'], receiverUserId: data['uid']));
            },
          );
        },
      );
    } else {
      return Container();
    }
 /*   if (_auth.currentUser?.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        trailing: FutureBuilder<int>(
          future: getUnreadMessageCount(data['uid']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              int unreadCount = snapshot.data ?? 0;
              return unreadCount > 0
                  ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
                  : SizedBox.shrink();
            }
          },
        ),
        onTap: () {
          Get.to(() => ChatPage(
              receiverUserEmail: data['email'], receiverUserId: data['uid']));
        },
      );
    } else {
      return Container();
    }*/
  }
  Future<int> getUnreadMessageCount(String receiverUserId) async {
    final QuerySnapshot unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(_auth.currentUser!.uid)
        .collection(receiverUserId)
        .where('isRead', isEqualTo: false)
        .where('senderId', isEqualTo: receiverUserId)
        .get();

    return unreadMessages.docs.length;
  }
}
