package com.balraksh.scrollrok.scroll_rok.blocking;

import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.ComponentActivity;
import androidx.activity.OnBackPressedCallback;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.balraksh.scrollrok.scroll_rok.MainActivity;
import com.balraksh.scrollrok.scroll_rok.R;

public class BlockActivity extends ComponentActivity {
    public static final String EXTRA_BLOCKED_PACKAGE = "blocked_package";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Keep screen on while the blocking screen is visible.
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        // Use AndroidX compat APIs to control immersive mode without deprecated platform calls.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        WindowInsetsControllerCompat insetsController =
                WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        if (insetsController != null) {
            insetsController.hide(WindowInsetsCompat.Type.systemBars());
            insetsController.setSystemBarsBehavior(
                    WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        }

        // Block back navigation across API levels.
        getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                // Intentionally empty to keep users on this blocking screen.
            }
        });

        setContentView(R.layout.activity_block);

        String blockedPackage = getIntent().getStringExtra(EXTRA_BLOCKED_PACKAGE);
        String appName = AndroidBlockManager.resolveAppLabel(this, blockedPackage);

        TextView appNameText = findViewById(R.id.blocked_app_name);
        appNameText.setText(appName);

        Button exitButton = findViewById(R.id.button_exit_app);
        Button breatheButton = findViewById(R.id.button_breathe_unlock);
        Button playButton = findViewById(R.id.button_play_unlock);

        exitButton.setOnClickListener(v -> {
            Intent home = new Intent(Intent.ACTION_MAIN);
            home.addCategory(Intent.CATEGORY_HOME);
            home.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(home);
            finish();
        });

        breatheButton.setOnClickListener(v -> openFlutterUnlock("breathe"));
        playButton.setOnClickListener(v -> openFlutterUnlock("game"));
    }

    private void openFlutterUnlock(String mode) {
        AndroidBlockManager.setPendingUnlockAction(this, mode);
        Intent flutter = new Intent(this, MainActivity.class);
        flutter.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK
                | Intent.FLAG_ACTIVITY_CLEAR_TOP
                | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(flutter);
        finish();
    }
}
