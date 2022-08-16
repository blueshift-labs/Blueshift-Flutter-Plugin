# Blueshift Flutter Plugin

Flutter plugin for integrating Blueshift's iOS and Android SDKs to your Flutter application.

## Installation

```shell
$ fluter pub add blueshift-plugin
```

## Android and iOS Integration

Refer to the [Flutter Plugin Integration](https://developer.blueshift.com/docs/install-and-set-up-flutter-plugin) guide to integrate the Blueshift SDK for Android and iOS.

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

Refer to [these Blueshift Dart methods](./lib/blueshift_plugin.dart) to know about features and methods supported by the plugin and how to use them.

## License

MIT
