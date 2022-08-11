import 'package:flutter/material.dart';
import 'package:blueshift_flutter_plugin/blueshift.dart';

class DeeplinkPage extends StatefulWidget {
  var deeplink = "";
  DeeplinkPage({Key? key, required this.deeplink}) : super(key: key);

  @override
  State<DeeplinkPage> createState() => _DeeplinkPageState(deeplink: deeplink);
}

class _DeeplinkPageState extends State<DeeplinkPage> {
  var deeplink = "";
  _DeeplinkPageState({required this.deeplink});

  @override
  void initState() {
    super.initState();
    Blueshift.trackScreenView("DeepLinkScreen", {}, false);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
      appBar: AppBar(title: const Text("Deep Link Page")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Received Deep link URL : ",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 22),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              deeplink,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 20),
              softWrap: true,
            ),
          ],
        ),
      ),
    ));
  }
}
