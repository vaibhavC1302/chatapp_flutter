import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // instance of firebase auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firebaseFirestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //signin
  Future<UserCredential> signinWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      //add document if it dosent already exists
      _fireStore.collection('users').doc(userCredential.user!.uid).set(
          {"uid": userCredential.user!.uid, "email": email},
          SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //create a new user
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //create document for the user
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "email": email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //signout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
