import 'dart:developer';

import 'package:flutter/material.dart';

import '../config/palette.dart';

class SettingDrawerWidget extends StatelessWidget {
  const SettingDrawerWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        key: Key("key"),
        backgroundColor: Palette.backgroundColor,
        elevation: 1,
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
                decoration: BoxDecoration(color: Palette.activeColor),
                child: Text("Settings")),
            ListTile(
              title: Text("aaaa?"),
              onTap: null,
            )
          ],
        ));
  }
}
