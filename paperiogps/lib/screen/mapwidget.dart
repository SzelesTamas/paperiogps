import 'dart:convert';
//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";
import 'package:paperiogps/config/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';

class MapWidget extends StatefulWidget {
  MapWidget({Key key}) : super(key: key);
  _MapWidgetState state;

  //@override
  _MapWidgetState createState() => state = _MapWidgetState();

  void updateGrid(String grid) {}
}

class _MapWidgetState extends State<MapWidget> {
  LatLng _markerPoint = LatLng(47.3729, 18.9962);
  Polyline pathPolyline = Polyline(
    points: [],
    strokeWidth: 2.0,
    color: Color.fromARGB(200, 72, 0, 113),
  );
  List<List<Polygon>> _polygons;
  List<Polyline> _polylines = List<Polyline>();

  _MapWidgetState() {
    //updateMarkerLocation(47.2729, 18.9962);
    _polylines.add(pathPolyline);
    proba();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      FlutterMap(
        options: MapOptions(
          center: _markerPoint,
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolylineLayerOptions(polylines: _polylines),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: _markerPoint,
                builder: (ctx) => const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
      /*
      Positioned(
        bottom: 0,
        child: ElevatedButton(
            onPressed: updateMarkerLocation, child: Icon(Icons.refresh_sharp)),
      )
      */
    ]);
  }

  void updateMarkerLocation(double lat, double lng) async {
    /*
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double lat = prefs.getDouble('lastLat');
    double lng = prefs.getDouble('lastLng');
    */
    lat ??= 46.9;
    lng ??= 19.4;
    _markerPoint = LatLng(lat, lng);
    _polylines[0].points.add(_markerPoint);
    setState(() {});
  }

  void proba() {
    List<LatLng> polygonLatLongs = List<LatLng>();
    polygonLatLongs.add(LatLng(46.9492, 19.4562));
    polygonLatLongs.add(LatLng(46.9273, 19.4562));
    polygonLatLongs.add(LatLng(46.9273, 19.4965));
    polygonLatLongs.add(LatLng(46.9492, 19.4965));
  }

  void updateGrid(String _grid) {
    dynamic grid = jsonDecode(_grid);
    debugPrint(_grid);
    if (_polygons.length != grid.length) {
      _polygons.clear();
      for (int i = 0; i < grid.length; i++) {
        _polygons.add(List<Polygon>.filled(grid[0].length, new Polygon()));
      }
    }

    for (int i = 0; i < _polygons.length; i++) {
      for (int j = 0; j < _polygons[i].length; j++) {
        dynamic field = jsonDecode(grid[i][j]);
        if (field["owner"] == "none") {
          _polygons[i][j] = new Polygon(color: Colors.transparent);
        } else {
          if (field["isTail"]) {
            _polygons[i][j] = new Polygon(color: Color.fromARGB(50, 0, 0, 0));
          } else {
            _polygons[i][j] = new Polygon(color: Color.fromARGB(75, 0, 0, 0));
          }
        }
      }
    }
  }
}
