package com.balraksh.scrollrok.scroll_rok;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.balraksh.scrollrok.scroll_rok.blocking.AndroidBlockManager;
import com.google.android.material.bottomsheet.BottomSheetDialog;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;

public class HomeActivity extends AppCompatActivity {
    private static final String FLUTTER_PREFS = "FlutterSharedPreferences";

    private TextView valueTimeWasted;
    private TextView valueTotalScroll;
    private TextView valueScrollBlocked;
    private TextView valueAppsOpened;
    private TextView valueStartTime;
    private TextView valueEndTime;
    private TextView statusIndicator;
    private Button buttonPause;
    private Button buttonActive;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        valueTimeWasted = findViewById(R.id.value_time_wasted);
        valueTotalScroll = findViewById(R.id.value_total_scroll);
        valueScrollBlocked = findViewById(R.id.value_scroll_blocked);
        valueAppsOpened = findViewById(R.id.value_apps_opened);
        valueStartTime = findViewById(R.id.value_start_time);
        valueEndTime = findViewById(R.id.value_end_time);
        statusIndicator = findViewById(R.id.status_indicator);
        buttonPause = findViewById(R.id.button_pause);
        buttonActive = findViewById(R.id.button_active);

        wireClicks();
    }

    @Override
    protected void onResume() {
        super.onResume();
        refreshDashboard();
    }

    private void wireClicks() {
        buttonPause.setOnClickListener(v -> onPauseClicked());

        buttonActive.setOnClickListener(v -> {
            AndroidBlockManager.lockNow(this);
            refreshDashboard();
        });

        LinearLayout breathingCard = findViewById(R.id.card_breathing);
        breathingCard.setOnClickListener(v -> startActivity(new Intent(this, BreathingSelectionActivity.class)));

        LinearLayout gameCard = findViewById(R.id.card_games);
        gameCard.setOnClickListener(v -> startActivity(new Intent(this, GameSelectionActivity.class)));

        findViewById(R.id.nav_activity).setOnClickListener(v ->
                Toast.makeText(this, "Activity tab coming soon", Toast.LENGTH_SHORT).show());

        findViewById(R.id.nav_profile).setOnClickListener(v ->
                Toast.makeText(this, "Profile tab coming soon", Toast.LENGTH_SHORT).show());
    }

    private void onPauseClicked() {
        if (!buttonPause.isEnabled()) {
            return;
        }

        if (isPremiumUser()) {
            showPauseDurationBottomSheet();
        } else {
            applyPause(10);
        }
    }

    private void showPauseDurationBottomSheet() {
        BottomSheetDialog dialog = new BottomSheetDialog(this);
        View sheet = LayoutInflater.from(this).inflate(R.layout.bottom_sheet_pause_slider, null, false);
        dialog.setContentView(sheet);

        SeekBar seekBar = sheet.findViewById(R.id.pause_seekbar);
        TextView minutesValue = sheet.findViewById(R.id.pause_minutes_value);
        Button cancel = sheet.findViewById(R.id.button_pause_cancel);
        Button apply = sheet.findViewById(R.id.button_pause_apply);

        final int[] selectedMinutes = new int[]{10};
        minutesValue.setText(getString(R.string.sr_minutes_format, selectedMinutes[0]));

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                selectedMinutes[0] = 10 + progress;
                minutesValue.setText(getString(R.string.sr_minutes_format, selectedMinutes[0]));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
                // no-op
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                // no-op
            }
        });

        cancel.setOnClickListener(v -> dialog.dismiss());
        apply.setOnClickListener(v -> {
            applyPause(selectedMinutes[0]);
            dialog.dismiss();
        });

        dialog.show();
    }

    private void applyPause(int minutes) {
        AndroidBlockManager.unlockApps(this, minutes);
        refreshDashboard();
    }

    private void refreshDashboard() {
        Map<String, Object> stats = AndroidBlockManager.getStats(this);

        long totalUsageSeconds = asLong(stats.get("totalUsageSeconds"));
        long totalScrolls = readLongFromAnyPreference(
                "total_scrolls",
                "stats_total_scrolls",
                "FlutterSharedPreferences.total_scrolls",
                "FlutterSharedPreferences.stats_total_scrolls"
        );
        long scrollBlocked = AndroidBlockManager.getScrollBlockedCount(this);
        long appsOpened = sumMapValues(stats.get("appOpens"));

        valueTimeWasted.setText(formatDuration(totalUsageSeconds));
        valueTotalScroll.setText(String.valueOf(totalScrolls));
        valueScrollBlocked.setText(String.valueOf(scrollBlocked));
        valueAppsOpened.setText(String.valueOf(appsOpened));

        boolean pauseActive = AndroidBlockManager.isUnlockActive(this);
        buttonPause.setEnabled(!pauseActive);
        buttonPause.setAlpha(pauseActive ? 0.45f : 1f);
        buttonPause.setBackgroundResource(pauseActive ? R.drawable.bg_button_disabled : R.drawable.bg_ripple_button_outline);

        if (pauseActive) {
            statusIndicator.setText("?");
            buttonActive.setText(getString(R.string.sr_paused));
        } else {
            statusIndicator.setText("?");
            buttonActive.setText(getString(R.string.sr_active));
        }

        long unlockStartMs = AndroidBlockManager.getLastUnlockStartMs(this);
        long unlockExpiryMs = asLong(stats.get("unlockExpiry"));
        if (unlockStartMs > 0L && unlockExpiryMs > unlockStartMs) {
            valueStartTime.setText(formatClock(unlockStartMs));
            valueEndTime.setText(formatClock(unlockExpiryMs));
        } else {
            valueStartTime.setText("--");
            valueEndTime.setText("--");
        }
    }

    private boolean isPremiumUser() {
        if (readBooleanAny("is_premium") || readBooleanAny("premium")
                || readBooleanAny("premium_active") || readBooleanAny("pro_user")) {
            return true;
        }

        return readStringAny("subscription_tier").equalsIgnoreCase("premium")
                || readStringAny("plan").equalsIgnoreCase("premium");
    }

    private boolean readBooleanAny(String key) {
        SharedPreferences nativePrefs = getSharedPreferences("scrollrok_android", MODE_PRIVATE);
        SharedPreferences flutterPrefs = getSharedPreferences(FLUTTER_PREFS, MODE_PRIVATE);

        if (nativePrefs.contains(key)) {
            return nativePrefs.getBoolean(key, false);
        }

        if (flutterPrefs.contains(key)) {
            return flutterPrefs.getBoolean(key, false);
        }

        String prefixedKey = "flutter." + key;
        if (flutterPrefs.contains(prefixedKey)) {
            return flutterPrefs.getBoolean(prefixedKey, false);
        }
        return false;
    }

    private String readStringAny(String key) {
        SharedPreferences nativePrefs = getSharedPreferences("scrollrok_android", MODE_PRIVATE);
        SharedPreferences flutterPrefs = getSharedPreferences(FLUTTER_PREFS, MODE_PRIVATE);

        String nativeValue = nativePrefs.getString(key, "");
        if (nativeValue != null && !nativeValue.isEmpty()) {
            return nativeValue;
        }

        String flutterValue = flutterPrefs.getString(key, "");
        if (flutterValue != null && !flutterValue.isEmpty()) {
            return flutterValue;
        }

        String prefixedValue = flutterPrefs.getString("flutter." + key, "");
        return prefixedValue == null ? "" : prefixedValue;
    }

    private long readLongFromAnyPreference(String... keys) {
        SharedPreferences nativePrefs = getSharedPreferences("scrollrok_android", MODE_PRIVATE);
        SharedPreferences flutterPrefs = getSharedPreferences(FLUTTER_PREFS, MODE_PRIVATE);

        for (String key : keys) {
            if (nativePrefs.contains(key)) {
                return nativePrefs.getLong(key, 0L);
            }
            if (flutterPrefs.contains(key)) {
                return tryGetLong(flutterPrefs, key);
            }
        }

        return 0L;
    }

    private long tryGetLong(SharedPreferences prefs, String key) {
        try {
            return prefs.getLong(key, 0L);
        } catch (ClassCastException e) {
            String raw = prefs.getString(key, "0");
            try {
                return Long.parseLong(raw == null ? "0" : raw);
            } catch (NumberFormatException ignored) {
                return 0L;
            }
        }
    }

    private long sumMapValues(Object mapObject) {
        if (!(mapObject instanceof Map)) {
            return 0L;
        }

        long sum = 0L;
        Map<?, ?> map = (Map<?, ?>) mapObject;
        for (Object value : map.values()) {
            sum += asLong(value);
        }
        return sum;
    }

    private long asLong(Object value) {
        if (value instanceof Integer) {
            return (Integer) value;
        }
        if (value instanceof Long) {
            return (Long) value;
        }
        if (value instanceof Double) {
            return ((Double) value).longValue();
        }
        if (value instanceof Float) {
            return ((Float) value).longValue();
        }
        return 0L;
    }

    private String formatDuration(long totalSeconds) {
        long seconds = Math.max(0L, totalSeconds);
        long hours = seconds / 3600L;
        long minutes = (seconds % 3600L) / 60L;
        long remSeconds = seconds % 60L;

        if (hours > 0L) {
            return String.format(Locale.getDefault(), "%dh %dm", hours, minutes);
        }
        return String.format(Locale.getDefault(), "%dm %ds", minutes, remSeconds);
    }

    private String formatClock(long ms) {
        return new SimpleDateFormat("hh:mm a", Locale.getDefault()).format(new Date(ms));
    }
}
