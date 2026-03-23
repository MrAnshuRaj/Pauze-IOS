package com.balraksh.scrollrok.scroll_rok.blocking;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.balraksh.scrollrok.scroll_rok.MainActivity;
import com.balraksh.scrollrok.scroll_rok.R;

public class BlockActivity extends Activity {
    public static final String EXTRA_BLOCKED_PACKAGE = "blocked_package";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN
                        | WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        );

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

    @Override
    public void onBackPressed() {
        // Consume back to keep the blocking wall active.
    }
}
