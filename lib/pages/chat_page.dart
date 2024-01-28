import 'package:chatapp_flutter/components/chat_bubble.dart';
import 'package:chatapp_flutter/components/my_text_field.dart';
import 'package:chatapp_flutter/services/chat/chat_service.dart';
import 'package:chatapp_flutter/services/timestamp_conversion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String recieverUserEmail;
  final String recieverUserId;
  const ChatPage(
      {super.key,
      required this.recieverUserEmail,
      required this.recieverUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    //send message if controller is not empty
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.recieverUserId, _messageController.text);
    }
    //clear the controller
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recieverUserEmail,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput()
          ],
        ),
      ),
    );
  }

  //message list

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessage(
          widget.recieverUserId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: " + snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        return ListView(
            children: snapshot.data!.docs
                .map(
                  (document) => _buildMessageItem(document),
                )
                .toList());
      },
    );
  }

  //message item

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    Timestamp timestamp = data["timestamp"];
    DateTime date = timestamp.toDate();
    String hrsMin = timestampToHrsMin(date);

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [ChatBubble(message: data['message']), Text(hrsMin)],
      ),
    );
  }

  //message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: MyTextField(
              controller: _messageController,
              hintText: "Enter a Message",
              obscureText: false),
        ),
        IconButton(
          onPressed: sendMessage,
          icon: const Icon(
            Icons.send,
            size: 40,
          ),
        )
      ],
    );
  }
}
