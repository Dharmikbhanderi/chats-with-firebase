import 'package:chats/home/home.dart';
import 'package:chats/login%20screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGet extends StatelessWidget {
  const AuthGet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream:  FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
        print('object stream error --->>>> ${snapshot.error}');
        print('object stream data --->>>> ${snapshot.data}');
            if(snapshot.hasData){
              return HomeScreen(email: snapshot.data?.email,);
            }else{
              return AuthScreen();
            }
          },),
    );
  }
}
