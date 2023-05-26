import 'package:blueshift_plugin/blueshift_inbox_widget.dart';
import 'package:flutter/material.dart';

class InboxPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('My Inbox'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: const BlueshiftInboxWidget(
              titleTextColor: Colors.black,
              detailTextColor: Color.fromARGB(255, 49, 49, 49),
              dateTextColor: Color.fromARGB(255, 111, 111, 111),
              seperaterColor: Color.fromARGB(255, 203, 203, 203))),
    );
  }
}
