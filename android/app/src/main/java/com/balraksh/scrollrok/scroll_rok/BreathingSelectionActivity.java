package com.balraksh.scrollrok.scroll_rok;

import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

public class BreathingSelectionActivity extends AppCompatActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_selection);

        TextView title = findViewById(R.id.selection_title);
        TextView subtitle = findViewById(R.id.selection_subtitle);
        Button close = findViewById(R.id.selection_close);

        title.setText("Breathing Selection");
        subtitle.setText("Complete a 2-minute guided breathing session");
        close.setOnClickListener(v -> finish());
    }
}
