import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:paperiogps/screen/mapwidget.dart';
import '../logic/websocket_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameMainPage extends StatefulWidget {
  GameMainPage({Key key}) : super(key: key);

  @override
  _GameMainPageState createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  DateFormat _dateTime;
  WebSocketAPI _wsapi = WebSocketAPI.gameMainScreenAPI();
  MapWidget _mapwidget = MapWidget();
  final _textEditingControllerCoordinates = TextEditingController();
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );

  _GameMainPageState() {
    _wsapi.fillUserData();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(children: [
          _mapwidget,
          TextField(
            enabled: false,
            controller: _textEditingControllerCoordinates,
          ),
        ]),
      ),
    );
  }

  void getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    SharedPreferences prefs = await SharedPreferences.getInstance();
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
      prefs.setDouble(
          "lastLat",
          position
              .latitude); //uncommenting these sometimes often breaks everything
      prefs.setDouble("lastLng", position.longitude);

      _mapwidget.state
          .updateMarkerLocation(position.latitude, position.longitude);
      _wsapi.sendLocationData(position, DateTime.now().millisecondsSinceEpoch);
    });
  }
}
