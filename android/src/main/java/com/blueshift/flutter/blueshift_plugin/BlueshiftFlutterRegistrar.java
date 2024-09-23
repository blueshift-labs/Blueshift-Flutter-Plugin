package com.blueshift.flutter.blueshift_plugin;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import androidx.core.content.ContextCompat;

import com.blueshift.Blueshift;
import com.blueshift.BlueshiftLogger;
import com.blueshift.BlueshiftRegion;
import com.blueshift.model.Configuration;

public class BlueshiftFlutterRegistrar {
    private static final String TAG = "BlueshiftFlutter";
    private static final String PREFIX = "com.blueshift.config.";
    private static final String API_KEY = PREFIX + "API_KEY";
    private static final String REGION = PREFIX + "REGION";
    private static final String APP_ICON = PREFIX + "APP_ICON";
    private static final String ENABLE_PUSH = PREFIX + "ENABLE_PUSH";
    private static final String ENABLE_IN_APP = PREFIX + "ENABLE_IN_APP";
    private static final String ENABLE_INBOX = PREFIX + "ENABLE_INBOX";
    private static final String ENABLE_IN_APP_JS = PREFIX + "ENABLE_IN_APP_JS";
    private static final String IN_APP_INTERVAL = PREFIX + "IN_APP_INTERVAL";
    private static final String BATCH_INTERVAL = PREFIX + "BATCH_INTERVAL";
    private static final String NOTIFICATION_ICON_SMALL = PREFIX + "NOTIFICATION_ICON_SMALL";
    private static final String NOTIFICATION_ICON_BIG = PREFIX + "NOTIFICATION_ICON_BIG";
    private static final String NOTIFICATION_ICON_COLOR = PREFIX + "NOTIFICATION_ICON_COLOR";
    private static final String NOTIFICATION_CHANNEL_ID = PREFIX + "NOTIFICATION_CHANNEL_ID";
    private static final String NOTIFICATION_CHANNEL_NAME = PREFIX + "NOTIFICATION_CHANNEL_NAME";
    private static final String NOTIFICATION_CHANNEL_DESCRIPTION = PREFIX + "NOTIFICATION_CHANNEL_DESCRIPTION";
    private static final String ENABLE_PUSH_APP_LINKS = PREFIX + "ENABLE_PUSH_APP_LINKS";
    private static final String ENABLE_IN_APP_MANUAL_TRIGGER = PREFIX + "ENABLE_IN_APP_MANUAL_TRIGGER";
    private static final String ENABLE_IN_APP_BACKGROUND_FETCH = PREFIX + "ENABLE_IN_APP_BACKGROUND_FETCH";
    private static final String ENABLE_AUTO_APP_OPEN = PREFIX + "ENABLE_AUTO_APP_OPEN";
    private static final String AUTO_APP_OPEN_INTERVAL = PREFIX + "AUTO_APP_OPEN_INTERVAL";
    private static final String JOB_ID_BULK_EVENT = PREFIX + "JOB_ID_BULK_EVENT";
    private static final String JOB_ID_NETWORK_CHANGE = PREFIX + "JOB_ID_NETWORK_CHANGE";
    private static final String DEVICE_ID_SOURCE = PREFIX + "DEVICE_ID_SOURCE";
    private static final String CUSTOM_DEVICE_ID = PREFIX + "CUSTOM_DEVICE_ID";
    private static final String LOG_LEVEL = PREFIX + "LOG_LEVEL";
    private static final String ENCRYPT_USER_INFO = PREFIX + "ENCRYPT_USER_INFO";

    private static void enableSdkLogging(String logLevel) {
        if (logLevel != null) {
            int level = -1;
            switch (logLevel) {
                case "V":
                    level = BlueshiftLogger.VERBOSE;
                    break;
                case "D":
                    level = BlueshiftLogger.DEBUG;
                    break;
                case "I":
                    level = BlueshiftLogger.INFO;
                    break;
                case "W":
                    level = BlueshiftLogger.WARNING;
                    break;
                case "E":
                    level = BlueshiftLogger.ERROR;
                    break;
                default:
                    Log.d(TAG, "Invalid log level supplied: " + logLevel + ". Supported values: V, D, I, W, and E");
            }

            if (level != -1) {
                BlueshiftLogger.setLogLevel(level);
            }
        }
    }

