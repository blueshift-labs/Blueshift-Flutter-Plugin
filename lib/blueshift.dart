import 'dart:async';

import 'package:flutter/services.dart';

class Blueshift {
  static const MethodChannel _methodChannel =
      MethodChannel('blueshift/methods');
  static const EventChannel _eventChannel =
      EventChannel('blueshift/deeplink_event');

  static final Blueshift _instance = Blueshift();

  static Blueshift get getInstance => _instance;

  /// Get the [Stream] of deep link URLs from push, in-app, and email.
  ///
  /// ```dart
  /// Blueshift.getInstance.onDeepLinkReceived.listen((String url) {
  ///   navigateToDeepLinkPage(url);
  /// });
  /// ```
  Stream<String> get onDeepLinkReceived {
    return _eventChannel.receiveBroadcastStream().cast<String>();
  }

  /// Returns the deep link URL, that caused the app launch from killed state.
  ///
  /// ```dart
  /// String url = await Blueshift.getInitialUrl;
  /// ```
  static Future<String> get getInitialUrl async {
    return await _methodChannel.invokeMethod(
      'getInitialUrl',
    );
  }

  /// Method to capture custom events.
  ///
  /// ```dart
  /// Blueshift.trackCustomEvent('eventName', { 'key' : 'val' }, false);
  /// ```
  static Future<void> trackCustomEvent(
    String eventName,
    Map<String, dynamic> details,
    bool isBatch,
  ) async {
    return await _methodChannel.invokeMethod(
      'trackCustomEvent',
      {'eventName': eventName, 'eventData': details, 'isBatch': isBatch},
    );
  }

  /// Method to capture screen view events (pageload)
  ///
  /// ```dart
  /// Blueshift.trackScreenView('screenName', { 'key' : 'val' }, false);
  /// ```
  static Future<void> trackScreenView(
    String screenName,
    Map<String, dynamic> details,
    bool isBatch,
  ) async {
    return await _methodChannel.invokeMethod(
      'trackScreenView',
      {'screenName': screenName, 'eventData': details, 'isBatch': isBatch},
    );
  }

  /// Sends an identify event to Blueshift, along with extra event data.
  ///
  /// ```dart
  /// Blueshift.identifyWithDetails({ 'key' : 'val' });
  /// ```
  static Future<void> identifyWithDetails(Map<String, dynamic> details) async {
    return await _methodChannel.invokeMethod(
      'identifyWithDetails',
      {'eventData': details},
    );
  }

  /// Register a screen for showing in-app message.
  ///
  /// ```dart
  /// Blueshift.registerForInAppMessage('screenName');
  /// ```
  static Future<void> registerForInAppMessage(String screenName) async {
    return await _methodChannel.invokeMethod(
      'registerForInAppMessage',
      {'screenName': screenName},
    );
  }

  /// Unregister a screen for showing in-app message.
  ///
  /// ```dart
  /// Blueshift.unregisterForInAppMessage();
  /// ```
  static Future<void> unregisterForInAppMessage() async {
    return await _methodChannel.invokeMethod(
      'unregisterForInAppMessage',
    );
  }

  /// Call the in-app API and fetch the latest in-app messages. The fetched
  /// in-app messages will be stored in the database.
  ///
  /// ```dart
  /// Blueshift.fetchInAppNotification();
  /// ```
  static Future<void> fetchInAppNotification() async {
    return await _methodChannel.invokeMethod(
      'fetchInAppNotification',
    );
  }

  /// Displays the eligible in-app message.
  ///
  /// ```dart
  /// Blueshift.displayInAppNotification();
  /// ```
  static Future<void> displayInAppNotification() async {
    return await _methodChannel.invokeMethod(
      'displayInAppNotification',
    );
  }

  /// Updates the user info with the [emailId] provided.
  ///
  /// ```dart
  /// Blueshift.setUserInfoEmailId('user@example.com');
  /// ```
  static Future<void> setUserInfoEmailId(String emailId) async {
    return await _methodChannel.invokeMethod(
      'setUserInfoEmailId',
      {'emailId': emailId},
    );
  }

  /// Return the email address stored inside the user info.
  ///
  /// ```dart
  /// String email = await Blueshift.getUserInfoEmailId;
  /// ```
  static Future<String> get getUserInfoEmailId async {
    final String emailId = await _methodChannel.invokeMethod(
      'getUserInfoEmailId',
    );
    return emailId;
  }

  /// Updates the user info with the [customerId] provided.
  ///
  /// ```dart
  /// Blueshift.setUserInfoCustomerId('customer_123');
  /// ```
  static Future<void> setUserInfoCustomerId(String customerId) async {
    return await _methodChannel.invokeMethod(
      'setUserInfoCustomerId',
      {'customerId': customerId},
    );
  }

  /// Return the customer id stored inside the user info.
  ///
  /// ```dart
  /// String customerId = await Blueshift.getUserInfoCustomerId;
  /// ```
  static Future<String> get getUserInfoCustomerId async {
    final String customerId = await _methodChannel.invokeMethod(
      'getUserInfoCustomerId',
    );
    return customerId;
  }

  /// Updates the user info with the [extras] provided. This is additional
  /// key-value pair of data about the signed in user.
  ///
  /// ```dart
  /// Blueshift.setUserInfoExtras({ 'profession' : 'SDE' , 'premium' : true });
  /// ```
  static Future<void> setUserInfoExtras(Map<String, dynamic> extras) async {
    return await _methodChannel.invokeMethod(
      'setUserInfoExtras',
      {'extras': extras},
    );
  }

  /// Return the additional data stored inside the user info.
  ///
  /// ```dart
  /// Map<String, dynamic>? extras = await Blueshift.getUserInfoExtras;
  /// ```
  static Future<Map<String, dynamic>?> get getUserInfoExtras async {
    final Map<String, dynamic>? extras = await _methodChannel.invokeMethod(
      'getUserInfoExtras',
    );
    return extras;
  }

  /// Updates the user info with the [firstName] provided.
  ///
  /// ```dart
  /// Blueshift.setUserInfoFirstName('John');
  /// ```
  static Future<void> setUserInfoFirstName(String firstName) async {
    return await _methodChannel.invokeMethod(
      'setUserInfoFirstName',
      {'firstName': firstName},
    );
  }

  /// Return the first name stored inside the user info.
  ///
  /// ```dart
  /// String firstName = await Blueshift.getUserInfoFirstName;
  /// ```
  static Future<String> get getUserInfoFirstName async {
    final String firstName = await _methodChannel.invokeMethod(
      'getUserInfoFirstName',
    );
    return firstName;
  }

  /// Updates the user info with the [lastName] provided.
  ///
  /// ```dart
  /// Blueshift.setUserInfoLastName('Doe');
  /// ```
  static Future<void> setUserInfoLastName(String lastName) async {
    return await _methodChannel.invokeMethod(
      'setUserInfoLastName',
      {'lastName': lastName},
    );
  }

  /// Return the last name stored inside the user info.
  ///
  /// ```dart
  /// String lastName = await Blueshift.getUserInfoLastName;
  /// ```
  static Future<String> get getUserInfoLastName async {
    final String lastName = await _methodChannel.invokeMethod(
      'getUserInfoLastName',
    );
    return lastName;
  }

  /// Clears the cached user info.
  ///
  /// ```dart
  /// Blueshift.removeUserInfo();
  /// ```
  static Future<void> removeUserInfo() async {
    return await _methodChannel.invokeMethod(
      'removeUserInfo',
    );
  }

  /// Helps to do push notification opt in/out.
  ///
  /// ```dart
  /// Blueshift.setEnablePush(true);
  /// ```
  static Future<void> setEnablePush(bool isEnabled) async {
    return await _methodChannel.invokeMethod(
      'setEnablePush',
      {'isEnabled': isEnabled},
    );
  }

  /// Return the status of push notification opt in/out.
  ///
  /// ```dart
  /// bool isEnabled = await Blueshift.getEnablePushStatus;
  /// ```
  static Future<bool> get getEnablePushStatus async {
    return await _methodChannel.invokeMethod(
      'getEnablePushStatus',
    );
  }

  /// Helps to do in-app message opt in/out.
  ///
  /// ```dart
  /// Blueshift.setEnableInApp(true);
  /// ```
  static Future<void> setEnableInApp(bool isEnabled) async {
    return await _methodChannel.invokeMethod(
      'setEnableInApp',
      {'isEnabled': isEnabled},
    );
  }

  /// Return the status of in-app message opt in/out.
  ///
  /// ```dart
  /// bool isEnabled = await Blueshift.getEnableInAppStatus;
  /// ```
  static Future<bool> get getEnableInAppStatus async {
    return await _methodChannel.invokeMethod(
      'getEnableInAppStatus',
    );
  }

  /// Enable/disable the event tracking capability of the plugin.
  ///
  /// ```dart
  /// Blueshift.setEnableTracking(true);
  /// ```
  static Future<void> setEnableTracking(bool isEnabled) async {
    return await _methodChannel.invokeMethod(
      'setEnableTracking',
      {'isEnabled': isEnabled},
    );
  }

  /// Return the status of event tracking.
  ///
  /// ```dart
  /// bool isEnabled = await Blueshift.getEnableTrackingStatus;
  /// ```
  static Future<bool> get getEnableTrackingStatus async {
    return await _methodChannel.invokeMethod(
      'getEnableTrackingStatus',
    );
  }

  /// iOS SDK won't collect the IDFA automatically. To track the same,
  /// please supply the IDFA value as [idfaString] to the plugin.
  ///
  /// ```dart
  /// Blueshift.setIDFA(idfa);
  /// ```
  static Future<void> setIDFA(String idfaString) async {
    return await _methodChannel.invokeMethod(
      'setIDFA',
      {'idfaString': idfaString},
    );
  }

  /// iOS SDK won't collect the location automatically. To track the same,
  /// please supply the [latitude] and [longitude] values to the plugin.
  ///
  /// ```dart
  /// Blueshift.setCurrentLocation(37.7576792,-122.5078115);
  /// ```
  static Future<void> setCurrentLocation(
    double latitude,
    double longitude,
  ) async {
    return await _methodChannel.invokeMethod(
      'setCurrentLocation',
      {'latitude': latitude, 'longitude': longitude},
    );
  }

  /// Fetch live content from Blueshift based on the slot provided.
  ///
  /// ```dart
  /// Future<Map<String,dynamic>> content = await Blueshift.liveContentByEmailId(
  ///   'slotName',
  ///   { 'exec_context' : 'exec_context_value' },
  /// );
  /// ```
  static Future<Map<String, dynamic>> liveContentByEmailId(
    String slot,
    Map<String, dynamic> context,
  ) async {
    dynamic response = await _methodChannel.invokeMethod(
      'liveContentByEmailId',
      {'slot': slot, 'context': context},
    );
    return Map<String, dynamic>.from(response);
  }

  /// Fetch live content from Blueshift based on the slot provided.
  ///
  /// ```dart
  /// Future<Map<String,dynamic>> content = await Blueshift.liveContentByCustomerId(
  ///   'slotName',
  ///   { 'exec_context' : 'exec_context_value' },
  /// );
  /// ```
  static Future<Map<String, dynamic>> liveContentByCustomerId(
    String slot,
    Map<String, dynamic> context,
  ) async {
    dynamic response = await _methodChannel.invokeMethod(
      'liveContentByCustomerId',
      {'slot': slot, 'context': context},
    );
    return Map<String, dynamic>.from(response);
  }

  /// Fetch live content from Blueshift based on the slot provided.
  ///
  /// ```dart
  /// Future<Map<String,dynamic>> content = await Blueshift.liveContentByDeviceId(
  ///   'slotName',
  ///   { 'exec_context' : 'exec_context_value' },
  /// );
  /// ```
  static Future<Map<String, dynamic>> liveContentByDeviceId(
    String slot,
    Map<String, dynamic> context,
  ) async {
    dynamic response = await _methodChannel.invokeMethod(
      'liveContentByDeviceId',
      {'slot': slot, 'context': context},
    );
    return Map<String, dynamic>.from(response);
  }

  /// Return the current device id being used.
  ///
  /// ```dart
  /// String deviceId = await Blueshift.getCurrentDeviceId;
  /// ```
  static Future<String> get getCurrentDeviceId async {
    final String deviceId = await _methodChannel.invokeMethod(
      'getCurrentDeviceId',
    );
    return deviceId;
  }

  /// Reset the current device id. This is only applicable if the device id
  /// source is set to GUID.
  ///
  /// ```dart
  /// Blueshift.resetDeviceId();
  /// ```
  static Future<void> resetDeviceId() async {
    return await _methodChannel.invokeMethod(
      'resetDeviceId',
    );
  }

  /// Request push notification permission on Android and iOS.
  ///
  /// ```dart
  /// Blueshift.requestPushNotificationPermission();
  /// ```
  static Future<void> requestPushNotificationPermission() async {
    return await _methodChannel.invokeMethod(
      'requestPushNotificationPermission',
    );
  }

  /// Checks if the provided push notification payload belongs to Blueshift.
  ///
  /// ```dart
  /// bool isBlueshiftPush = Blueshift.isBlueshiftPushNotification(pushPayload);
  /// ```
  static bool isBlueshiftPushNotification(Map<String, dynamic> payload) {
    return payload.containsKey(
      'bsft_message_uuid',
    );
  }

  /// Use this method for letting Blueshift plugin to handle the push notification
  /// payload received from FCM.
  ///
  /// ```dart
  /// Future<void> _handleRemoteMessage(RemoteMessage message) async {
  ///   Blueshift.handlePushNotification(message.data);
  /// }
  ///
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ///   // https://github.com/firebase/flutterfire/issues/6011
  ///   await FirebaseMessaging.instance.getToken();
  ///   // listen for notification while the app is in foreground.
  ///   FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
  ///   // listen for notification while the app is in background or terminated.
  ///   FirebaseMessaging.onBackgroundMessage(_handleRemoteMessage);
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> handlePushNotification(Map<String, dynamic> data) async {
    return await _methodChannel.invokeMethod(
      'handleDataMessage',
      {'data': data},
    );
  }

  /// Checks if the provided deep link URL belongs to Blueshift.
  ///
  /// ```dart
  /// bool isBlueshiftUrl = Blueshift.isBlueshiftUrl(url);
  /// ```
  static bool isBlueshiftUrl(String url) {
    Uri uri = Uri.parse(url);
    bool hasBsftPath = uri.pathSegments.isNotEmpty &&
        (uri.pathSegments[0] == 'z' || uri.pathSegments[0] == 'track');
    bool hasBsftParams = uri.queryParameters.containsKey('uid') &&
        uri.queryParameters.containsKey('mid');
    return hasBsftPath && hasBsftParams;
  }
}
