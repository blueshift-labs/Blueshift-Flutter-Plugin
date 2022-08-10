# Android Plugin Integration

## 1. SDK Integration

### Install Blueshift Android SDK

To install the Blueshift Android SDK, add the following line to the app level `build.gradle` file. To know the latest version, check the [releases](https://github.com/blueshift-labs/Blueshift-Android-SDK/releases) page on **GitHub**. 

```groovy
implementation "com.blueshift:android-sdk-x:$sdkVersion"
```

### Install Firebase Cloud Messaging

Blueshift uses Firebase Messaging for sending push messages. If not already done, please integrate Firebase Messaging into the project.

If this is the first time that you are integrating FCM with your application, add the following lines of code into the `AndroidManifest.xml` file. This will enable the Blueshift Android SDK to receive the push notification sent from Blueshift servers via Firebase.

```xml
<service
    android:name="com.blueshift.fcm.BlueshiftMessagingService"
    android:exported="true">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

If you have an existing FCM integration, let your `FirebaseMessagingService` class to extend `BlueshiftMessagingService` as mentioned below. This will enable the Blueshift Android SDK to receive the push notification sent from Blueshift servers via Firebase.

```java
public class AwesomeAppMessagingService extends BlueshiftMessagingService {

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        if (BlueshiftUtils.isBlueshiftPushMessage(remoteMessage)) {
            super.onMessageReceived(remoteMessage);
        } else {
            /*
             * The push message does not belong to Blueshift. Please handle it here.
             */
        }
    }

    @Override
    public void onNewToken(String newToken) {
        super.onNewToken(newToken);

        /*
         * Use the new token in your app. the super.onNewToken() call is important
         * for the SDK to do the analytical part and notification rendering.
         * Make sure that it is present when you override onNewToken() method.
         */
    }
}
```

### Permissions

Add the following permissions to the `AndroidManifest.xml` file.

```xml
<!-- Internet permission is required to send events, 
get notifications and in-app messages. -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- Network state access permission is required to detect changes 
in network connection to schedule sync operations. -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Location access permission is required if you want to track the 
location of the user. You can skip this step if you don't want to 
track the user location. -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### Initialize the Native SDK

Open the `MainApplication.java` file and import the following classes.

```java
import com.blueshift.model.Configuration;
import com.blueshift.Blueshift;
```

Now add the following lines inside the `onCreated()` method of `MainApplication` class to initialize the Blueshift SDK.

```java
Configuration configuration = new Configuration();
// Set Blueshift event API key
configuration.setApiKey(YOUR_EVENT_API_KEY);
// Set device-id source to Instance Id and package name combo (highly recommended)
configuration.setDeviceIdSource(Blueshift.DeviceIdSource.INSTANCE_ID_PKG_NAME);

Blueshift.getInstance(this).initialize(configuration);
```

To know more about the other optional configurations, please check [this document](https://developer.blueshift.com/docs/get-started-with-the-android-sdk#optional-configurations).

## 2. Push Notifications

Push notifications are enabled by default. You should be able to receive push notifications by now if you have followed the steps mentioned above.

To enable deeplinking from push notification, follow the below steps.

Open the `MainActivity.java` file and import the following classes.

```java
import android.content.Intent;
import android.os.Bundle;
import com.blueshift.reactnative.BlueshiftReactNativeModule;
```

Now add the following code inside the `MainActivity` class to handle push notification deeplinks.

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  BlueshiftReactNativeModule.processBlueshiftPushUrl(getIntent());
}

@Override
public void onNewIntent(Intent intent) {
  super.onNewIntent(intent);
  BlueshiftReactNativeModule.processBlueshiftPushUrl(getIntent());
}
```

## 3. In-app messaging

By default, In-app messages are disabled in the SDK. You will need to enable it explicitly using the Blueshift config during SDK initialization.

Add the following lines before calling the initialize method mentioned in the "Initialize the Native SDK" section above.

```java
// Enable in-app messages
configuration.setInAppEnabled(true);
configuration.setJavaScriptForInAppWebViewEnabled(true);
```

By default, the time interval between two in-app messages is one minute. You can use the following method to change this interval during the SDK initialization.

```java
configuration.setInAppInterval(1000 * 60 * 2); // This will set the interval to two minutes.
```

### In-app display options.

The app must register/whitelist its pages/screens to show in-app messages.

#### 1. Show on all pages

To whitelist all pages/screens make use of `ActivityLifecycleCallback` as mentioned below.

```java
public class YourApplication extends Application implements Application.ActivityLifecycleCallbacks {
  
    @Override
    public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {
      
    }
  
    @Override
    public void onActivityStarted(@NonNull Activity activity) {
        Blueshift.getInstance(activity).registerForInAppMessages(activity);
    }
  
    @Override
    public void onActivityResumed(@NonNull Activity activity) {
      
    }
  
    @Override
    public void onActivityPaused(@NonNull Activity activity) {
      
    }
  
    @Override
    public void onActivityStopped(@NonNull Activity activity) {
        Blueshift.getInstance(activity).unregisterForInAppMessages(activity);
    }
  
    @Override
    public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {
      
    }
  
    @Override
    public void onActivityDestroyed(@NonNull Activity activity) {
      
    }
}
```

#### 2. Show on selected pages

To register selected screens of the react native application, make use of the following methods in the respective callacks.

```js
 componentDidMount() { 
    // Register for in-app notification
    Blueshift.registerForInAppMessage("ScreenName");
  }
  
 componentWillUnmount() {
    // Unregister for in-app notification
    Blueshift.unregisterForInAppMessage();
 }
```

## 4. Blueshift Deep Links

Blueshift’s deep links are usual https URLs that take users to an installed app or a web browser to show the content. If an email or text message that we send as a part of a campaign contains Blueshift deep links and a user clicks on it, the OS will launch the installed app and Blueshift SDK will deliver the deep link to the app to navigate the user to the respective screen.

To enable the domain verification, follow the steps mentioned in [this](https://developer.blueshift.com/docs/integrate-blueshifts-universal-links-android) document's **Prerequisite** section.

To open the app when someone clicks the link, add the following intent filter to the `<activity>` tag for your `MainActivity` inside your `AndroidManifest.xml` file. Make sure to replace `links.clientdomain.com` with your email domain name.

```xml
<intent-filter
    android:autoVerify="true"
    tools:targetApi="m">
    <action android:name="android.intent.action.VIEW" />

    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <data
        android:host="links.clientdomain.com"
        android:pathPrefix="/track"
        android:scheme="https" />
    <data
        android:host="links.clientdomain.com"
        android:pathPrefix="/z"
        android:scheme="https" />
</intent-filter>
```

## Logging

To verify the SDK integration, enable the logging and see the events are being sent to the Blueshift APIs.

Open the `MainActivity.java` file and import the following class.

```java
import com.blueshift.BlueshiftLogger;
```

Now add the below lines before the SDK initialization code for enabling SDK logs.

```java
// Enable logging to view SDK logs in logcat window.
if (BuildConfig.DEBUG) {
  // You must disable logging in production.
  BlueshiftLogger.setLogLevel(BlueshiftLogger.VERBOSE);
}
```
