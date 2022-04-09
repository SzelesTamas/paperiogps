import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:paperiogps/config/palette.dart';
import 'package:paperiogps/screen/mapwidget.dart';
import 'package:paperiogps/screen/setting_drawer.dart';
import '../logic/websocket_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameMainPage extends StatefulWidget {
  GameMainPage({Key key}) : super(key: key);

  @override
  _GameMainPageState createState() => _GameMainPageState();
}

class _GameMainPageState extends State<GameMainPage> {
  DateFormat _dateTime;
  WebSocketAPI _wsapi;
  MapWidget _mapwidget = MapWidget();
  final _textEditingControllerCoordinates = TextEditingController();
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );
  int ownId = -1;
  int lastKnownChange = -1;

  _GameMainPageState() {
    _wsapi = WebSocketAPI.gameMainScreenAPI(updateGrid);
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
      drawer: const SettingDrawerWidget(),
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
        .listen((Position position) async {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
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
      if (ownId != -1) {
        _wsapi.sendLastKnownChange(ownId, lastKnownChange);
      }
    });
  }

  void updateGrid(String _data) {
    Map<String, dynamic> data = jsonDecode(_data);

    switch (data["type"]) {
      case "beginningData":
        ownId = data["ownId"];
        lastKnownChange = data["lastKnownChange"];
        _mapwidget.state.drawBeginning(data);
        break;
      case "changeLogUpdate":
        if (_mapwidget.state.hasDrawnArena) {
          lastKnownChange = data["newLastKnown"];
          _mapwidget.state.drawNewChanges(data["newChanges"]);
        }
        break;
      default:
    }
  }
}
