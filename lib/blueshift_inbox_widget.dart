import 'dart:async';
import 'dart:io';

import 'package:blueshift_plugin/blueshift_inbox_message.dart';
import 'package:blueshift_plugin/blueshift_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BlueshiftInboxWidget extends StatefulWidget {
  final TextStyle? titleTextStyle;
  final TextStyle? detailTextStyle;
  final TextStyle? dateTextStyle;
  final Color unreadIndicatorColor;
  final Color dividerColor;
  final Widget? placeholder;
  final String Function(DateTime)? dateFormatter;

  const BlueshiftInboxWidget({
    Key? key,
    this.titleTextStyle,
    this.detailTextStyle,
    this.dateTextStyle,
    this.unreadIndicatorColor = const Color(0xFF00C1C1),
    this.dividerColor = const Color(0xFF9A9A9A),
    this.placeholder = const SizedBox.shrink(),
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

  Widget inboxWithLoader() {
    return _isInboxLoading == true
        ? const Center(child: CircularProgressIndicator())
        : inboxContainer();
  }

  Widget inboxContainer() {
    return _inboxMessages.isEmpty
        ? Center(child: widget.placeholder ?? const SizedBox.shrink())
        : inbox(_inboxMessages);
  }

  Widget swipeToRefresh() {
    return RefreshIndicator(
      child: inboxContainer(),
      onRefresh: () {
        refreshInboxMessages();
        return Future.value();
      },
    );
  }

  void showInboxMessage(BlueshiftInboxMessage message) {
    setState(() => _isInAppLoading = true);
    Blueshift.showInboxMessage(message);
  }

  @override
  void initState() {
    super.initState();
    inboxEventStream = Blueshift.getInstance.onInboxDataChanged.listen(
      (String event) {
        if (event == "SyncCompleteEvent") {
          refreshInboxMessages();
        } else if (event == "InAppLoadEvent") {
          setState(() => _isInAppLoading = false);
        }
      },
    );

    refreshInboxMessages();
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
        thickness: 1.0,
      ),
      itemBuilder: (context, index) {
        final inboxMessage = inboxMessages[index];

        final String? title = inboxMessage.title;
        final String? details = inboxMessage.detail;
        final String? imageUrl = inboxMessage.imageUrl;
        final String? status = inboxMessage.status;
        final DateTime? createdAt = inboxMessage.createdAt;

        return Dismissible(
          // Provide a unique key for each item
          key: Key(inboxMessage.messageId!),
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
          child: InboxListItem(
            title: title ?? "",
            details: details ?? "",
            imageUrl: imageUrl ?? "",
            status: status ?? "",
            dateString: formatDate(createdAt),
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
            onTap: () => showInboxMessage(inboxMessage),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          swipeToRefresh(),
          if (Platform.isIOS && _isInAppLoading)
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

class InboxListItem extends StatelessWidget {
  final String title;
  final String details;
  final String imageUrl;
  final String status;
  final String dateString;

  final TextStyle? titleTextStyle;
  final TextStyle? detailsTextStyle;
  final TextStyle? dateTextStyle;

  final Color unreadIndicatorColor;

  final void Function()? onTap;

  const InboxListItem(
      {Key? key,
      required this.title,
      required this.details,
      required this.imageUrl,
      required this.status,
      required this.dateString,
      this.titleTextStyle,
      this.detailsTextStyle,
      this.dateTextStyle,
      required this.unreadIndicatorColor,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title:
          title.isNotEmpty ? Text(title.trim(), style: titleTextStyle) : null,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (details.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(details.trim(), style: detailsTextStyle),
            ),
          if (dateString.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(dateString.trim(), style: dateTextStyle),
            ),
        ],
      ),
      trailing: "unread" == status
          ? Container(
              decoration: BoxDecoration(
                color: unreadIndicatorColor,
                shape: BoxShape.circle,
              ),
              width: 8,
              height: 8,
            )
          : null,
      leading: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            )
          : null,
      onTap: onTap,
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
