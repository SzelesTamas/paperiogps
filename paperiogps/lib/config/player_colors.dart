import 'dart:math';

import 'package:flutter/painting.dart';

class PlayerColor {
  static int ownedFieldAlpha = 1000;
  static int tailFieldAlpha = 600;
  static Color selectColor(number, alpha) {
    number = number + 10;

    List<int> col = [];
    Random rnd = Random(number);

    for (int i = 0; i < 3; i++) {
      col.add(rnd.nextInt(16) * 16 + rnd.nextInt(16));
    }

    return Color.fromARGB(alpha, col[0], col[1], col[2]);
  }
}
