import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart";
import 'package:shared_preferences/shared_preferences.dart';

class MapWidget extends StatefulWidget {
  MapWidget({Key key}) : super(key: key);
  _MapWidgetState state;

  //@override
  _MapWidgetState createState() => state = _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng _markerPoint = LatLng(47.3729, 18.9962);

  _MapWidgetState() {
    //updateMarkerLocation(47.2729, 18.9962);
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
    setState(() {});
  }
}
