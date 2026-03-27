package com.balraksh.scrollrok.scroll_rok.blocking;

import android.accessibilityservice.AccessibilityService;
import android.content.ComponentName;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.text.TextUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public final class AndroidBlockManager {
    private static final String PREFS = "scrollrok_android";
    private static final String KEY_BLOCKED_APPS = "blocked_apps";
    private static final String KEY_UNLOCK_EXPIRY = "unlock_expiry_ms";
    private static final String KEY_LAST_BLOCK_LAUNCH = "last_block_launch_ms";
    private static final String KEY_CURRENT_APP = "current_foreground_app";
    private static final String KEY_CURRENT_APP_START = "current_foreground_start_ms";
    private static final String KEY_TOTAL_UNLOCKS = "stats_total_unlocks";
    private static final String KEY_TOTAL_USAGE_SECONDS = "stats_total_usage_seconds";
    private static final String KEY_APP_OPENS = "stats_app_opens_json";
    private static final String KEY_APP_USAGE = "stats_app_usage_json";
    private static final String KEY_PENDING_UNLOCK_ACTION = "pending_unlock_action";

    private static final long BLOCK_LAUNCH_DEBOUNCE_MS = 1500L;

    // Analytics should only track the supported social apps.
    private static final Set<String> SOCIAL_PACKAGES = new HashSet<>(Arrays.asList(
            "com.instagram.android",
            "com.instagram.lite",
            "com.google.android.youtube",
            "com.facebook.katana",
            "com.snapchat.android",
            "com.linkedin.android",
            "com.zhiliaoapp.musically"
    ));

    private AndroidBlockManager() {}

    private static SharedPreferences prefs(Context context) {
        return context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    public static void setBlockedApps(Context context, List<String> packageNames) {
        Set<String> data = new HashSet<>();
        for (String pkg : packageNames) {
            if (pkg != null && !pkg.trim().isEmpty()) {
                data.add(pkg.trim());
            }
        }
        prefs(context).edit().putStringSet(KEY_BLOCKED_APPS, data).apply();
    }

    public static List<String> getBlockedApps(Context context) {
        Set<String> set = prefs(context).getStringSet(KEY_BLOCKED_APPS, new HashSet<String>());
        return new ArrayList<>(set);
    }

    public static void unlockApps(Context context, int durationMinutes) {
        long now = System.currentTimeMillis();
        long expiry = now + (Math.max(1, durationMinutes) * 60L * 1000L);
        prefs(context).edit()
                .putLong(KEY_UNLOCK_EXPIRY, expiry)
                .putInt(KEY_TOTAL_UNLOCKS, prefs(context).getInt(KEY_TOTAL_UNLOCKS, 0) + 1)
                .apply();
    }

    public static void lockNow(Context context) {
        prefs(context).edit().putLong(KEY_UNLOCK_EXPIRY, 0L).apply();
    }

    public static boolean isUnlockActive(Context context) {
        long expiry = prefs(context).getLong(KEY_UNLOCK_EXPIRY, 0L);
        return System.currentTimeMillis() < expiry;
    }

    public static boolean isPackageBlocked(Context context, String packageName) {
        if (packageName == null || packageName.isEmpty()) {
            return false;
        }
        Set<String> set = prefs(context).getStringSet(KEY_BLOCKED_APPS, new HashSet<String>());
        return set.contains(packageName);
    }

    public static boolean shouldBlockPackageNow(Context context, String packageName) {
        return isPackageBlocked(context, packageName) && !isUnlockActive(context);
    }

    public static boolean shouldLaunchBlockNow(Context context) {
        long now = System.currentTimeMillis();
        long last = prefs(context).getLong(KEY_LAST_BLOCK_LAUNCH, 0L);
        if ((now - last) < BLOCK_LAUNCH_DEBOUNCE_MS) {
            return false;
        }
        prefs(context).edit().putLong(KEY_LAST_BLOCK_LAUNCH, now).apply();
        return true;
    }

    public static void onForegroundChanged(Context context, String packageName) {
        if (packageName == null || packageName.isEmpty()) {
            return;
        }

        SharedPreferences prefs = prefs(context);
        String previousApp = prefs.getString(KEY_CURRENT_APP, null);
        long previousStart = prefs.getLong(KEY_CURRENT_APP_START, 0L);
        long now = System.currentTimeMillis();

        if (packageName.equals(previousApp)) {
            return;
        }

        if (previousApp != null && previousStart > 0L && isSocialPackage(previousApp)) {
            long seconds = Math.max(0L, (now - previousStart) / 1000L);
            if (seconds > 0L) {
                long total = prefs.getLong(KEY_TOTAL_USAGE_SECONDS, 0L) + seconds;
                JSONObject usage = readJsonObject(prefs.getString(KEY_APP_USAGE, "{}"));
                long old = usage.optLong(previousApp, 0L);
                putLongSafe(usage, previousApp, old + seconds);
                prefs.edit()
                        .putLong(KEY_TOTAL_USAGE_SECONDS, total)
                        .putString(KEY_APP_USAGE, usage.toString())
                        .apply();
            }
        }

        if (isSocialPackage(packageName)) {
            JSONObject opens = readJsonObject(prefs.getString(KEY_APP_OPENS, "{}"));
            long openCount = opens.optLong(packageName, 0L);
            putLongSafe(opens, packageName, openCount + 1L);
            prefs.edit().putString(KEY_APP_OPENS, opens.toString()).apply();
        }

        prefs.edit()
                .putString(KEY_CURRENT_APP, packageName)
                .putLong(KEY_CURRENT_APP_START, now)
                .apply();
    }

    public static boolean isBlockedAppActive(Context context) {
        SharedPreferences prefs = prefs(context);
        String current = prefs.getString(KEY_CURRENT_APP, "");
        return current != null && shouldBlockPackageNow(context, current);
    }

    public static Map<String, Object> getStats(Context context) {
        SharedPreferences prefs = prefs(context);
        Map<String, Object> result = new HashMap<>();

        result.put("totalUnlocks", prefs.getInt(KEY_TOTAL_UNLOCKS, 0));
        result.put("totalUsageSeconds", prefs.getLong(KEY_TOTAL_USAGE_SECONDS, 0L));
        result.put("unlockExpiry", prefs.getLong(KEY_UNLOCK_EXPIRY, 0L));
        result.put("currentForegroundApp", prefs.getString(KEY_CURRENT_APP, ""));
        result.put("appOpens", jsonToMap(readJsonObject(prefs.getString(KEY_APP_OPENS, "{}"))));
        result.put("appUsageSeconds", jsonToMap(readJsonObject(prefs.getString(KEY_APP_USAGE, "{}"))));

        return result;
    }

    public static void setPendingUnlockAction(Context context, String action) {
        prefs(context).edit().putString(KEY_PENDING_UNLOCK_ACTION, action).apply();
    }

    public static String consumePendingUnlockAction(Context context) {
        SharedPreferences prefs = prefs(context);
        String value = prefs.getString(KEY_PENDING_UNLOCK_ACTION, null);
        prefs.edit().remove(KEY_PENDING_UNLOCK_ACTION).apply();
        return value;
    }

    public static boolean isAccessibilityEnabled(Context context) {
        String enabledServices = Settings.Secure.getString(
                context.getContentResolver(),
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        );
        if (enabledServices == null) {
            return false;
        }

        ComponentName expected = new ComponentName(context, AppBlockAccessibilityService.class);
        TextUtils.SimpleStringSplitter splitter = new TextUtils.SimpleStringSplitter(':');
        splitter.setString(enabledServices);
        while (splitter.hasNext()) {
            String item = splitter.next();
            ComponentName enabled = ComponentName.unflattenFromString(item);
            if (enabled != null && enabled.equals(expected)) {
                return true;
            }
        }
        return false;
    }

    public static String resolveAppLabel(Context context, String packageName) {
        if (packageName == null || packageName.isEmpty()) {
            return "Selected app";
        }
        try {
            PackageManager pm = context.getPackageManager();
            ApplicationInfo appInfo;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                appInfo = pm.getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(0));
            } else {
                appInfo = pm.getApplicationInfo(packageName, 0);
            }
            CharSequence label = pm.getApplicationLabel(appInfo);
            if (label != null) {
                return label.toString();
            }
        } catch (Exception ignored) {
        }
        return packageName;
    }

    private static JSONObject readJsonObject(String raw) {
        try {
            return new JSONObject(raw == null ? "{}" : raw);
        } catch (JSONException e) {
            return new JSONObject();
        }
    }

    private static void putLongSafe(JSONObject object, String key, long value) {
        try {
            object.put(key, value);
        } catch (JSONException ignored) {
        }
    }

    private static Map<String, Object> jsonToMap(JSONObject object) {
        Map<String, Object> map = new HashMap<>();
        if (object == null) {
            return map;
        }
        for (java.util.Iterator<String> it = object.keys(); it.hasNext(); ) {
            String key = it.next();
            map.put(key, object.optLong(key, 0L));
        }
        return map;
    }

    private static boolean isSocialPackage(String packageName) {
        return packageName != null && SOCIAL_PACKAGES.contains(packageName);
    }
}
