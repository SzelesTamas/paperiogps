import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";
import 'package:paperiogps/config/mapconfig.dart';
import 'package:paperiogps/config/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';
import 'package:paperiogps/config/player_colors.dart';

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
  List<Polygon> _arenaPolygons = <Polygon>[];
  bool hasDrawnArena = false;
  List<Polyline> _polylines = <Polyline>[];
  Map<String, int> _playerColors = Map<String, int>();
  int _gameRandSeed;
  Point upperLeftCorner, lowerRightCorner;
  double gridUnitSize;
  Point gridSize;
  List<List<int>> tailer = List<List<int>>();
  List<List<int>> owner = List<List<int>>();

  MapController _mapController;

  _MapWidgetState() {
    //updateMarkerLocation(47.2729, 18.9962);
    _polylines.add(pathPolyline);
    _polygons = <Polygon>[];
    _mapController = MapController();
    Random rnd = Random();
    _gameRandSeed = rnd.nextInt(1000);
    //proba();
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (_mapController.center != _markerPoint) {
        _mapController.move(_markerPoint, _mapController.zoom);
      }
    });
    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _markerPoint,
          allowPanning: MapConfig.allowPanning,
          minZoom: MapConfig.minZoom,
          zoom: MapConfig.zoom,
          maxZoom: MapConfig.maxZoom,
          interactiveFlags: MapConfig.iflag,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          PolygonLayerOptions(polygons: _arenaPolygons), //ARENA BOUNDARIES
          PolygonLayerOptions(polygons: _polygons), //CAPTURED FIELDS
          PolylineLayerOptions(polylines: _polylines),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: _markerPoint,
                builder: (ctx) => const Icon(
                  Icons.local_pizza_outlined,
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
    Polygon p = Polygon(
        points: polygonLatLongs,
        color: Color.fromARGB(100, 40, 30, 128),
        borderColor: Colors.red,
        borderStrokeWidth: 1);
  }

  void changeFieldColor(int lat, int lng, Color newColor) {
    List<LatLng> points = makeField(lat, lng);

    int ind = lat * gridSize.lng.toInt() + lng;
    _polygons[ind] = new Polygon(points: points, color: newColor);
  }

  List<LatLng> makeField(int lat, int lng) {
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

  Polygon drawPlayer(double lat, double lng,
      {double size = 0.00001, Color color = Colors.black}) {
    Point upperLeftCorner = Point(lat + size / 2, lng - size / 2);

    List<LatLng> points = List<LatLng>();
    points.add(LatLng(upperLeftCorner.lat, upperLeftCorner.lng));
    points.add(LatLng(upperLeftCorner.lat - size, upperLeftCorner.lng));
    points.add(LatLng(upperLeftCorner.lat - size, upperLeftCorner.lng + size));
    points.add(LatLng(upperLeftCorner.lat, upperLeftCorner.lng + size));

    Polygon out = Polygon(points: points, color: color);
    return out;
  }

  void drawArenaBoundaries() {
    _arenaPolygons.clear();
    _arenaPolygons.add(Polygon(
      color: Colors.transparent,
      borderColor: const Color(0xFF004F71),
      borderStrokeWidth: 2,
      points: [
        LatLng(upperLeftCorner.lat, upperLeftCorner.lng),
        LatLng(upperLeftCorner.lat, lowerRightCorner.lng),
        LatLng(lowerRightCorner.lat, lowerRightCorner.lng),
        LatLng(lowerRightCorner.lat, upperLeftCorner.lng)
      ],
    ));
  }

  void drawGrid(grid) {
    String owner;
    String tailOwner;

    for (int i = 0; i < gridSize.lat; i++) {
      for (int j = 0; j < gridSize.lng; j++) {
        changeFieldColor(i, j, Colors.transparent);
        continue;
        /*
        owner = grid[i][j]["owner"].toString();
        tailOwner = grid[i][j]["tailOwner"].toString();

        if (owner == "none" && tailOwner == "none") {
          continue;
        }

        Color col;

        if (tailOwner != "none") {
          if (!_playerColors.containsKey(tailOwner)) {
            _playerColors[tailOwner] = _playerColors.length + _gameRandSeed;
          }
          col = PlayerColor.selectColor(
              _playerColors[tailOwner], PlayerColor.tailFieldAlpha);
        } else if (owner != "none") {
          if (!_playerColors.containsKey(owner)) {
            _playerColors[owner] = _playerColors.length + _gameRandSeed;
          }
          col = PlayerColor.selectColor(
              _playerColors[owner], PlayerColor.ownedFieldAlpha);
        }
        changeFieldColor(i, j, col);
*/
      }
    }
  }

  void drawBeginning(data) {
    if (!hasDrawnArena) {
      dynamic grid = jsonDecode(data["arenaData"]);

      int dim1 = grid.length;
      int dim2 = grid[0].length;
      gridSize = Point(dim1.toDouble(), dim2.toDouble());
      upperLeftCorner = Point(
          data["upperLeftCornerLatitude"], data["upperLeftCornerLongitude"]);
      lowerRightCorner = Point(
          data["lowerRightCornerLatitude"], data["lowerRightCornerLongitude"]);
      gridUnitSize = data["gridUnitSize"];

      _polygons.clear();
      for (int i = 0; i < dim1; i++) {
        List<int> temp1 = List<int>();
        List<int> temp2 = List<int>();
        for (int j = 0; j < dim2; j++) {
          temp1.add(-1);
          temp2.add(-1);
          _polygons
              .add(new Polygon(points: makeField(i, j), color: Colors.black12));
        }
        tailer.add(temp1);
        owner.add(temp2);
      }

      drawArenaBoundaries();
      drawGrid(grid);

      hasDrawnArena = true;
    }
  }

  void changeOwner(int a, int b, int c) {
    if (c == -1) {
      owner[a][b] = -1;
      tailer[a][b] = -1;
      changeFieldColor(a, b, Colors.transparent);
      return;
    }
    if (!_playerColors.containsKey(c.toString())) {
      _playerColors[c.toString()] = _playerColors.length + _gameRandSeed;
    }
    Color color = PlayerColor.selectColor(
        _playerColors[c.toString()], PlayerColor.ownedFieldAlpha);
    tailer[a][b] = -1;
    owner[a][b] = c;
    changeFieldColor(a, b, color);
  }

  void changeTailer(int a, int b, int c) {
    if (c == -1) {
      tailer[a][b] = -1;
      if (owner[a][b] != -1) {
        if (!_playerColors.containsKey(owner[a][b].toString())) {
          _playerColors[owner[a][b].toString()] =
              _playerColors.length + _gameRandSeed;
        }
        Color color = PlayerColor.selectColor(
            _playerColors[owner[a][b].toString()], PlayerColor.ownedFieldAlpha);

        changeFieldColor(a, b, color);
      } else {
        changeFieldColor(a, b, Colors.transparent);
      }
      return;
    }

    if (!_playerColors.containsKey(c.toString())) {
      _playerColors[c.toString()] = _playerColors.length + _gameRandSeed;
    }
    Color color = PlayerColor.selectColor(
        _playerColors[c.toString()], PlayerColor.tailFieldAlpha);

    tailer[a][b] = c;
    changeFieldColor(a, b, color);
  }

  void drawNewChanges(newChanges) {
    int type, a, b, c;
    for (var change in newChanges) {
      type = change["type"];
      a = change["a"];
      b = change["b"];
      c = change["c"];

      switch (type) {
        case 1:
          changeOwner(a, b, c);
          break;
        case 2:
          changeTailer(a, b, c);
          break;
        default:
      }
    }
  }
}
