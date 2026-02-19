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
import com.blueshift.inappmessage.InAppMessage;
import com.blueshift.inappmessage.InAppMessageStore;
import com.blueshift.inbox.BlueshiftInboxManager;
import com.blueshift.inbox.BlueshiftInboxMessage;
import com.blueshift.inbox.BlueshiftInboxStoreSQLite;
import com.blueshift.model.UserInfo;
import com.blueshift.rich_push.RichPushConstants;
import com.blueshift.util.DeviceUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.json.JSONObject;

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
    private final String PLUGIN_VERSION = "1.2.0";
    private final String TAG = "BlueshiftFlutter";
    private Activity appActivity;
    private Context appContext;
    private EventChannel deeplinkEventChannel;
    private EventChannel mobileInboxEventChannel;
    private EventChannel pushEventsChannel;
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
        pushEventsChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "blueshift/push_click_event");
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

        pushEventsChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
            }

            @Override
            public void onCancel(Object arguments) {
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
                handleDataMessage(call, result);
                break;
            case "identifyWithDetails":
                identifyWithDetails(call, result);
                break;
            case "trackCustomEvent":
                trackCustomEvent(call, result);
                break;
            case "trackScreenView":
                trackScreenView(call, result);
                break;
            case "trackInAppMessageView":
                trackInAppMessageView(call, result);
                break;
            case "registerForRemoteNotification":
                registerForRemoteNotification(result);
                break;
            case "registerForInAppMessage":
                registerForInAppMessage(call, result);
                break;
            case "unregisterForInAppMessage":
                unregisterForInAppMessage(result);
                break;
            case "getRegisteredInAppScreenName":
                getRegisteredInAppScreenName(result);
                break;
            case "fetchInAppNotification":
                fetchInAppNotification(result);
                break;
            case "displayInAppNotification":
                displayInAppNotification(result);
                break;
            case "setUserInfoEmailId":
                setUserInfoEmailId(call, result);
                break;
            case "setUserInfoCustomerId":
                setUserInfoCustomerId(call, result);
                break;
            case "setUserInfoExtras":
                setUserInfoExtras(call, result);
                break;
            case "setUserInfoFirstName":
                setUserInfoFirstName(call, result);
                break;
            case "setUserInfoLastName":
                setUserInfoLastName(call, result);
                break;
            case "removeUserInfo":
                removeUserInfo(result);
                break;
            case "setEnablePush":
                setEnablePush(call, result);
                break;
            case "setEnableInApp":
                setEnableInApp(call, result);
                break;
            case "setEnableTracking":
                setEnableTracking(call, result);
                break;
            case "setIDFA":
                setIDFA(result);
                break;
            case "setCurrentLocation":
                setCurrentLocation(result);
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
                resetDeviceId(result);
                break;
            case "requestPushNotificationPermission":
                requestPushNotificationPermission(result);
                break;
            case "getInboxMessages":
                getInboxMessages(result);
                break;
            case "showInboxMessage":
                showInboxMessage(call, result);
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

    private void handleDataMessage(MethodCall methodCall, Result result) {
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
            result.success(null);
        } else {
            BlueshiftLogger.w(TAG, "data is null.");
            result.error("INVALID_DATA", "data is null.", null);
        }
    }

    private void identifyWithDetails(MethodCall methodCall, Result result) {
        HashMap<String, Object> extras = methodCall.argument("eventData");
        Blueshift.getInstance(appContext).identifyUser(appendVersion(extras), false);
        result.success(null);
    }

    private void trackCustomEvent(MethodCall methodCall, Result result) {
        String event = methodCall.argument("eventName");
        if (event != null) {
            HashMap<String, Object> extras = methodCall.argument("eventData");
            boolean isBatch = Boolean.TRUE.equals(methodCall.argument("isBatch"));

            Blueshift.getInstance(appContext).trackEvent(event, appendVersion(extras), isBatch);
            result.success(null);
        } else {
            BlueshiftLogger.w(TAG, "Can not send event without an event name.");
            result.error("INVALID_EVENT", "Can not send event without an event name.", null);
        }
    }

    private void trackScreenView(MethodCall methodCall, Result result) {
        String screenName = methodCall.argument("screenName");
        boolean isBatch = Boolean.TRUE.equals(methodCall.argument("isBatch"));
        Blueshift.getInstance(appContext).trackScreenView(screenName, isBatch);
        result.success(null);
    }

    private void trackInAppMessageView(MethodCall methodCall, Result result) {
        HashMap<String, Object> messageMap = methodCall.argument("message");
        if (messageMap != null) {
            try {
                // Log the entire message for debugging
                BlueshiftLogger.d(TAG, "trackInAppMessageView called with message: " + messageMap.toString());
                
                // Extract the data field from BlueshiftInboxMessage
                Object dataObject = messageMap.get("data");
                if (dataObject instanceof HashMap) {
                    HashMap<String, Object> dataMap = (HashMap<String, Object>) dataObject;
                    
                    // Log the data field for debugging
                    BlueshiftLogger.d(TAG, "Extracted data field: " + dataMap.toString());
                    
                    // Convert data HashMap to JSONObject for InAppMessage.getInstance
                    JSONObject jsonObject = new JSONObject(dataMap);
                    
                    // Log the JSONObject for debugging
                    BlueshiftLogger.d(TAG, "Created JSONObject: " + jsonObject.toString());
                    
                    // Create InAppMessage instance using getInstance method
                    InAppMessage inAppMessage = InAppMessage.getInstance(jsonObject);
                    
                    if (inAppMessage != null) {
                        BlueshiftLogger.d(TAG, "Successfully created InAppMessage, calling trackInAppMessageView");
                        
                        // Set the OpenedBy field to prevent null pointer exception
                        // Since this is being called from Flutter (user action), we set it to user
                        inAppMessage.setOpenedBy(InAppMessage.OpenedBy.user);
                        
                        // Track the in-app message view event
                        Blueshift.getInstance(appContext).trackInAppMessageView(inAppMessage);
                        
                        // Mark the message as displayed and read in local storage
                        markAsDisplayed(inAppMessage);
                        BlueshiftInboxManager.notifyMessageRead(appContext, inAppMessage.getMessageUuid());
                        
                        BlueshiftLogger.d(TAG, "trackInAppMessageView completed successfully");
                        result.success(null);
                    } else {
                        BlueshiftLogger.w(TAG, "Failed to create InAppMessage from provided data. JSONObject: " + jsonObject.toString());
                        result.error("INVALID_MESSAGE", "Failed to create InAppMessage from provided data.", null);
                    }
                } else {
                    BlueshiftLogger.w(TAG, "Data field is missing or invalid in the message. Data object type: " +
                        (dataObject != null ? dataObject.getClass().getSimpleName() : "null"));
                    result.error("INVALID_MESSAGE", "Data field is missing or invalid in the message.", null);
                }
            } catch (Exception e) {
                BlueshiftLogger.e(TAG, "Error creating InAppMessage: " + e.getMessage());
                BlueshiftLogger.e(TAG, e);
                result.error("EXCEPTION", "Error creating InAppMessage: " + e.getMessage(), null);
            }
        } else {
            BlueshiftLogger.w(TAG, "Cannot track in-app message view without message data.");
            result.error("INVALID_MESSAGE", "Cannot track in-app message view without message data.", null);
        }
    }

    private void markAsDisplayed(final InAppMessage inAppMessage) {
        BlueshiftExecutor.getInstance().runOnDiskIOThread(() -> {
            if (inAppMessage != null && appContext != null) {
                inAppMessage.setDisplayedAt(System.currentTimeMillis());
                InAppMessageStore store = InAppMessageStore.getInstance(appContext);
                if (store != null) {
                    store.update(inAppMessage);
                }
                
                BlueshiftInboxStoreSQLite.getInstance(appContext).markMessageAsRead(inAppMessage.getMessageUuid());
                BlueshiftLogger.d(TAG, "Message marked as displayed and read: " + inAppMessage.getMessageUuid());
            }
        });
    }

    private void registerForRemoteNotification(Result result) {
        BlueshiftLogger.d(TAG, "registerForRemoteNotification() - Method not available in Android.");
        result.success(null);
    }

    private void registerForInAppMessage(MethodCall methodCall, Result result) {
        String screenName = methodCall.argument("screenName");
        Blueshift.getInstance(appContext).registerForInAppMessages(appActivity, screenName);
        result.success(null);
    }

    private void unregisterForInAppMessage(Result result) {
        Blueshift.getInstance(appContext).unregisterForInAppMessages(appActivity);
        result.success(null);
    }

    private void getRegisteredInAppScreenName(Result result) {
        if (result != null) {
            String val = InAppManager.getRegisteredScreenName();
            result.success(val);
        }
    }

    private void fetchInAppNotification(Result result) {
        Blueshift.getInstance(appContext).fetchInAppMessages(null);
        result.success(null);
    }

    private void displayInAppNotification(Result result) {
        Blueshift.getInstance(appContext).displayInAppMessages();
        result.success(null);
    }

    private void setUserInfoEmailId(MethodCall methodCall, Result result) {
        String emailId = methodCall.argument("emailId");
        UserInfo.getInstance(appContext).setEmail(emailId);
        UserInfo.getInstance(appContext).save(appContext);
        result.success(null); 
    }

    private void setUserInfoCustomerId(MethodCall methodCall, Result result) {
        String customerId = methodCall.argument("customerId");
        UserInfo.getInstance(appContext).setRetailerCustomerId(customerId);
        UserInfo.getInstance(appContext).save(appContext);
        result.success(null); 
    }

    private void setUserInfoExtras(MethodCall methodCall, Result result) {
        HashMap<String, Object> extras = methodCall.argument("extras");
        UserInfo.getInstance(appContext).setDetails(extras);
        UserInfo.getInstance(appContext).save(appContext);
        result.success(null);
    }

    private void setUserInfoFirstName(MethodCall methodCall, Result result) {
        String firstName = methodCall.argument("firstName");
        UserInfo.getInstance(appContext).setFirstname(firstName);
        UserInfo.getInstance(appContext).save(appContext);
        result.success(null);
    }

    private void setUserInfoLastName(MethodCall methodCall, Result result) {
        String lastName = methodCall.argument("lastName");
        UserInfo.getInstance(appContext).setLastname(lastName);
        UserInfo.getInstance(appContext).save(appContext);
        result.success(null);
    }

    private void removeUserInfo(Result result) {
        UserInfo.getInstance(appContext).clear(appContext);
        result.success(null);
    }

    private void setEnablePush(MethodCall methodCall, Result result) {
        boolean isEnabled = Boolean.TRUE.equals(methodCall.argument("isEnabled"));
        Blueshift.optInForPushNotifications(appContext, isEnabled);
        result.success(null);
    }

    private void setEnableInApp(MethodCall methodCall, Result result) {
        boolean isEnabled = Boolean.TRUE.equals(methodCall.argument("isEnabled"));
        Blueshift.optInForInAppNotifications(appContext, isEnabled);
        result.success(null);
    }

    private void setEnableTracking(MethodCall methodCall, Result result) {
        boolean isEnabled = Boolean.TRUE.equals(methodCall.argument("isEnabled"));
        Blueshift.setTrackingEnabled(appContext, isEnabled);
        result.success(null);
    }

    private void setIDFA(Result result) {
        BlueshiftLogger.d(TAG, "setIDFA() - Method not available in Android.");
        result.success(null);
    }

    private void setCurrentLocation(Result result) {
        BlueshiftLogger.d(TAG, "setCurrentLocation() - Method not available in Android.");
        result.success(null);
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

    private void resetDeviceId(Result result) {
        Blueshift.getInstance(appContext).resetDeviceId();
        result.success(null);
    }

    private void requestPushNotificationPermission(Result result) {
        Blueshift.requestPushNotificationPermission(appActivity);
        result.success(null);
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

    private void showInboxMessage(MethodCall call, Result result) {
        HashMap<String, Object> map = call.argument("message");
        if (map != null) {
            BlueshiftInboxMessage message = BlueshiftInboxMessage.fromHashMap(map);
            BlueshiftInboxManager.displayInboxMessage(message);
            result.success(null);
        } else {
            result.error("INVALID_MESSAGE", "Cannot show inbox message without message data.", null);
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
