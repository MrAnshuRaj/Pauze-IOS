package com.balraksh.scrollrok.scroll_rok.blocking;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.Intent;
import android.view.accessibility.AccessibilityEvent;

public class AppBlockAccessibilityService extends AccessibilityService {

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        AccessibilityServiceInfo info = getServiceInfo();
        if (info != null) {
            info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
                    | AccessibilityEvent.TYPE_WINDOWS_CHANGED;
            info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC;
            info.notificationTimeout = 100;
            setServiceInfo(info);
        }
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        if (event == null || event.getPackageName() == null) {
            return;
        }

        String packageName = event.getPackageName().toString();
        if (packageName.isEmpty()) {
            return;
        }

        AndroidBlockManager.onForegroundChanged(this, packageName);

        if (getPackageName().equals(packageName)) {
            return;
        }

        if (!AndroidBlockManager.shouldBlockPackageNow(this, packageName)) {
            return;
        }

        if (!AndroidBlockManager.shouldLaunchBlockNow(this)) {
            return;
        }

        Intent intent = new Intent(this, BlockActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
                | Intent.FLAG_ACTIVITY_SINGLE_TOP
                | Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
        intent.putExtra(BlockActivity.EXTRA_BLOCKED_PACKAGE, packageName);
        startActivity(intent);
    }

    @Override
    public void onInterrupt() {
        // No-op. We are not streaming spoken feedback.
    }
}
