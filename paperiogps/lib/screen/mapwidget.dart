import 'dart:convert';
import 'dart:ffi';
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
}

class Point {
  double lat;
  double lng;

  Point(double lt, double lg) {
    lat = lt;
    lng = lg;
  }
}

class _MapWidgetState extends State<MapWidget> {
  LatLng _markerPoint = LatLng(47.3729, 18.9962);
  Polyline pathPolyline = Polyline(
    points: [],
    strokeWidth: 2.0,
    color: Color.fromARGB(200, 72, 0, 113),
  );
  List<Polygon> _polygons;
  List<Polyline> _polylines = List<Polyline>();

  _MapWidgetState() {
    //updateMarkerLocation(47.2729, 18.9962);
    _polylines.add(pathPolyline);
    _polygons = <Polygon>[];
    //proba();
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
          PolygonLayerOptions(polygons: _polygons),
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
    Polygon(
        points: polygonLatLongs,
        color: Color.fromARGB(100, 40, 30, 128),
        borderColor: Colors.red,
        borderStrokeWidth: 1);
  }

  List<LatLng> makeField(
      int lat, int lng, Point upperLeftCorner, double gridUnitSize) {
    List<LatLng> out = List<LatLng>();
    out.add(LatLng(upperLeftCorner.lat - lat * gridUnitSize,
        upperLeftCorner.lng + lng * gridUnitSize));
    out.add(LatLng(upperLeftCorner.lat - (lat + 1) * gridUnitSize,
        upperLeftCorner.lng + lng * gridUnitSize));
    out.add(LatLng(upperLeftCorner.lat - (lat + 1) * gridUnitSize,
        upperLeftCorner.lng + (lng + 1) * gridUnitSize));
    out.add(LatLng(upperLeftCorner.lat - lat * gridUnitSize,
        upperLeftCorner.lng + (lng + 1) * gridUnitSize));

    return out;
  }

  void updateGrid(String _data) {
    Map<String, dynamic> data = jsonDecode(_data);
    dynamic grid = jsonDecode(data["arenaData"]);

    int dim1 = grid.length;
    int dim2 = grid[0].length;
    Point upperLeftCorner = Point(
        data["upperLeftCornerLatitude"], data["upperLeftCornerLongitude"]);
    double gridUnitSize = data["gridUnitSize"];

    //debugPrint('dim1: $dim1');
    //debugPrint('dim2: $dim2');
    String owner;

    _polygons.clear();
    for (int i = 0; i < dim1; i++) {
      for (int j = 0; j < dim2; j++) {
        owner = grid[i][j]["owner"].toString();

        if (owner != "none") {
          _polygons.add(new Polygon(
              points: makeField(i, j, upperLeftCorner, gridUnitSize),
              color: Color.fromARGB(134, 255, 0, 0)));
        }
      }
    }
  }
}
