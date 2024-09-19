
import 'package:animate_do/animate_do.dart';
import 'package:chats/auth/authService.dart';
import 'package:chats/common/inputField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthScreen extends StatefulWidget {
  static String? ifUserId = "";

  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final signUpConfirmPasswordController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();

  var isLogin = false.obs;

  void signUp(){
    if(signUpPasswordController.text!=signUpConfirmPasswordController.text){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password do not match!')));
    }
    AuthService().signUpWithEmailPassword(signUpEmailController.text,signUpPasswordController.text);
  }

  void signIn() async {
    try {
      await AuthService().signInWithEmailPassword(
          emailController.text, passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Error: ${e.toString()}')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 400,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/background.png'),
                              fit: BoxFit.fill
                          )
                      ),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 30,
                            width: 80,
                            height: 200,
                            child: FadeInUp(duration: const Duration(seconds: 1),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/light-1.png')
                                      )
                                  ),
                                )),
                          ),
                          Positioned(
                            left: 140,
                            width: 80,
                            height: 150,
                            child: FadeInUp(duration: const Duration(
                                milliseconds: 1200), child: Container(
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-2.png')
                                  )
                              ),
                            )),
                          ),
                          Positioned(
                            right: 40,
                            top: 40,
                            width: 80,
                            height: 150,
                            child: FadeInUp(duration: const Duration(
                                milliseconds: 1300), child: Container(
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/clock.png')
                                  )
                              ),
                            )),
                          ),
                          Positioned(
                            child: FadeInUp(duration: const Duration(
                                milliseconds: 1600), child: Container(
                              margin: const EdgeInsets.only(top: 50),
                              child: Center(
                                child: Text(isLogin.value ? "Sign Up" : "Login",
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold)),
                              ),
                            )),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: <Widget>[
                          FadeInUp(duration: const Duration(milliseconds: 1800),
                              child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color.fromRGBO(
                                          143, 148, 251, 1)),
                                      boxShadow: [
                                        const BoxShadow(
                                            color: Color.fromRGBO(
                                                143, 148, 251, .2),
                                            blurRadius: 20.0,
                                            offset: Offset(0, 10)
                                        )
                                      ]
                                  ),
                                  child: isLogin.value ?
                                  Column(
                                    children: <Widget>[
                                      InputTextFieldWidget(
                                          signUpEmailController,
                                          'Enter Your Email Address'),
                                      InputTextFieldWidget(
                                          signUpPasswordController,
                                          'Enter Your Password'),
                                      InputTextFieldWidget(
                                          signUpConfirmPasswordController,
                                          'Enter Your Confirm Password'),

                                    ],
                                  ).marginSymmetric(horizontal: 10) :
                                  Column(
                                    children: <Widget>[
                                      InputTextFieldWidget(
                                           emailController,
                                          'Enter Your Email Address'),
                                      InputTextFieldWidget(
                                           passwordController,
                                          'Enter Your Password'),

                                    ],
                                  ).marginSymmetric(horizontal: 10)
                              )),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () {isLogin.value ?
                            signUp()
                            :signIn();

                              // AuthService().signInWithEmailPassword(emailController.text,passwordController.text);
                              print('login or sign up ');
                            },
                            child: FadeInUp(duration: const Duration(
                                milliseconds: 1900), child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                      colors: [
                                        Color.fromRGBO(143, 148, 251, 1),
                                        Color.fromRGBO(143, 148, 251, .6),
                                      ]
                                  )
                              ),
                              child: Center(
                                child: Text(isLogin.value
                                    ? "Create New Account"
                                    : "Login", style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),),
                              ),
                            )),
                          ),
                          const SizedBox(height: 70,),
                          FadeInUp(duration: const Duration(milliseconds: 2000),
                              child: InkWell(
                                  onTap: () {
                                    isLogin.value = !isLogin.value;
                                  },
                                  child: Text(isLogin.value
                                      ? "Login"
                                      : "Create New Account", style: const TextStyle(
                                      color: Color.fromRGBO(
                                          143, 148, 251, 1)),))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
        ),
    );
  }}

