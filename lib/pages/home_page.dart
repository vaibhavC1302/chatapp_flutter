import 'package:chatapp_flutter/pages/chat_page.dart';
import 'package:chatapp_flutter/services/auth/auth_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void signOut() {
    final authServide = Provider.of<AuthService>(context, listen: false);
    authServide.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const Text("has error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("loading ....");
        }

        return ListView(
          children: snapshot.data!.docs
              .map(
                (doc) => _buildUserListItem(doc),
              )
              .toList(),
        );
      }),
    );
  }

  //building indivisual list items
  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    //display all users except current user
    if (_auth.currentUser!.email != data["email"]) {
      return ListTile(
          title: Text(data["email"]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  recieverUserEmail: data["email"],
                  recieverUserId: data["uid"],
                ),
              ),
            );
          });
    } else {
      return Container();
    }
  }
}
