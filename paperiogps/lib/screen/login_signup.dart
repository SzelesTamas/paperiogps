import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:paperiogps/config/palette.dart';
import '../logic/websocket_logic.dart';
import 'game_mainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSignupScreen extends StatefulWidget {
  LoginSignupScreen({Key key}) : super(key: key);

  // TODO: replace

  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isMale = true;
  bool isSignupScreen = true;
  bool isRememberMe = false;
  bool isKeyboardVisible = false;
  bool isSuccessfulSignup = false;
  bool isSuccessfulSignin = false;
  final _textEditingControllerUsername = TextEditingController();
  final _textEditingControllerPassword = TextEditingController();
  final _textEditingControllerEmail = TextEditingController();
  WebSocketAPI _wsapi;

  _LoginSignupScreenState() {
    _wsapi = WebSocketAPI.signupAPI(
        changeIsSuccessfulSignup, changeIsSuccessfulSignin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
                height: 300,
                decoration: const BoxDecoration(
                    image: const DecorationImage(
                        image: const AssetImage("images/background.jpg"),
                        fit: BoxFit.cover)),
                child: Container(
                  padding: const EdgeInsets.only(top: 90, left: 20),
                  color: const Color(0xFF3b5999).withOpacity(.85),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                              text: isSignupScreen ? "Welcome to " : "Welcome ",
                              style: TextStyle(
                                fontSize: 25,
                                letterSpacing: 2,
                                color: Colors.yellow[700],
                              ),
                              children: [
                            TextSpan(
                                text: isSignupScreen ? "GPSPaper.io" : "back",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[700],
                                ))
                          ])),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        isSignupScreen
                            ? "Signup to Continue"
                            : "Signin to Continue",
                        style: TextStyle(
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                )),
          ),
          buildBottomHalfConatiner(true),
          // Main Container for Login and Signup
          AnimatedPositioned(
              duration: Duration(milliseconds: 700),
              curve: Curves.bounceOut,
              top: isSignupScreen ? 173 : 230,
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 700),
                  curve: Curves.bounceOut,
                  height: isSignupScreen ? 380 : 250,
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width - 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 5),
                      ]),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                changeSignupScreenState(false);
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "LOGIN",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: !isSignupScreen
                                            ? Palette.activeColor
                                            : Palette.textColor1),
                                  ),
                                  if (!isSignupScreen)
                                    Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        height: 2,
                                        width: 55,
                                        color: Colors.orange)
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => {changeSignupScreenState(true)},
                              child: Column(
                                children: [
                                  Text(
                                    "SIGNUP",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSignupScreen
                                            ? Palette.activeColor
                                            : Palette.textColor1),
                                  ),
                                  if (isSignupScreen)
                                    Container(
                                        margin: const EdgeInsets.only(top: 3),
                                        height: 2,
                                        width: 55,
                                        color: Colors.orange)
                                ],
                              ),
                            )
                          ],
                        ),
                        if (isSignupScreen) buildSignupSection(),
                        if (!isSignupScreen) buildSigninSection()
                      ],
                    ),
                  ))),
          // Trick to add the submit button
          buildBottomHalfConatiner(false),
        ],
      ),
    );
  }

  Container buildSigninSection() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            buildTextField(MaterialCommunityIcons.account_outline,
                "yourUsername", false, false),
            buildTextField(
                MaterialCommunityIcons.lock_outline, "********", true, false),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  Checkbox(
                      value: isRememberMe,
                      activeColor: Palette.textColor2,
                      onChanged: (value) {
                        changeIsRememberMeState(value);
                      }),
                  Text("Remember me",
                      style:
                          TextStyle(fontSize: 12, color: Palette.textColor1)),
                ],
              ),
              TextButton(
                  onPressed: () {},
                  child: Text("Forgot Password?",
                      style:
                          TextStyle(fontSize: 12, color: Palette.textColor1)))
            ])
          ],
        ));
  }

  Container buildSignupSection() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(children: [
          buildTextField(MaterialCommunityIcons.account_outline, "User Name",
              false, false),
          buildTextField(Icons.mail_outline, "Email", false, true),
          buildTextField(
              MaterialCommunityIcons.lock_outline, "Password", true, false),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Row(children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMale = true;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color:
                              isMale ? Palette.textColor2 : Colors.transparent,
                          border: Border.all(
                              width: 1,
                              color: isMale
                                  ? Colors.transparent
                                  : Palette.textColor1),
                          borderRadius: BorderRadius.circular(15)),
                      child: Icon(
                        MaterialCommunityIcons.account_outline,
                        color: isMale ? Colors.white : Palette.iconColor,
                      ),
                    ),
                    Text(
                      "Male",
                      style: TextStyle(color: Palette.textColor1),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 30,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMale = false;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color:
                              isMale ? Colors.transparent : Palette.textColor2,
                          border: Border.all(
                              width: 1,
                              color: isMale
                                  ? Palette.textColor1
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(15)),
                      child: Icon(
                        MaterialCommunityIcons.account_outline,
                        color: isMale ? Palette.iconColor : Colors.white,
                      ),
                    ),
                    Text(
                      "Female",
                      style: TextStyle(color: Palette.textColor1),
                    )
                  ],
                ),
              )
            ]),
          ),
          Container(
            width: 200,
            margin: EdgeInsets.only(top: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "By pressing 'Submit' you agree to our ",
                  style: TextStyle(color: Palette.textColor2),
                  children: [
                    TextSpan(
                      text: "terms & conditions",
                      style: TextStyle(color: Colors.orange),
                    )
                  ]),
            ),
          )
        ]));
  }

  Widget buildBottomHalfConatiner(bool showShadow) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 700),
      curve: Curves.bounceOut,
      top: isSignupScreen ? 508 : 430,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          height: 90,
          width: 90,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white,
              boxShadow: [
                if (showShadow)
                  BoxShadow(
                      color: Colors.black.withOpacity(.3),
                      spreadRadius: 1.5,
                      blurRadius: 10,
                      offset: Offset(0, 1))
              ]),
          child: !showShadow
              ? GestureDetector(
                  onTap: isSignupScreen ? sendDataSignup : sendDataSignin,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.orange[200], Colors.red[400]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1))
                        ]),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                )
              : Center(),
        ),
      ),
    );
  }

  Widget buildTextField(
      IconData icon, String hintText, bool isPassword, bool isEmail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: isPassword
            ? _textEditingControllerPassword
            : (isEmail
                ? _textEditingControllerEmail
                : _textEditingControllerUsername),
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Palette.iconColor),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Palette.textColor1),
              borderRadius: BorderRadius.all(Radius.circular(35.0))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Palette.textColor1),
              borderRadius: BorderRadius.all(Radius.circular(35.0))),
          contentPadding: EdgeInsets.all(10),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
        ),
      ),
    );
  }

  void changeIsSuccessfulSignup(value) {
    if (value) {
      showAlertDialog(context, "Successful Signup", "");
    } else {
      showAlertDialog(context, "Signup failed", "");
    }
    setState(() {
      isSuccessfulSignup = value;
    });
  }

  void changeIsSuccessfulSignin(value) async {
    setState(() {
      isSuccessfulSignin = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      if (isRememberMe) {
        prefs.setBool("isRememberedUser", true);
        prefs.setString("username", _textEditingControllerUsername.text);
        prefs.setString("password", _textEditingControllerPassword.text);
      } else {
        prefs.setBool("isRememberedUser", false);
        prefs.setString("username", _textEditingControllerUsername.text);
        prefs.setString("password", _textEditingControllerPassword.text);
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GameMainPage()),
      );
    } else {
      prefs.setBool("isRememberedUser", false);
      prefs.setString("username", "");
      prefs.setString("password", "");
      showAlertDialog(context, "Signin failed", "");
    }
  }

  showAlertDialog(BuildContext context, title, message) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    void changeIsSuccessfulSignin(value) {
      setState(() {
        isSuccessfulSignin = value;
      });
    }
  }

  void sendDataSignup() {
    _wsapi.sendDataSignup(
        _textEditingControllerUsername.text,
        _textEditingControllerPassword.text,
        _textEditingControllerEmail.text,
        isMale);
  }

  void sendDataSignin() {
    _wsapi.sendDataSignin(_textEditingControllerUsername.text,
        _textEditingControllerPassword.text, isRememberMe);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textEditingControllerUsername.dispose();
    _textEditingControllerPassword.dispose();
    _textEditingControllerEmail.dispose();
    super.dispose();
  }

  void changeSignupScreenState(state) async {
    if (!state) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool pos = prefs.getBool('isRememberedUser');
      if (pos == null) {
        pos = false;
      }
      print(pos);
      if (pos) {
        changeIsRememberMeState(true);
        print(prefs.getString("username"));
        _textEditingControllerUsername.text = prefs.getString('username');
        _textEditingControllerPassword.text = prefs.getString('password');
      } else {
        changeIsRememberMeState(false);
        prefs.setString("username", "");
        prefs.setString("password", "");
        _textEditingControllerPassword.text = "";
        _textEditingControllerUsername.text = "";
      }
    } else {
      _textEditingControllerEmail.text = "";
      _textEditingControllerPassword.text = "";
      _textEditingControllerUsername.text = "";
    }
    setState(() {
      isSignupScreen = state;
    });
  }

  void changeIsRememberMeState(state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isRememberedUser", state);
    if (state) {
      _textEditingControllerUsername.text = prefs.getString("username");
      _textEditingControllerPassword.text = prefs.getString("password");
    }
    setState(() {
      isRememberMe = state;
    });
  }
}
