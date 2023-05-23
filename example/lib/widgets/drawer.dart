import 'package:blueshift_plugin/blueshift_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/routes.dart';

class MyDrawer extends StatefulWidget {
  var email = "";
  var name = "";
  MyDrawer({Key? key, required this.email, required this.name})
      : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState(email: email, name: name);
}

class _MyDrawerState extends State<MyDrawer> {
  String name = "";
  String email = "";

  _MyDrawerState({required this.email, required this.name});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue,
      child: ListView(
        children: [
          DrawerHeader(
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                accountEmail: Text(email),
                accountName: Text(name),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                ),
              )),
          ListTile(
              leading: const Icon(CupertinoIcons.home, color: Colors.white),
              title: const Text("Home", style: TextStyle(color: Colors.white)),
              onTap: () {
                homePressed(context);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send Push",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent("bsft_send_me_push", {}, false);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send Image Push",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent(
                    "bsft_send_me_image_push", {}, false);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send animated carousel Push",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent(
                    "bsft_send_me_animated_carousel_push", {}, false);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send non animated carousel Push",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent(
                    "bsft_send_me_nonanimated_carousel_push", {}, false);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send custom button Push",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent(
                    "bsft_send_me_custom_button_push", {}, false);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send in app",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent("bsft_send_me_in_app", {}, false);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send Modal in app",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent(
                    "bsft_send_me_in_app_modal", {}, false);
              }),
          ListTile(
              leading: const Icon(CupertinoIcons.eject, color: Colors.white),
              title: const Text("Send HTML in app",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Blueshift.trackCustomEvent(
                    "bsft_send_me_in_app_html", {}, false);
              })
        ],
      ),
    );
  }

  void homePressed(context) {
    Navigator.pop(context);
  }
}
