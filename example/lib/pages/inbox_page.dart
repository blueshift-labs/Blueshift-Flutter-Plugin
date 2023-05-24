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
            title: Text('My Inbox'),
          ),
          body: const BlueshiftInboxWidget(
              titleTextColor: Colors.black,
              detailTextColor: Color.fromARGB(255, 49, 49, 49),
              dateTextColor: Color.fromARGB(255, 111, 111, 111),
              seperaterColor: Color.fromARGB(255, 203, 203, 203))),
    );
  }
}
