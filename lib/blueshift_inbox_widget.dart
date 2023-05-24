import 'dart:async';
import 'dart:io';

import 'package:blueshift_plugin/blueshift_inbox_message.dart';
import 'package:blueshift_plugin/blueshift_plugin.dart';
import 'package:flutter/material.dart';

class BlueshiftInboxWidget extends StatefulWidget {
  final Color titleTextColor;
  final Color detailTextColor;
  final Color dateTextColor;
  final Color seperaterColor;

  const BlueshiftInboxWidget({
    Key? key,
    this.titleTextColor = Colors.black,
    this.detailTextColor = Colors.blueGrey,
    this.dateTextColor = Colors.grey,
    this.seperaterColor = const Color.fromARGB(255, 234, 234, 234),
  }) : super(key: key);

  @override
  _BlueshiftInboxWidgetState createState() => _BlueshiftInboxWidgetState();
}

class _BlueshiftInboxWidgetState extends State<BlueshiftInboxWidget>
    with AutomaticKeepAliveClientMixin {
  Future<List<BlueshiftInboxMessage>> messages = Blueshift.getInboxMessages();
  late StreamSubscription<String> inboxEventStream;
  bool isLoading = false;

  void showInboxMessage(BlueshiftInboxMessage message) {
    setState(() {
      isLoading = true;
    });
    Blueshift.showInboxMessage(message);
  }

  void deleteMessage(BlueshiftInboxMessage message) {
    Blueshift.deleteInboxMessage(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted ${message.title}')),
    );
  }

  void reloadInbox() async {
    setState(() {
      messages = Blueshift.getInboxMessages();
    });
  }

  Future<void> refreshList() async {
    reloadInbox();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    inboxEventStream = Blueshift.getInstance.onInboxDataChanged.listen(
      (String event) {
        if (event == "SyncCompleteEvent") {
          reloadInbox();
        } else if (event == "InAppLoadEvent") {
          setState(() {
            isLoading = false;
          });
        }
      },
    );
    Blueshift.syncInboxMessages();
  }

  @override
  void dispose() {
    super.dispose();
    // Remove the event listener
    inboxEventStream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isIOS = Platform.isIOS;
    final themeData = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refreshList,
            child: FutureBuilder<List<BlueshiftInboxMessage>>(
              future: messages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the data, display a loading indicator
                  return const Center(
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
                  return ListView.separated(
                    itemCount: items!.length,
                    separatorBuilder: (context, index) => Divider(
                      color: widget.seperaterColor,
                      thickness: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: Key(item
                            .messageId!), // Provide a unique key for each item
                        onDismissed: (direction) {
                          // Handle the dismiss event here
                          deleteMessage(item);
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
                          key: UniqueKey(),
                          onTap: () {
                            // Handle the click event here
                            showInboxMessage(item);
                          },
                          leading: items[index].imageUrl != null
                              ? Image.network(
                                  items[index].imageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(
                                  width: 50, height: 50), // Empty case,
                          title: Text(
                            items[index].title!,
                            style: TextStyle(
                              color: widget.titleTextColor,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (items[index].detail != "" &&
                                  items[index].detail != null)
                                Text(
                                  items[index].detail!.trim(),
                                  style: TextStyle(
                                    color: widget.detailTextColor,
                                  ),
                                ),
                              if (items[index].createdAt != null)
                                Text(
                                  items[index].createdAt!.toLocal().toString(),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: widget.dateTextColor),
                                ),
                            ],
                          ),
                          trailing: item.status == "unread"
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: themeData.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 10,
                                  height: 10,
                                )
                              : const SizedBox(
                                  width: 10,
                                  height: 10,
                                ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          if (isIOS && isLoading)
            Container(
              color: themeData.primaryColor.withOpacity(0),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
