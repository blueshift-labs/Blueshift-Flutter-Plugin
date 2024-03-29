import 'dart:async';
import 'dart:io';

import 'package:blueshift_flutter_plugin_example/pages/deeplink_page.dart';
import 'package:blueshift_plugin/blueshift_plugin.dart';
import 'package:flutter/material.dart';

import '../utils/routes.dart';
import '../widgets/drawer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? deviceId = "";
  String? firstName = "";
  String? emailId = "";
  String? customerId = "";
  String? lastName = "";
  String customEventName = "bsft_send_me_push";
  String? liveContent = "Live content will be populated here..";
  bool enableInApp = true;
  bool enablePush = true;
  bool enableTracking = true;
  final String liveContentSlot = "careinappmessagingslot";

  final _custIdController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _deviceIdController = TextEditingController();

  late StreamSubscription<String> deepLinkStream;
  late StreamSubscription<String> inboxStream;

  Future<int>? messageCount = Blueshift.getUnreadInboxMessageCount();

  @override
  void initState() {
    super.initState();
    getDefaults();

    deepLinkStream = Blueshift.getInstance.onDeepLinkReceived.listen(
      (String event) {
        print("deep link");
        navigateToDeepLinkPage(event);
      },
    );

    inboxStream = Blueshift.getInstance.onInboxDataChanged.listen(
      (String event) {
        if (event == Blueshift.kInboxDataChangeEvent) {
          setState(() {
            messageCount = Blueshift.getUnreadInboxMessageCount();
          });
        }
      },
    );
    handleInitialURL();
  }

  @override
  void deactivate() {
    super.deactivate();
    deepLinkStream.cancel();
    inboxStream.cancel();
    _custIdController.dispose();
    _lastNameController.dispose();
    _deviceIdController.dispose();
  }

  void getDefaults() async {
    customerId = await Blueshift.getUserInfoCustomerId;
    lastName = await Blueshift.getUserInfoLastName;
    deviceId = await Blueshift.getCurrentDeviceId;
    enablePush = await Blueshift.getEnablePushStatus;
    enableInApp = await Blueshift.getEnableInAppStatus;
    enableTracking = await Blueshift.getEnableTrackingStatus;
    emailId = await Blueshift.getUserInfoEmailId;
    firstName = await Blueshift.getUserInfoFirstName;

    setState(() {
      enablePush;
      enableInApp;
      enableTracking;
      _lastNameController.text = lastName!;
      _custIdController.text = customerId!;
      _deviceIdController.text = deviceId!;
      emailId;
      firstName;
    });
  }

  handleInitialURL() async {
    String url = await Blueshift.getInitialUrl;
    navigateToDeepLinkPage(url);
  }

  void showInbox() {
    Navigator.pushNamed(context, MyRoutes.inboxRoute);
  }

  void syncInbox() {
    Blueshift.syncInboxMessages();
  }

  navigateToDeepLinkPage(String url) {
    if (url.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeeplinkPage(
            deeplink: url,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 16),
      minimumSize: const Size.fromHeight(50),
      padding: const EdgeInsets.all(10),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Home Page"), actions: [
          FutureBuilder<int>(
            future: messageCount,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Display nothing while loading
              } else if (snapshot.hasError) {
                return Text(
                    'Error'); // Display error message if there is an error
              } else {
                final messageCount = snapshot.data;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        showInbox();
                      },
                      icon: Icon(Icons.message),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          messageCount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ]),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "User info",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  const Text("Email id : "),
                                  Text(emailId!)
                                ]),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  const Text("User first name : "),
                                  Text(firstName != null ? firstName! : "")
                                ]),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        decoration: const InputDecoration(
                                          hintText: "Enter customer id",
                                          label: Text("Enter customer id"),
                                          contentPadding: EdgeInsets.all(20),
                                        ),
                                        onChanged: (value) {
                                          customerId = value;
                                        },
                                        controller: _custIdController,
                                      ),
                                      ElevatedButton(
                                        style: style,
                                        onPressed: () {
                                          if (customerId != null) {
                                            Blueshift.setUserInfoCustomerId(
                                                customerId!);
                                          }
                                        },
                                        child: const Text("Set Customer Id"),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: "Enter user last name",
                                        label: Text("Enter user last name"),
                                        contentPadding: EdgeInsets.all(20),
                                      ),
                                      controller: _lastNameController,
                                      onChanged: (value) {
                                        lastName = value;
                                      },
                                    ),
                                    ElevatedButton(
                                      style: style,
                                      onPressed: () {
                                        if (lastName != null) {
                                          Blueshift.setUserInfoLastName(
                                              lastName!);
                                        }
                                      },
                                      child: const Text("Set User last name"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        style: style,
                                        onPressed: () {
                                          Blueshift.setUserInfoExtras({
                                            "key3": "123",
                                            "key4": false,
                                            "key5": 123
                                          });
                                        },
                                        child: const Text("Set Extras"),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        style: style,
                                        onPressed: () {
                                          Blueshift.setIDFA(
                                              "55DA5E20-4ACF-4C51-868E-CC3C89593405");
                                        },
                                        child: const Text("Set IDFA"),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        style: style,
                                        onPressed: () {
                                          Blueshift.setCurrentLocation(
                                              18.5681377, 73.7734102);
                                        },
                                        child: const Text("Set Location"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Blueshift.removeUserInfo();
                                  },
                                  style: style,
                                  child: const Text("Remove user data"),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  style: style,
                                  child: const Text("Logout"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Events",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    Blueshift.identifyWithDetails(
                                        {"key1": "val1", "key2": "val2"});
                                  },
                                  child: const Text("Send Identify event"),
                                ),
                              ),
                            ),
                            Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: "Enter Custom event name",
                                        label: Text("Custom event Name"),
                                      ),
                                      initialValue: customEventName,
                                      onChanged: (value) {
                                        customEventName = value;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Blueshift.trackCustomEvent(
                                            customEventName, {}, false);
                                      },
                                      style: style,
                                      child: const Text("Send Custom event"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    Blueshift.trackScreenView(
                                        "HomeScreen", {}, false);
                                  },
                                  child: const Text("Track screen view"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: style,
                          onPressed: () {
                            Blueshift.requestPushNotificationPermission();
                          },
                          child:
                              const Text("Register for remote notifications"),
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Opt out/in",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Card(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Switch(
                                      onChanged: (val) {
                                        setState(() {
                                          enableInApp = val;
                                        });
                                      },
                                      value: enableInApp,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Blueshift.setEnableInApp(enableInApp);
                                        },
                                        child:
                                            const Text("Save Enable In App")),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Switch(
                                        value: enablePush,
                                        onChanged: (val) {
                                          setState(() {
                                            enablePush = val;
                                          });
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Blueshift.setEnablePush(enablePush);
                                        },
                                        child: const Text("Save Enable Push")),
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Switch(
                                        value: enableTracking,
                                        onChanged: (val) {
                                          setState(() {
                                            enableTracking = val;
                                          });
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Blueshift.setEnableTracking(
                                              enableTracking);
                                        },
                                        child:
                                            const Text("Save Enable Tracking")),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "In-App notifications",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    Blueshift.fetchInAppNotification();
                                  },
                                  child:
                                      const Text("Fetch in-app notifications"),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    Blueshift.displayInAppNotification();
                                  },
                                  child:
                                      const Text("Display in-app notification"),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    Blueshift.registerForInAppMessage(
                                        "HomeScreen");
                                  },
                                  child: const Text(
                                      "Register for in-app notification"),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    Blueshift.unregisterForInAppMessage();
                                  },
                                  child: const Text(
                                      "Unregister for in-app notifications"),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    syncInbox();
                                  },
                                  child: const Text("Sync Inbox"),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Device Id",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    hintText: "Current Device id",
                                    label: Text("Current Device Id"),
                                  ),
                                  controller: _deviceIdController,
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () {
                                    Blueshift.resetDeviceId();
                                  },
                                  child: const Text("Reset Device Id"),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Live content",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () async {
                                    setState(() {
                                      liveContent = "";
                                    });
                                    Map<String, dynamic> content =
                                        await Blueshift.liveContentByEmailId(
                                            liveContentSlot, {});
                                    setState(() {
                                      liveContent =
                                          content["content"]["html_content"];
                                    });
                                  },
                                  child: const Text("Live content by email id"),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () async {
                                    setState(() {
                                      liveContent = "";
                                    });
                                    Map<String, dynamic> content =
                                        await Blueshift.liveContentByCustomerId(
                                            liveContentSlot, {});
                                    setState(() {
                                      liveContent =
                                          content["content"]["html_content"];
                                    });
                                  },
                                  child:
                                      const Text("Live content by customer id"),
                                ),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: style,
                                  onPressed: () async {
                                    setState(() {
                                      liveContent = "";
                                    });
                                    Map<String, dynamic> content =
                                        await Blueshift.liveContentByDeviceId(
                                            liveContentSlot, {});
                                    setState(() {
                                      liveContent =
                                          content["content"]["html_content"];
                                    });
                                  },
                                  child:
                                      const Text("Live content by device id"),
                                ),
                              ),
                            ),
                            Card(
                              child: Text(liveContent!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        drawer: MyDrawer(email: emailId ?? "", name: firstName ?? ""),
      ),
    );
  }
}
