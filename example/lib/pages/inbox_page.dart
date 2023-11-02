import 'package:blueshift_plugin/blueshift_inbox.dart';
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
        body: BlueshiftInbox(
          titleTextStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.green),
          detailsTextStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.red),
          dateTextStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.blue),
          unreadIndicatorColor: Colors.cyan,
          // dividerColor: Colors.blueGrey,
          // dateFormatter: (date) => date.toIso8601String(),
          // sortMessages: (m1, m2) => m2.createdAt.compareTo(m1.createdAt),
          // placeholder: const Text("Inbox is empty!"),
          // loadingIndicator: const Icon(Icons.hourglass_top),
          // inboxItem: (msg) => Column(
          //   crossAxisAlignment: CrossAxisAlignment.stretch,
          //   children: [
          //     Text(msg.title.trim()),
          //     Text(msg.details),
          //     Text(msg.imageUrl),
          //   ],
          // ),
        ),
      ),
    );
  }
}
