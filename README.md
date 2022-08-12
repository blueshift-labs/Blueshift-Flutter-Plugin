# Blueshift Flutter Plugin

Flutter plugin for integrating Blueshift's iOS and Android SDKs to your Flutter application.

## Installation

```shell
$ fluter pub get blueshift-flutter-plugin
```

## Android and iOS Integration

Refer to the below documents to integrate the Blueshift SDK for Android and iOS.

- [Android SDK Integration](./Android.md)
- [iOS SDK Integration](./iOS.md)

## Usage

Import the Blueshift plugin to your Dart code.

```dart
import 'package:blueshift_plugin/blueshift_plugin.dart';
```

Once imported, you can call the Blueshift plugin's methods as mentioned below.

```dart
/// Make a call to Blueshift functions
Blueshift.setUserInfoEmailId("test@blueshift.com");
Blueshift.identifyWithDetails(
  {"user_type": "premium", "country": "US", "timezone": "PST"},
);
```

Refer to [these Blueshift Dart methods]() [Link to be added] to know about features and methods supported by the plugin and how to use them.

### Storing user info

Once a user is logged-in to the app, the app is recommended to store their info inside the Blueshift plugin's user info class. This will help in sending the same info in each event fired by the plugin. It is important to remove this cached information when the user logs out.

Blueshift uses the following user identifiers to merge the events under a customer profile. If an event comes without any of these identifiers, it will be discarded.

- Device ID - A unique identifier for each devices/app installs. This value is generated and captured by the SDK automatically.
- Email ID - Email address of the logged-in user. The email id needs to be updated in the user info whenever it changes.
- Customer ID - A unique customer identifier. The customer id needs to be updated in the user info whenever it changes.

```dart
/// Set data on successful login
Blueshift.setUserInfoEmailId("test@blueshift.com");
Blueshift.setUserInfoCustomerId("customer123456");

/// Set other user info as below. This info will be used for creating 
/// segments or running personalized campaigns 
Blueshift.setUserInfoFirstName("John");
Blueshift.setUserInfoLastName("Carter");

/// Add any extra information you would like to capture.
Blueshift.setUserInfoExtras({
  "profession":"software engineer", 
  "premium_user":true
});
```

When the user logs-out, we must clear the cached user info.
```dart
Blueshift.removeUserInfo();
```
Make sure you fire an `identify` event after making changes to the user data to update it on the Blueshift server.

### The identify event
The `identify` event is responsible for updating the data in the customer's profile on the Blueshift server. Whenever you make a change to the customer profile attributes using the Blueshift plugin, we recommend you to fire an `identify` event to reflect those changes on the Blueshift server.

```dart
/// Identify event with custom (optional) data
Blueshift.identifyWithDetails({
  "country": "US",
  "timezone":"PST"
});
```

### Sending custom Event
You could fire custom events with custom data to Blueshift using the plugin.

```dart
Blueshift.trackCustomEvent("name_of_event", {}, false);
```

### Messaging opt in/out

Blueshift plugin provides option to change opt-in status for push notifications and in-app messages. When a user logs out of the app, we must opt them out of messaging. When someone logs in, we should let them opt-in.

#### Push Notifications

Use Blueshift plugin to change the opt-in status of push notifications. Once modified, you must fire an `identify` event to Blueshift to update the customer profile.

```dart
/// set the preference for push notification
Blueshift.setEnablePush(false);

/// fire identify event
Blueshift.identifyWithDetails({});
```
#### In-app Messages

Use Blueshift plugin to change the opt-in status of in-app messages. Once modified, you must fire an `identify` event to Blueshift to update the customer profile.

```dart
/// set the preference for in-app message
Blueshift.setEnableInApp(false);

/// fire identify event
Blueshift.identifyWithDetails({});
```

### Request push notification permission

#### iOS

Blueshift SDK registers for iOS push notifications automatically after the app launch. If you don't want the push notification permission to be displayed immediately on the app launch, you can customize it to display it later after sign up/sign in. To do that you need to set the `config.enablePushNotification` as `false` in your **Xcode project** while initializing the Blueshift Plugin.

```objective-c
// Disable push notifications in the SDK configuration 
// to delay the Push notification permission dialog
[config setEnablePushNotification:NO];
```

You can invoke the below plugin method from your **Flutter code** when you want to register for push notifications and show the push notification dialog to the user.

```dart
/// Register for remote notifications using SDK. 
/// Calling this method will show push permission dialogue to the user.
Blueshift.requestPushNotificationPermission();
```

#### Android

Android 13 and above required explicit consent from the user to show notification. The method below asks for permission from the user. However if your app is not targeting Android 13, then the OS will ask for the notification permission on the app's first launch.

```dart
/// This will bring up the OS's notification permission dialog
/// if you deny the permission two times, this will take you to
/// settings page for enabling notifications
Blueshift.requestPushNotificationPermission();
```

You must also add the following permission to your `AndroidManifest.xml` to be able to request the permission.

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### In-App Notifications

Once you enable the in-app notifications from the SDK as mentioned in the Android and iOS set-up documents, you will need to register the screens in order to see in-app messages. You can register the screens in two ways.

- **Register all screens** Refer to the Android and iOS integration documents to register all screens to receive in-app notifications. After completing this set up, in-app can be displayed on any screen when it is availble to display.

- **Register and unregister each screen** of your Flutter project for in-app messages. If you don’t register a screen for in-app messages, the in-app messages will stop showing up for screens that are not registered.

```dart
/// Register for in-app notification
Blueshift.registerForInAppMessage("HomeScreen");
 
/// Unregister for in-app notification
Blueshift.unregisterForInAppMessage();
```

### Deep Link Event Listener

Blueshift's plugin will take care of delivering the deep link added inside the push and in-app notifications to the Flutter once the user interacts with the notification.

Blueshift plugin will also take care of handling the email deep links. Email deep links are basically App Links for Android and Universal Links for iOS. To enable the App Links and Universal Links you need to set them up as mentioned in the Android and iOS integration document.

Blueshift plugin will deliver the deep link to Flutter using the event stream. You will need to add a listener as mentioned below in your project to receive the deep link.

```dart
Blueshift.getInstance.onDeepLinkReceived.listen((String deeplink) {
  print("Blueshift deep link received: " + deeplink);
});
```

When app is brought alive from killed state, use the `getInitialUrl` method to get the URL caused the app start - Android only.

```dart
String url = await Blueshift.getInitialUrl;
/// use the url to navigate the user to the proper screen/widget
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT