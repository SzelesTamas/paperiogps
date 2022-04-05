import 'package:flutter_map/flutter_map.dart';

class MapConfig {
  static const double minZoom = 10.0;
  static const double zoom = 15.0;
  static const double maxZoom = 19.0;
  static const bool allowPanning = false;
  static const int iflag = InteractiveFlag.drag | InteractiveFlag.pinchZoom;
}
