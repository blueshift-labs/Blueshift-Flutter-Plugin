import 'dart:async';
import 'dart:io';

import 'package:blueshift_plugin/blueshift_inbox_message.dart';
import 'package:blueshift_plugin/blueshift_plugin.dart';
import 'package:flutter/material.dart';

class BlueshiftInboxWidget extends StatefulWidget {
  final TextStyle? titleTextStyle;
  final TextStyle? detailTextStyle;
  final TextStyle? dateTextStyle;
  final Color unreadIndicatorColor;
  final Color dividerColor;
  final Widget? placeholder;
  final Widget? loadingIndicator;
  final Widget Function(BlueshiftInboxMessage)? inboxItem;
  final String Function(DateTime)? dateFormatter;

  const BlueshiftInboxWidget({
    Key? key,
    this.titleTextStyle,
    this.detailTextStyle,
    this.dateTextStyle,
    this.unreadIndicatorColor = const Color(0xFF00C1C1),
    this.dividerColor = const Color(0xFF9A9A9A),
    this.placeholder = const SizedBox.shrink(),
    this.loadingIndicator = const CircularProgressIndicator(),
    this.inboxItem,
    this.dateFormatter,
  }) : super(key: key);

  @override
  _BlueshiftInboxWidgetState createState() => _BlueshiftInboxWidgetState();
}

class _BlueshiftInboxWidgetState extends State<BlueshiftInboxWidget> {
  late StreamSubscription<String> inboxEventStream;
  List<BlueshiftInboxMessage> _inboxMessages = [];
  bool _isInboxLoading = false;
  bool _isInAppLoading = false;

  refreshInboxMessages() {
    setState(() => _isInboxLoading = true);
    Blueshift.getInboxMessages().then((messages) {
      setState(() {
        _inboxMessages = messages;
        _isInboxLoading = false;
      });
    });
  }

  syncInboxMessages() {
    Blueshift.syncInboxMessages().then((value) => {});
  }

  Widget inboxWrapper() {
    return inboxWithPullToRefresh();
  }

  Widget inboxLoadingIndicator() {
    return Center(
      child: widget.loadingIndicator ?? const CircularProgressIndicator(),
    );
  }

  Widget inboxWithPullToRefresh() {
    return RefreshIndicator(
      child: inboxWithPlaceholder(),
      onRefresh: () {
        syncInboxMessages();
        return Future.value();
      },
    );
  }

  Widget inboxWithPlaceholder() {
    return _inboxMessages.isEmpty
        ? Center(child: widget.placeholder ?? const SizedBox.shrink())
        : inbox(_inboxMessages);
  }

  void showInboxMessage(BlueshiftInboxMessage message) {
    setState(() => _isInAppLoading = true);
    Blueshift.showInboxMessage(message);
  }

  @override
  void initState() {
    super.initState();
    refreshInboxMessages();
    inboxEventStream =
        Blueshift.getInstance.onInboxDataChanged.listen((String event) {
      if (event == "SyncCompleteEvent") {
        refreshInboxMessages();
      } else if (event == "InAppLoadEvent") {
        setState(() => _isInAppLoading = false);
      }
    });
    syncInboxMessages();
  }

  @override
  void dispose() {
    super.dispose();
    // Remove the event listener
    inboxEventStream.cancel();
  }

  String formatDate(DateTime? dateTime) {
    String formattedDate = "";

    if (dateTime != null) {
      if (widget.dateFormatter != null) {
        formattedDate = widget.dateFormatter!(dateTime);
      } else {
        formattedDate = dateTime.toLocal().toString();
      }
    }

    return formattedDate;
  }

  Widget inbox(List<BlueshiftInboxMessage> inboxMessages) {
    return ListView.separated(
      itemCount: inboxMessages.length,
      separatorBuilder: (context, index) => Divider(
        color: widget.dividerColor,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
        final inboxMessage = inboxMessages[index];

        return Dismissible(
            // Provide a unique key for each item
            key: Key(inboxMessage.messageId),
            onDismissed: (direction) {
              // Handle the dismiss event here
              Blueshift.deleteInboxMessage(inboxMessage).then((value) {
                setState(() {
                  // Remove the item from the data list
                  inboxMessages.removeAt(index);
                });
              }).onError((error, stackTrace) {
                refreshInboxMessages();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              });
            },
            background: const DismissibleBackground(),
            child: InkWell(
              onTap: () => showInboxMessage(inboxMessage),
              child: widget.inboxItem != null
                  ? widget.inboxItem!(inboxMessage)
                  : DefaultInboxListItem(
                      title: inboxMessage.title,
                      details: inboxMessage.details,
                      imageUrl: inboxMessage.imageUrl,
                      status: inboxMessage.status,
                      dateString: formatDate(inboxMessage.createdAt),
                      titleTextStyle: widget.titleTextStyle ??
                          DefaultTextStyle.of(context).style.copyWith(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                      detailsTextStyle: widget.detailTextStyle ??
                          DefaultTextStyle.of(context)
                              .style
                              .copyWith(fontSize: 14, color: Colors.black),
                      dateTextStyle: widget.dateTextStyle ??
                          DefaultTextStyle.of(context)
                              .style
                              .copyWith(fontSize: 12, color: Colors.black45),
                      unreadIndicatorColor: widget.unreadIndicatorColor,
                    ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          inboxWrapper(),
          if (Platform.isIOS && _isInAppLoading)
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0),
              child: inboxLoadingIndicator(),
            ),
        ],
      ),
    );
  }
}

class DefaultInboxListItem extends StatelessWidget {
  final String title;
  final String details;
  final String imageUrl;
  final String status;
  final String dateString;

  final TextStyle? titleTextStyle;
  final TextStyle? detailsTextStyle;
  final TextStyle? dateTextStyle;

  final Color unreadIndicatorColor;

  const DefaultInboxListItem({
    Key? key,
    required this.title,
    required this.details,
    required this.imageUrl,
    required this.status,
    required this.dateString,
    this.titleTextStyle,
    this.detailsTextStyle,
    this.dateTextStyle,
    required this.unreadIndicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: "unread" == status
                  ? unreadIndicatorColor
                  : Colors.transparent,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title.trim(),
                    style: titleTextStyle,
                  ),
                if (details.isNotEmpty)
                  Text(
                    details.trim(),
                    style: detailsTextStyle,
                  ),
                if (dateString.isNotEmpty)
                  Text(
                    dateString.trim(),
                    style: dateTextStyle,
                  ),
              ],
            ),
          ),
        ),
        if (imageUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Handle image load failure
                  return const SizedBox(
                    width: 56,
                    height: 56,
                  );
                },
              ),
            ),
          )
      ],
    );
  }
}

class DismissibleBackground extends StatelessWidget {
  const DismissibleBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
