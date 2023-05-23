import 'dart:async';

import 'package:blueshift_plugin/blueshift_inbox_message.dart';
import 'package:blueshift_plugin/blueshift_plugin.dart';
import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  Future<List<BlueshiftInboxMessage>> items = Blueshift.getInboxMessages();
  late StreamSubscription<String> inboxEventStream;

  void handleOnTap(BlueshiftInboxMessage message) {
    Blueshift.showInboxMessage(message);
  }

  void handleRemoveItem(BlueshiftInboxMessage message) {
    Blueshift.deleteInboxMessage(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${message.title}')),
    );
  }

  void syncInbox() async {
    setState(() {
      Blueshift.syncInboxMessages();
      // Replace the items with new data
      items = Blueshift.getInboxMessages();
    });
  }

  Future<void> _refreshList() async {
    syncInbox();
  }

  @override
  void initState() {
    super.initState();
    inboxEventStream = Blueshift.getInstance.onInboxDataChanged.listen(
      (String event) {
        print("datachanged- syncing inbox!");
        syncInbox();
      },
    );
    // messageCountFuture = fetchMessageCount();
    Blueshift.syncInboxMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blueshift Inbox'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: FutureBuilder<List<BlueshiftInboxMessage>>(
          future: items,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the data, display a loading indicator
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              // If an error occurred while fetching the data, display an error message
              return Center(
                child: Text('Error occurred: ${snapshot.error}'),
              );
            } else {
              // If the data was successfully fetched, display it in a ListView
              final items = snapshot.data;
              return ListView.builder(
                itemCount: items?.length,
                itemBuilder: (context, index) {
                  final item = items![index];
                  return Dismissible(
                    key: Key(
                        item.messageId!), // Provide a unique key for each item
                    onDismissed: (direction) {
                      // Handle the dismiss event here
                      handleRemoveItem(item);
                      setState(() {
                        items.removeAt(
                            index); // Remove the item from the data list
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        // Handle the click event here
                        handleOnTap(item);
                      },
                      leading: items![index].imageUrl != null
                          ? Image.network(
                              items[index].imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(
                              width: 50, height: 50), // Empty case,
                      title: Text(items[index].title!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(items[index].detail ?? ""),
                          Text(
                            items![index].createdAt.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: item.status == "unread"
                          ? Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                ' ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
