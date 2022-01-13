import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../logic/websocket_logic.dart';

class GameMainPage extends StatefulWidget {
  GameMainPage({Key key}) : super(key: key);

  @override
  _GameMainPageState createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  DateFormat _dateTime;
  WebSocketAPI _wsapi = WebSocketAPI.gameMainScreenAPI();
  final _textEditingControllerCoordinates = TextEditingController();
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );

  _GameMainPageState() {
    _wsapi.fillUserData();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextField(
          enabled: false,
          controller: _textEditingControllerCoordinates,
        ),
      ),
    );
  }

  void getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Geolocator.getPositionStream(locationSettings: _locationSettings)
        .listen((Position position) {
      _textEditingControllerCoordinates.text = (position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      _wsapi.sendLocationData(position, DateTime.now().millisecondsSinceEpoch);
    });
  }
}