    public static void initSdk(Context context, Bundle metaData) {
        if (context != null && metaData != null && metaData.containsKey(API_KEY)) {
            String apiKey = metaData.getString(API_KEY, null);
            if (apiKey != null && !apiKey.isEmpty()) {
                Configuration config = new Configuration();
                config.setApiKey(apiKey);

                enableSdkLogging(metaData.getString(LOG_LEVEL, null));

                int appIcon = metaData.getInt(APP_ICON, 0);
                if (appIcon > 0) config.setAppIcon(appIcon);

                boolean enablePush = metaData.getBoolean(ENABLE_PUSH, true);
                config.setPushEnabled(enablePush);

                boolean enableInApp = metaData.getBoolean(ENABLE_IN_APP, false);
                config.setInAppEnabled(enableInApp);

                boolean enableInAppJs = metaData.getBoolean(ENABLE_IN_APP_JS, false);
                config.setJavaScriptForInAppWebViewEnabled(enableInAppJs);

                boolean enableInbox = metaData.getBoolean(ENABLE_INBOX, false);
                config.setInboxEnabled(enableInbox);

                long inAppIntervalSeconds = metaData.getInt(IN_APP_INTERVAL, 0);
                if (inAppIntervalSeconds > 0) config.setInAppInterval(inAppIntervalSeconds * 1000L);

                long batchIntervalSeconds = metaData.getInt(BATCH_INTERVAL, 0);
                if (inAppIntervalSeconds > 0) config.setBatchInterval(batchIntervalSeconds * 1000L);

                int notificationIconSmall = metaData.getInt(NOTIFICATION_ICON_SMALL, 0);
                if (inAppIntervalSeconds > 0) config.setSmallIconResId(notificationIconSmall);

                int notificationIconBig = metaData.getInt(NOTIFICATION_ICON_BIG, 0);
                if (inAppIntervalSeconds > 0) config.setSmallIconResId(notificationIconBig);

                int notificationIconColor = metaData.getInt(NOTIFICATION_ICON_COLOR, 0);
                if (inAppIntervalSeconds > 0) {
                    try {
                        int color = ContextCompat.getColor(context, notificationIconColor);
                        config.setNotificationColor(color);
                    } catch (Exception e) {
                        BlueshiftLogger.e(TAG, e);
                    }
                }

                String notificationChannelId = metaData.getString(NOTIFICATION_CHANNEL_ID, null);
                if (notificationChannelId != null) {
                    config.setDefaultNotificationChannelId(notificationChannelId);
                }

                String notificationChannelName = metaData.getString(NOTIFICATION_CHANNEL_NAME, null);
                if (notificationChannelName != null) {
                    config.setDefaultNotificationChannelName(notificationChannelName);
                }

                String notificationChannelDesc = metaData.getString(NOTIFICATION_CHANNEL_DESCRIPTION, null);
                if (notificationChannelDesc != null) {
                    config.setDefaultNotificationChannelName(notificationChannelDesc);
                }

                boolean enablePushAppLinks = metaData.getBoolean(ENABLE_PUSH_APP_LINKS, false);
                config.setPushAppLinksEnabled(enablePushAppLinks);

                boolean enableInAppManualTrigger = metaData.getBoolean(ENABLE_IN_APP_MANUAL_TRIGGER, false);
                config.setInAppManualTriggerEnabled(enableInAppManualTrigger);

                boolean enableInAppBackgroundFetch = metaData.getBoolean(ENABLE_IN_APP_BACKGROUND_FETCH, true);
                config.setInAppBackgroundFetchEnabled(enableInAppBackgroundFetch);

                boolean enableAutoAppOpen = metaData.getBoolean(ENABLE_AUTO_APP_OPEN, true);
                config.setEnableAutoAppOpenFiring(enableAutoAppOpen);

                long autoAppOpenIntervalSeconds = metaData.getInt(AUTO_APP_OPEN_INTERVAL, 0);
                if (autoAppOpenIntervalSeconds > 0) {
                    config.setAutoAppOpenInterval(autoAppOpenIntervalSeconds);
                }

                int jobIdBulkEvent = metaData.getInt(JOB_ID_BULK_EVENT, 0);
                if (jobIdBulkEvent > 0) config.setBulkEventsJobId(jobIdBulkEvent);

                int jobIdNwChange = metaData.getInt(JOB_ID_NETWORK_CHANGE, 0);
                if (jobIdNwChange > 0) config.setBulkEventsJobId(jobIdNwChange);

                String region = metaData.getString(REGION, null);
                if (region != null) {
                    try {
                        config.setRegion(BlueshiftRegion.valueOf(region));
                    } catch (Exception e) {
                        BlueshiftLogger.e(TAG, e);
                    }
                }

                String deviceIdSource = metaData.getString(DEVICE_ID_SOURCE, null);
                if (deviceIdSource != null) {
                    try {
                        config.setDeviceIdSource(Blueshift.DeviceIdSource.valueOf(deviceIdSource));
                    } catch (Exception e) {
                        BlueshiftLogger.e(TAG, e);
                    }
                }

                String customDeviceId = metaData.getString(CUSTOM_DEVICE_ID, null);
                if (customDeviceId != null) {
                    config.setCustomDeviceId(customDeviceId);
                }

                boolean encryptUserInfo = metaData.getBoolean(ENCRYPT_USER_INFO, false);
                config.setSaveUserInfoAsEncrypted(encryptUserInfo);

                Blueshift.getInstance(context).initialize(config);
            } else {
                BlueshiftLogger.w(TAG, "Could not initialize Blueshift SDK. API KEY not found.");
            }
        } else {
            BlueshiftLogger.w(TAG, "Could not initialize Blueshift SDK. Meta data not found.");
        }
    }
}
