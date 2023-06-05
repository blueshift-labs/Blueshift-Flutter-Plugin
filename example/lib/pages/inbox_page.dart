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
        body: const BlueshiftInbox(
          // titleTextStyle: Theme.of(context).textTheme.bodyLarge,
          // detailTextStyle: Theme.of(context).textTheme.bodyMedium,
          // dateTextStyle: Theme.of(context).textTheme.bodySmall,
          // unreadIndicatorColor: Colors.red,
          // dividerColor: Colors.blueGrey,
          // dateFormatter: (date) => date.toIso8601String(),
          // placeholder: const Text("Inbox is empty!"),
          // loadingIndicator: const Icon(Icons.hourglass_top),
          // inboxItem: (msg) => Column(
          //   crossAxisAlignment: CrossAxisAlignment.stretch,
          //   children: [
          //     Text(msg.title.trim()),
          //     Text(msg.detail),
          //     Text(msg.imageUrl),
          //   ],
          // ),
        ),
      ),
    );
  }
}
