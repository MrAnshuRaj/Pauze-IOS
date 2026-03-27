package com.balraksh.scrollrok.scroll_rok;

import android.content.Intent;
import android.provider.Settings;

import androidx.annotation.NonNull;

import com.balraksh.scrollrok.scroll_rok.blocking.AndroidBlockManager;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "scrollrok/android";
    private MethodChannel channel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this::onMethodCall);
    }

    @Override
    protected void onResume() {
        super.onResume();
        dispatchPendingUnlockAction();
    }

    private void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "setBlockedApps": {
                List<String> blocked = call.argument("packages");
                if (blocked == null) {
                    blocked = new ArrayList<>();
                }
                AndroidBlockManager.setBlockedApps(this, blocked);
                result.success(true);
                return;
            }
            case "unlockApps": {
                Integer duration = call.argument("durationMinutes");
                AndroidBlockManager.unlockApps(this, duration == null ? 10 : duration);
                result.success(true);
                return;
            }
            case "lockNow": {
                AndroidBlockManager.lockNow(this);
                result.success(true);
                return;
            }
            case "getStats": {
                Map<String, Object> stats = AndroidBlockManager.getStats(this);
                result.success(stats);
                return;
            }
            case "isBlockedAppActive": {
                result.success(AndroidBlockManager.isBlockedAppActive(this));
                return;
            }
            case "isAccessibilityEnabled": {
                result.success(AndroidBlockManager.isAccessibilityEnabled(this));
                return;
            }
            case "openAccessibilitySettings": {
                Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
                result.success(true);
                return;
            }
            case "consumePendingUnlockAction": {
                result.success(AndroidBlockManager.consumePendingUnlockAction(this));
                return;
            }
            default:
                result.notImplemented();
        }
    }

    private void dispatchPendingUnlockAction() {
        if (channel == null) {
            return;
        }

        String pending = AndroidBlockManager.consumePendingUnlockAction(this);
        if (pending != null && !pending.isEmpty()) {
            channel.invokeMethod("onUnlockChallengeRequested", pending);
        }
    }
}

