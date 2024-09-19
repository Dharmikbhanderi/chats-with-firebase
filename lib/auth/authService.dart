import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmailPassword(String email,String password) async {
    print('signInWithEmailPassword is ------->>>>>>>>>>> 11');

    try {
      print('signInWithEmailPassword is ------->>>>>>>>>>> 222');

      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      _firestore.collection('users').doc(userCredential.user?.uid).set({

        'uid':userCredential.user?.uid,
        'email':email
      },SetOptions(merge: true));
      return userCredential;

    } on FirebaseAuthException catch (e) {
      throw Exception('errroee is ------->>>>>>>>>>> ${e.code}');
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email,String password) async {
    try{
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      _firestore.collection('users').doc(userCredential.user?.uid).set({
        'uid':userCredential.user?.uid,
        'email':email
      });
      return userCredential;
    }on FirebaseAuthException catch (e) {
      throw Exception('Exception ---->>>> ${e.code}');
    }
  }

  Future<void> signOut() async {
      return await FirebaseAuth.instance.signOut();
  }
}