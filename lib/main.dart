import 'package:chats/auth/auth_get.dart';
import 'package:chats/login%20screen/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyA-XFKY6Lgcgq_F5Vmumyazm6YkwegKL4U",
      appId: "1:1089761737892",
      messagingSenderId: "",
      projectId: "chats-df2e3",
    ),
  );
  runApp(  MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home:   AuthGet(),
    );
  }
}