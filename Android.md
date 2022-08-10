# Android Plugin Integration

## Initialization

The Blueshift's Android SDK will initialize automatically when the flutter app starts. You need to provide the required configuration in the form of `meta-data` inside `AndroidManifest.xml` to successfully initialize the SDK.

### Mandatory Configuration

Obtain the event api key from Blueshift's dashboard and supply it as mentioned below.

```xml
<meta-data
    android:name="com.blueshift.config.API_KEY"
    android:value="${blueshiftApiKey}" />
```

### Optional configurations

If you are using Blueshift only for capturing events, skip to the [next section](). Curious minds can read along.

#### Region

The region of the Blueshift's data center.

Supported values: `US` , `EU`. 

Default value: `US`

```xml
<meta-data
    android:name="com.blueshift.config.REGION"
    android:value="EU" />
```

#### In-app messages

To enable in-app messages, enable the following two configurations in your AndroidManifest file.

```xml
<meta-data
    android:name="com.blueshift.config.ENABLE_IN_APP"
    android:value="true" />
```

In-app messages also support HTML content. To support JavaScript code execution, you should enable the following flag as well.

```xml
<meta-data
    android:name="com.blueshift.config.ENABLE_IN_APP_JS"
    android:value="true" />
```

##### Configure in-app interval

The interval between two in-app messages in seconds. The default value is 60 seconds (1 minute).

```xml
<meta-data
    android:name="com.blueshift.config.IN_APP_INTERVAL"
    android:value="300" />
```

##### Manual trigger

In-app manual trigger is disabled by default. To change it, use the following configuration.

```xml
<meta-data
    android:name="com.blueshift.config.ENABLE_IN_APP_MANUAL_TRIGGER"
    android:value="true" />
```

##### Background fetch

In-app background fetch is enabled by default. To change it, use the following configuration.

```xml
<meta-data
    android:name="com.blueshift.config.ENABLE_IN_APP_BACKGROUND_FETCH"
    android:value="true" />
```

#### Batch interval

The plugin supports sending events in realtime and in batches of 100. Configure the time interval between batch events (in seconds) as given below. To know more, visit [the documentation](https://developer.blueshift.com/docs/get-started-with-the-android-sdk#batched-events-time-interval).

```xml
<meta-data
    android:name="com.blueshift.config.BATCH_INTERVAL"
    android:value="54000" />
```

#### Push Notification

Push notifications are enabled by default. To disable the same, use the below config.

**Note:** This is a client side setting. To change this an app update would be required.

```xml
<meta-data
    android:name="com.blueshift.config.ENABLE_PUSH"
    android:value="true" />
```

##### Notification Small Icon

The small icon on the notification can be configured as mentioned below.

```xml
<meta-data
    android:name="com.blueshift.config.NOTIFICATION_ICON_SMALL"
    android:resource="@mipmap/ic_launcher" />
```

##### Notification Big Icon

The big icon on the notification can be configured as mentioned below.

```xml
<meta-data
    android:name="com.blueshift.config.NOTIFICATION_ICON_BIG"
    android:resource="@mipmap/ic_launcher" />
```

##### Notification Color

The color of notification can be customised as per the app's theme here. To add a new colour, add it as a resource inside the android project.

*res/values/colors.xml*

```xml
<color name="notificationColor">#ff32ff</color>
```

Now, use the reference as mentioned below.

```xml
<meta-data
    android:name="com.blueshift.config.NOTIFICATION_ICON_COLOR"
    android:resource="@color/notificationColor" />
```

##### Notification Channel

On Android 8 and above, a notification channel is required to show notification. Blueshift has default channel for push notification, to customise it based on the app's needs, follow the steps below.

###### Notification Channel ID

```xml
<meta-data
    android:name="com.blueshift.config.NOTIFICATION_CHANNEL_ID"
    android:value="DefaultChannelId" />
```

###### Notification Channel Name

```xml
<meta-data
    android:name="com.blueshift.config.NOTIFICATION_CHANNEL_NAME"
    android:value="DefaultChannelName" />
```

###### Notification Channel Description 

```xml
<meta-data
    android:name="com.blueshift.config.NOTIFICATION_CHANNEL_DESCRIPTION"
    android:value="DefaultChannelDescription" />
```

##### Push App Links

By default the sdk opens the app and delivers the deep link when someone clicks on the push notification. To change this, use the following config.

```xml
<meta-data
    android:name="com.blueshift.config.ENABLE_PUSH_APP_LINKS"
    android:value="true" />
```

When enabled, the sdk will try to open the deep link based on App Link configuration. All App Links will open the app and rest of the links will open default browser.

#### App Icon

The app icon is used as backup when notification icons are provided. If not provided, the SDK will try to get this value automatically.

```xml
<meta-data
    android:name="com.blueshift.config.APP_ICON"
    android:resource="@mipmap/ic_launcher" />
```

#### Device ID source

The SDK uses a combination of Firebase Installation ID and package name as the default device id. To change this, use the below setting.

```xml
<meta-data
    android:name="com.blueshift.config.DEVICE_ID_SOURCE"
    android:value="INSTANCE_ID" />
```

Supported values are, `INSTANCE_ID` , `INSTANCE_ID_PKG_NAME` , `GUID` , and `CUSTOM`

##### Custom device ID

When the device id source is `CUSTOM` , use the following config to suppy the custom device id.

```xml
<meta-data
    android:name="com.blueshift.config.CUSTOM_DEVICE_ID"
    android:value="${customDeviceId}" />
```

#### Handle the Job ID conflict

If the job ID of Blueshift's job scheduler conflicts with your app's job scheduler's job ID, change it as follows

```xml
<meta-data
    android:name="com.blueshift.config.JOB_ID_BULK_EVENT"
    android:value="911" />
```

```xml
<meta-data
    android:name="com.blueshift.config.JOB_ID_NETWORK_CHANGE"
    android:value="911" />
```

