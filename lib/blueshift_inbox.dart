import 'dart:async';
import 'dart:io';

import 'package:blueshift_plugin/blueshift_inbox_message.dart';
import 'package:blueshift_plugin/blueshift_plugin.dart';
import 'package:flutter/material.dart';

class BlueshiftInbox extends StatefulWidget {
  final TextStyle? titleTextStyle;
  final TextStyle? detailsTextStyle;
  final TextStyle? dateTextStyle;
  final Color unreadIndicatorColor;
  final Color dividerColor;
  final Widget? placeholder;
  final Widget? loadingIndicator;
  final Widget Function(BlueshiftInboxMessage)? inboxItem;
  final String Function(DateTime)? dateFormatter;
  final int Function(BlueshiftInboxMessage, BlueshiftInboxMessage)?
      sortMessages;

  const BlueshiftInbox({
    Key? key,
    this.titleTextStyle,
    this.detailsTextStyle,
    this.dateTextStyle,
    this.unreadIndicatorColor = const Color(0xFF00C1C1),
    this.dividerColor = const Color(0xFF9A9A9A),
    this.placeholder = const SizedBox.shrink(),
    this.loadingIndicator = const CircularProgressIndicator(),
    this.inboxItem,
    this.dateFormatter,
    this.sortMessages,
  }) : super(key: key);

  @override
  _BlueshiftInboxState createState() => _BlueshiftInboxState();
}

class _BlueshiftInboxState extends State<BlueshiftInbox> {
  late StreamSubscription<String> _inboxEventStream;
  List<BlueshiftInboxMessage> _inboxMessages = [];
  bool _isInAppLoading = false;
  String? _cachedInAppScreenName;

  void getInboxMessagesFromCache() {
    Blueshift.getInboxMessages().then((messages) {
      if (widget.sortMessages != null) {
        messages.sort((a, b) => widget.sortMessages!(a,b),);
      } else {
        if (Platform.isAndroid) {
          messages.sort((a, b) => b.createdAt.compareTo(a.createdAt),);
        }
      }

      setState(() => _inboxMessages = messages);
    });
  }

  void handleIOSInAppRegistrationInit(String? screenName) {
    if (screenName != null && screenName != "") {
      _cachedInAppScreenName = screenName;
      Blueshift.unregisterForInAppMessage();
    }
  }

  void handleIOSInAppRegistrationCleanup() {
    if (_cachedInAppScreenName != null) {
      Blueshift.registerForInAppMessage(_cachedInAppScreenName!);
      _cachedInAppScreenName = null;
    }
  }

  void handleAndroidInAppRegistrationInit(String? screenName) {
    _cachedInAppScreenName = screenName;
    Blueshift.registerForInAppMessage("blueshift_inbox");
  }

  Future<void> handleAndroidInAppRegistrationCleanup() async {
    await Blueshift.unregisterForInAppMessage();

    /// If _cachedInAppScreenName is null, the host app may not have
    /// registered any screen for in-app display. Having this check
    /// will prevent doing an unintentional call to registerForInAppMessage().
    if (_cachedInAppScreenName != null) {
      await Blueshift.registerForInAppMessage(_cachedInAppScreenName!);
    }
  }

  void handleInitState() {
    Blueshift.getRegisteredInAppScreenName().then((screenName) {
      if (Platform.isIOS) {
        handleIOSInAppRegistrationInit(screenName);
      } else if (Platform.isAndroid) {
        handleAndroidInAppRegistrationInit(screenName);
      }
    });
  }

  void handleDispose() {
    if (Platform.isIOS) {
      handleIOSInAppRegistrationCleanup();
    } else if (Platform.isAndroid) {
      handleAndroidInAppRegistrationCleanup();
    }
  }

  Future<void> getInboxMessagesFromApi() async {
    return await Blueshift.syncInboxMessages();
  }

  Widget inboxLoadingIndicator() {
    return Center(
      child: widget.loadingIndicator ?? const CircularProgressIndicator(),
    );
  }

  Widget inboxWithPullToRefresh() {
    return RefreshIndicator(
      child: inboxWithPlaceholder(),
      onRefresh: () => getInboxMessagesFromApi(),
    );
  }

  Widget inboxPlaceholder() {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) => SizedBox(
        height: 200,
        child: Center(
          child: widget.placeholder ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget inboxWithPlaceholder() {
    return _inboxMessages.isEmpty ? inboxPlaceholder() : inbox();
  }

  void showInboxMessage(BlueshiftInboxMessage message) {
    setState(() => _isInAppLoading = true);
    Blueshift.showInboxMessage(message);
  }

  StreamSubscription<String> registerForInboxDataChangeEvents() {
    return Blueshift.getInstance.onInboxDataChanged.listen((event) {
      switch (event) {
        case Blueshift.kInboxDataChangeEvent:
          getInboxMessagesFromCache();
          break;
        case Blueshift.kInAppLoadEvent:
          setState(() => _isInAppLoading = false);
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    handleInitState();
    _inboxEventStream = registerForInboxDataChangeEvents();
    getInboxMessagesFromCache();
    getInboxMessagesFromApi();
  }

  @override
  void dispose() {
    _inboxEventStream.cancel();
    handleDispose();
    super.dispose();
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

  Widget inbox() {
    return ListView.separated(
      itemCount: _inboxMessages.length,
      separatorBuilder: (context, index) => Divider(
        color: widget.dividerColor,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
        final inboxMessage = _inboxMessages[index];

        return Dismissible(
            // Provide a unique key for each item
            key: Key(inboxMessage.messageId),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              // Handle the dismiss event here
              setState(() => _inboxMessages.removeAt(index));
              Blueshift.deleteInboxMessage(inboxMessage)
                  .then((value) {})
                  .onError((error, stackTrace) {
                getInboxMessagesFromCache();
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
                      detailsTextStyle: widget.detailsTextStyle ??
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
          inboxWithPullToRefresh(),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      details.trim(),
                      style: detailsTextStyle,
                    ),
                  ),
                if (dateString.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      dateString.trim(),
                      style: dateTextStyle,
                    ),
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
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  width: 56,
                  height: 56,
                ),
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
