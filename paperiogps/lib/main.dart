import 'package:flutter/material.dart';
import 'package:paperiogps/screen/login_signup.dart';

void main() {
  runApp(LoginSignupUI());
}

class LoginSignupUI extends StatelessWidget {
  LoginSignupUI({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login Signup UI",
      home: LoginSignupScreen(),
    );
  }
}
