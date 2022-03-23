import 'dart:convert';
import '../logic/websocket_client_factory.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketAPI {
  final _channel = makeWsClient('wss://api.mapconquest.tech');
  var _streamBuilder;

  WebSocketAPI.signupAPI(changeisSuccessfulSignup, changeisSuccessfulSignin) {
    _channel.stream.listen((data) {
      var msg = jsonDecode(data);
      if (msg["type"] == "checkUserSignupReturn") {
        changeisSuccessfulSignup(msg["returnValue"]);
      } else if (msg["type"] == "checkUserSigninReturn") {
        changeisSuccessfulSignin(msg["returnValue"]);
      }
    });
  }

  WebSocketAPI.gameMainScreenAPI() {
    _channel.stream.listen((data) {
      var msg = jsonDecode(data);
    });
  }

  void sendLocationData(location, timeSinceEpoch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var toSend = {
      "type": "userLocationData",
      "username": prefs.getString("username"),
      "latitude": location.latitude,
      "longitude": location.longitude,
      "timeSinceEpoch": timeSinceEpoch
    };
    this._channel.sink.add(jsonEncode(toSend));
  }

  void sendDataSignup(username, password, email, isMale) {
    var toSend = {
      "type": "checkUserSignup",
      "username": username,
      "password": password,
      "email": email,
      "isMale": isMale
    };
    this._channel.sink.add(jsonEncode(toSend));
  }

  void sendDataSignin(username, password, isRememberMe) {
    var toSend = {
      "type": "checkUserSignin",
      "username": username,
      "password": password,
      "rememberMe": isRememberMe,
    };
    this._channel.sink.add(jsonEncode(toSend));
  }

  void fillUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var toSend = {
      "type": "fillUserData",
      "username": prefs.getString("username")
    };
    this._channel.sink.add(jsonEncode(toSend));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    this._channel.sink.close();
  }
}
