package com.blueshift.flutter.blueshift_plugin;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;

import androidx.annotation.NonNull;

import com.blueshift.Blueshift;
import com.blueshift.BlueshiftAppPreferences;
import com.blueshift.BlueshiftConstants;
import com.blueshift.BlueshiftExecutor;
import com.blueshift.BlueshiftLinksHandler;
import com.blueshift.BlueshiftLinksListener;
import com.blueshift.BlueshiftLogger;
import com.blueshift.BuildConfig;
import com.blueshift.fcm.BlueshiftMessagingService;
import com.blueshift.inappmessage.InAppManager;
import com.blueshift.inbox.BlueshiftInboxManager;
import com.blueshift.inbox.BlueshiftInboxMessage;
import com.blueshift.model.UserInfo;
import com.blueshift.rich_push.RichPushConstants;
import com.blueshift.util.DeviceUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

/**
 * Blueshift Plugin
 */
public class BlueshiftFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    // TODO: 16/08/22 Change this value on each release.
    @SuppressWarnings("FieldCanBeLocal")
    private final String PLUGIN_VERSION = "1.0.1";
    private final String TAG = "BlueshiftFlutter";
    private Activity appActivity;
    private Context appContext;
    private EventChannel deeplinkEventChannel;
    private EventChannel mobileInboxEventChannel;
    private MethodChannel methodChannel;
    private ActivityPluginBinding activityPluginBinding;
    private EventChannel.EventSink deeplinkEventSink = null;
    private EventChannel.EventSink inboxEventSink = null;
    private String cachedUrl = null;
    private boolean inAppOnAllScreens = false;
    private final PluginRegistry.NewIntentListener newIntentListener = intent -> {
        handleDeepLinks(intent);
        return false;
    };
    private final BroadcastReceiver inboxDataChangeReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            sendInboxDataChangeEvent();
        }
    };

    @Override // FlutterPlugin
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        appContext = flutterPluginBinding.getApplicationContext();

        deeplinkEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "blueshift/deeplink_event");
        mobileInboxEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "blueshift/inbox_event");
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "blueshift/methods");

        deeplinkEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                deeplinkEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                deeplinkEventSink = null;
            }
        }); // EventChannel.StreamHandler

        mobileInboxEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                inboxEventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                inboxEventSink = null;
            }
        }); // EventChannel.StreamHandler

        methodChannel.setMethodCallHandler(this); // MethodCallHandler

        Bundle metaData = getMetaData();
        BlueshiftFlutterRegistrar.initSdk(appContext, metaData);

        if (metaData != null) {
            inAppOnAllScreens = metaData.getBoolean("com.blueshift.config.IN_APP_ON_ALL_SCREENS", false);
        }
    }

    private Bundle getMetaData() {
        String pkgName = appContext.getPackageName();
        PackageManager pkgManager = appContext.getPackageManager();
        try {
            ApplicationInfo applicationInfo = pkgManager.getApplicationInfo(pkgName, PackageManager.GET_META_DATA);
            if (applicationInfo != null && applicationInfo.metaData != null) {
                return applicationInfo.metaData;
            }
        } catch (PackageManager.NameNotFoundException e) {
            BlueshiftLogger.e(TAG, e);
        }

        return null;
    }

    @Override // FlutterPlugin
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        deeplinkEventChannel.setStreamHandler(null);
        mobileInboxEventChannel.setStreamHandler(null);
        methodChannel.setMethodCallHandler(null);
    }

    private void activityInit(@NonNull ActivityPluginBinding binding) {
        appActivity = binding.getActivity();
        handleDeepLinks(appActivity.getIntent());

        activityPluginBinding = binding;
        activityPluginBinding.addOnNewIntentListener(newIntentListener);

        if (inAppOnAllScreens) {
            Blueshift.getInstance(appContext).registerForInAppMessages(appActivity);
        }

        BlueshiftInboxManager.registerForInboxBroadcasts(appActivity, inboxDataChangeReceiver);
    }

    private void activityCleanup() {
        if (activityPluginBinding != null) {
            activityPluginBinding.removeOnNewIntentListener(newIntentListener);
            activityPluginBinding = null;
        }

        if (inAppOnAllScreens) {
            Blueshift.getInstance(appContext).unregisterForInAppMessages(appActivity);
        }

        if (appActivity != null) {
            appActivity.unregisterReceiver(inboxDataChangeReceiver);
        }

        appActivity = null;
    }

    @Override // ActivityAware
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityInit(binding);
    }

    @Override // ActivityAware
    public void onDetachedFromActivityForConfigChanges() {
        activityCleanup();
    }

    @Override // ActivityAware
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activityInit(binding);
    }

    @Override // ActivityAware
    public void onDetachedFromActivity() {
        activityCleanup();
    }

    private void sendDeeplinkEvent(Uri link) {
        if (deeplinkEventSink != null) {
            deeplinkEventSink.success(link != null ? link.toString() : null);
        } else {
            // When eventSink is not ready, cache the URL so that the host app can call
            // getInitialUrl to get the URL whenever it wants.
            cachedUrl = link != null ? link.toString() : null;
        }
    }

    private void handleBlueshiftDeepLink(Uri uri) {
        new BlueshiftLinksHandler(appActivity).handleBlueshiftUniversalLinks(
                uri, null, new BlueshiftLinksListener() {
                    @Override
                    public void onLinkProcessingStart() {
                    }

                    @Override
                    public void onLinkProcessingComplete(Uri link) {
                        sendDeeplinkEvent(link);
                    }

                    @Override
                    public void onLinkProcessingError(Exception e, Uri link) {
                        sendDeeplinkEvent(link);
                    }
                }
        );
    }

    private void handleDeepLinks(Intent intent) {
        if (intent != null) {
            Uri deepLink = intent.getData();
            if (deepLink == null) {
                String pushLink = intent.getStringExtra(RichPushConstants.EXTRA_DEEP_LINK_URL);
                if (pushLink != null && !pushLink.isEmpty()) {
                    BlueshiftLogger.d(TAG, "Deeplink found inside the bundle (deep_link_url).");
                    handleBlueshiftDeepLink(Uri.parse(pushLink));
                }
            } else {
                BlueshiftLogger.d(TAG, "Deeplink found inside the intent data.");
                handleBlueshiftDeepLink(deepLink);
            }
        }
    }

    @Override // MethodCallHandler
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getInitialUrl":
                getInitialUrl(result);
                break;
            case "handleDataMessage":
                handleDataMessage(call);
                break;
            case "identifyWithDetails":
                identifyWithDetails(call);
                break;
            case "trackCustomEvent":
                trackCustomEvent(call);
                break;
            case "trackScreenView":
                trackScreenView(call);
                break;
            case "registerForRemoteNotification":
                registerForRemoteNotification();
                break;
            case "registerForInAppMessage":
                registerForInAppMessage(call);
                break;
            case "unregisterForInAppMessage":
                unregisterForInAppMessage();
                break;
            case "getRegisteredInAppScreenName":
                getRegisteredInAppScreenName(result);
                break;
            case "fetchInAppNotification":
                fetchInAppNotification();
                break;
            case "displayInAppNotification":
                displayInAppNotification();
                break;
            case "setUserInfoEmailId":
                setUserInfoEmailId(call);
                break;
            case "setUserInfoCustomerId":
                setUserInfoCustomerId(call);
                break;
            case "setUserInfoExtras":
                setUserInfoExtras(call);
                break;
            case "setUserInfoFirstName":
                setUserInfoFirstName(call);
                break;
            case "setUserInfoLastName":
                setUserInfoLastName(call);
                break;
            case "removeUserInfo":
                removeUserInfo();
                break;
            case "setEnablePush":
                setEnablePush(call);
                break;
            case "setEnableInApp":
                setEnableInApp(call);
                break;
            case "setEnableTracking":
                setEnableTracking(call);
                break;
            case "setIDFA":
                setIDFA();
                break;
            case "setCurrentLocation":
                setCurrentLocation();
                break;
            case "getEnablePushStatus":
                getEnablePushStatus(result);
                break;
            case "getEnableInAppStatus":
                getEnableInAppStatus(result);
                break;
            case "getEnableTrackingStatus":
                getEnableTrackingStatus(result);
                break;
            case "getUserInfoFirstName":
                getUserInfoFirstName(result);
                break;
            case "getUserInfoLastName":
                getUserInfoLastName(result);
                break;
            case "getUserInfoEmailId":
                getUserInfoEmailId(result);
                break;
            case "getUserInfoCustomerId":
                getUserInfoCustomerId(result);
                break;
            case "getUserInfoExtras":
                getUserInfoExtras(result);
                break;
            case "getCurrentDeviceId":
                getCurrentDeviceId(result);
                break;
            case "liveContentByEmailId":
                liveContentByEmailId(call, result);
                break;
            case "liveContentByCustomerId":
                liveContentByCustomerId(call, result);
                break;
            case "liveContentByDeviceId":
                liveContentByDeviceId(call, result);
                break;
            case "resetDeviceId":
                resetDeviceId();
                break;
            case "requestPushNotificationPermission":
                requestPushNotificationPermission();
                break;
            case "getInboxMessages":
                getInboxMessages(result);
                break;
            case "showInboxMessage":
                showInboxMessage(call);
                break;
            case "syncInboxMessages":
                syncInboxMessages(result);
                break;
            case "deleteInboxMessage":
                deleteInboxMessage(call, result);
                break;
            case "getUnreadInboxMessageCount":
                getUnreadInboxMessageCount(result);
                break;
            default:
                result.notImplemented();
        }
    }

    private HashMap<String, Object> appendVersion(HashMap<String, Object> map) {
        if (map == null) map = new HashMap<>();

        String version = BuildConfig.SDK_VERSION + "-FL-" + PLUGIN_VERSION;
        map.put(BlueshiftConstants.KEY_SDK_VERSION, version);

        return map;
    }

    /**
     * This method is responsible for providing the deep link URL received by the plugin while
     * the app was in killed state or when the event channel was not ready. Once consumed, the
     * cached value will be removed.
     *
     * @param result cached deep link URL (if available)
     */
    private void getInitialUrl(Result result) {
        if (cachedUrl != null) {
            result.success(cachedUrl);
            cachedUrl = null;
        } else {
            result.success("");
        }
    }

    private void handleDataMessage(MethodCall methodCall) {
        HashMap<String, Object> data = methodCall.argument("data");
        if (data != null) {
            Bundle bundle = new Bundle();
            for (String key : data.keySet()) {
                bundle.putString(key, String.valueOf(data.get(key)));
            }

            Intent intent = new Intent();
            intent.putExtras(bundle);

            // do the heavy lifting in background.
            BlueshiftExecutor.getInstance().runOnWorkerThread(() -> BlueshiftMessagingService.handlePushMessage(appContext, intent));
        } else {
            BlueshiftLogger.w(TAG, "data is null.");
        }
    }

    private void identifyWithDetails(MethodCall methodCall) {
        HashMap<String, Object> extras = methodCall.argument("eventData");
        Blueshift.getInstance(appContext).identifyUser(appendVersion(extras), false);
    }

    private void trackCustomEvent(MethodCall methodCall) {
        String event = methodCall.argument("eventName");
        if (event != null) {
            HashMap<String, Object> extras = methodCall.argument("eventData");
            boolean isBatch = Boolean.TRUE.equals(methodCall.argument("isBatch"));

            Blueshift.getInstance(appContext).trackEvent(event, appendVersion(extras), isBatch);
        } else {
            BlueshiftLogger.w(TAG, "Can not send event without an event name.");
        }
    }

    private void trackScreenView(MethodCall methodCall) {
        String screenName = methodCall.argument("screenName");
        boolean isBatch = Boolean.TRUE.equals(methodCall.argument("isBatch"));
        Blueshift.getInstance(appContext).trackScreenView(screenName, isBatch);
    }

    private void registerForRemoteNotification() {
        BlueshiftLogger.d(TAG, "registerForRemoteNotification() - Method not available in Android.");
    }

    private void registerForInAppMessage(MethodCall methodCall) {
        String screenName = methodCall.argument("screenName");
        Blueshift.getInstance(appContext).registerForInAppMessages(appActivity, screenName);
    }

    private void unregisterForInAppMessage() {
        Blueshift.getInstance(appContext).unregisterForInAppMessages(appActivity);
    }

    private void getRegisteredInAppScreenName(Result result) {
        if (result != null) {
            String val = InAppManager.getRegisteredScreenName();
            result.success(val);
        }
    }

    private void fetchInAppNotification() {
        Blueshift.getInstance(appContext).fetchInAppMessages(null);
    }

    private void displayInAppNotification() {
        Blueshift.getInstance(appContext).displayInAppMessages();
    }

    private void setUserInfoEmailId(MethodCall methodCall) {
        String emailId = methodCall.argument("emailId");
        UserInfo.getInstance(appContext).setEmail(emailId);
        UserInfo.getInstance(appContext).save(appContext);
    }

    private void setUserInfoCustomerId(MethodCall methodCall) {
        String customerId = methodCall.argument("customerId");
        UserInfo.getInstance(appContext).setRetailerCustomerId(customerId);
        UserInfo.getInstance(appContext).save(appContext);
    }

    private void setUserInfoExtras(MethodCall methodCall) {
        HashMap<String, Object> extras = methodCall.argument("extras");
        UserInfo.getInstance(appContext).setDetails(extras);
        UserInfo.getInstance(appContext).save(appContext);
    }

    private void setUserInfoFirstName(MethodCall methodCall) {
        String firstName = methodCall.argument("firstName");
        UserInfo.getInstance(appContext).setFirstname(firstName);
        UserInfo.getInstance(appContext).save(appContext);
    }

    private void setUserInfoLastName(MethodCall methodCall) {
        String lastName = methodCall.argument("lastName");
        UserInfo.getInstance(appContext).setLastname(lastName);
        UserInfo.getInstance(appContext).save(appContext);
    }

    private void removeUserInfo() {
        UserInfo.getInstance(appContext).clear(appContext);
    }

    private void setEnablePush(MethodCall methodCall) {
        boolean isEnabled = Boolean.TRUE.equals(methodCall.argument("isEnabled"));
        Blueshift.optInForPushNotifications(appContext, isEnabled);
    }

    private void setEnableInApp(MethodCall methodCall) {
        boolean isEnabled = Boolean.TRUE.equals(methodCall.argument("isEnabled"));
        Blueshift.optInForInAppNotifications(appContext, isEnabled);
    }

    private void setEnableTracking(MethodCall methodCall) {
        boolean isEnabled = Boolean.TRUE.equals(methodCall.argument("isEnabled"));
        Blueshift.setTrackingEnabled(appContext, isEnabled);
    }

    private void setIDFA() {
        BlueshiftLogger.d(TAG, "setIDFA() - Method not available in Android.");
    }

    private void setCurrentLocation() {
        BlueshiftLogger.d(TAG, "setCurrentLocation() - Method not available in Android.");
    }

    private void getEnablePushStatus(Result result) {
        boolean isEnabled = BlueshiftAppPreferences.getInstance(appContext).getEnablePush();
        result.success(isEnabled);
    }

    private void getEnableInAppStatus(Result result) {
        boolean isEnabled = BlueshiftAppPreferences.getInstance(appContext).getEnableInApp();
        result.success(isEnabled);
    }

    private void getEnableTrackingStatus(Result result) {
        boolean isEnabled = Blueshift.isTrackingEnabled(appContext);
        result.success(isEnabled);
    }

    private void getUserInfoFirstName(Result result) {
        String firstName = UserInfo.getInstance(appContext).getFirstname();
        result.success(firstName != null ? firstName : "");
    }

    private void getUserInfoLastName(Result result) {
        String lastName = UserInfo.getInstance(appContext).getLastname();
        result.success(lastName != null ? lastName : "");
    }

    private void getUserInfoEmailId(Result result) {
        String email = UserInfo.getInstance(appContext).getEmail();
        result.success(email != null ? email : "");
    }

    private void getUserInfoCustomerId(Result result) {
        String customerId = UserInfo.getInstance(appContext).getRetailerCustomerId();
        result.success(customerId != null ? customerId : "");
    }

    private void getUserInfoExtras(Result result) {
        result.success(UserInfo.getInstance(appContext).getDetails());
    }

    private void getCurrentDeviceId(Result result) {
        String deviceId = DeviceUtils.getDeviceId(appContext);
        result.success(deviceId != null ? deviceId : "");
    }

    private void liveContentByEmailId(MethodCall methodCall, Result result) {
        String slot = methodCall.argument("slot");
        if (slot != null) {
            HashMap<String, Object> context = methodCall.argument("context");
            Blueshift.getInstance(appContext).getLiveContentByEmail(slot, context, response -> result.success(stringToMap(response)));
        } else {
            BlueshiftLogger.w(TAG, "Can not fetch live content without a slot name.");
        }
    }

    private void liveContentByCustomerId(MethodCall methodCall, Result result) {
        String slot = methodCall.argument("slot");
        if (slot != null) {
            HashMap<String, Object> context = methodCall.argument("context");
            Blueshift.getInstance(appContext).getLiveContentByCustomerId(slot, context, response -> result.success(stringToMap(response)));
        } else {
            BlueshiftLogger.w(TAG, "Can not fetch live content without a slot name.");
        }
    }

    private void liveContentByDeviceId(MethodCall methodCall, Result result) {
        String slot = methodCall.argument("slot");
        if (slot != null) {
            HashMap<String, Object> context = methodCall.argument("context");
            Blueshift.getInstance(appContext).getLiveContentByDeviceId(slot, context, response -> result.success(stringToMap(response)));
        } else {
            BlueshiftLogger.w(TAG, "Can not fetch live content without a slot name.");
        }
    }

    private HashMap<String, Object> stringToMap(String json) {
        try {
            if (json != null) {
                Type type = new TypeToken<HashMap<String, Object>>() {
                }.getType();
                return new Gson().fromJson(json, type);
            }
        } catch (Exception e) {
            BlueshiftLogger.e(TAG, e);
        }

        return new HashMap<>();
    }

    private void resetDeviceId() {
        Blueshift.getInstance(appContext).resetDeviceId();
    }

    private void requestPushNotificationPermission() {
        Blueshift.requestPushNotificationPermission(appActivity);
    }

    private void getInboxMessages(Result result) {
        BlueshiftInboxManager.getMessages(appContext, blueshiftInboxMessages -> {
            HashMap<String, Object> resultMap = new HashMap<>();

            if (blueshiftInboxMessages == null || blueshiftInboxMessages.isEmpty()) {
                BlueshiftLogger.d(TAG, "No messages found inside Mobile Inbox.");

                // return empty list
                resultMap.put("messages", new ArrayList<>());
                result.success(resultMap);
            } else {
                if (result != null) {
                    ArrayList<HashMap<String, Object>> messageList = new ArrayList<>();

                    for (BlueshiftInboxMessage message : blueshiftInboxMessages) {
                        messageList.add(message.toHashMap());
                    }

                    resultMap.put("messages", messageList);
                    result.success(resultMap);
                }
            }
        });
    }

    private void showInboxMessage(MethodCall call) {
        HashMap<String, Object> map = call.argument("message");
        if (map != null) {
            BlueshiftInboxMessage message = BlueshiftInboxMessage.fromHashMap(map);
            BlueshiftInboxManager.displayInboxMessage(message);
        }
    }

    private void deleteInboxMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.argument("message");
        if (map != null) {
            BlueshiftInboxMessage message = BlueshiftInboxMessage.fromHashMap(map);
            BlueshiftInboxManager.deleteMessage(appContext, message, status -> {
                if (status) {
                    result.success(true);
                } else {
                    result.error("error", "Could not delete the message.", null);
                }
            });
        }
    }

    private void syncInboxMessages(Result result) {
        BlueshiftInboxManager.syncMessages(appContext, result::success);
    }

    private void sendInboxDataChangeEvent() {
        if (inboxEventSink != null) {
            inboxEventSink.success("InboxDataChangeEvent");
        }
    }

    private void getUnreadInboxMessageCount(Result result) {
        BlueshiftInboxManager.getUnreadMessagesCount(appContext, result::success);
    }
}
