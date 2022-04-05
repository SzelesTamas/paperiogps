import 'dart:developer';

import 'package:flutter/material.dart';

import '../config/palette.dart';

class SettingDrawerWidget extends StatelessWidget {
  const SettingDrawerWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        key: const Key("key"),
        backgroundColor: Palette.backgroundColor,
        elevation: 1,
        child: Column(
          children: const [
            DrawerHeader(
                decoration: BoxDecoration(color: Palette.softActiveColor),
                child: Text("Settings & some user data"),
            ),  
            ListTile(
              title: Text("aaaa?"),
              onTap: null,
            ),
            Spacer(),
            Divider(),
            ListTile(
              title: Text("logout"),
            )
          ],
        ));
  }
}
