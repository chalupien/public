package com.plantronics;

import android.app.Activity;

import android.bluetooth.BluetoothAssignedNumbers;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothHeadset;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.Html;
import android.view.View;
import android.widget.TextView;
import com.plantronics.R;
import com.plantronics.bluetooth.PlantronicsReceiver;
import com.plantronics.bluetooth.PlantronicsXEventMessage;


/**
 * Copyright 2012 Plantronics, Inc.
 *
 * @author Cary Bran
 *
 * A simple Activity to display the XEvent information generated
 * by the Plantronics device
 */
public class XEventExampleActivity extends Activity {

    //where the data gets output
    private TextView logPane;

    //bluetooth
    private BroadcastReceiver btReceiver;
    private BluetoothHandler btHandler;
    private IntentFilter btIntentFilter;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.main);

        logPane = (TextView)findViewById(R.id.log);

        initBluetooth();
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        String log = savedInstanceState.getString("log");
        logPane.setText(log);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putString("log", logPane.getText().toString());
    }


    @Override
    protected void onStop() {
        super.onStop();
        unregisterReceiver(btReceiver);
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    /**
     * Initialization routine that registers the handler with the receiver and sets up the intent filters
     * for the PlantronicsReceiver to receive XEvent messages from the Plantronics device
     */
    private void initBluetooth() {
        btHandler = new BluetoothHandler();
        btReceiver = new PlantronicsReceiver(btHandler);

        btIntentFilter = new IntentFilter();
        btIntentFilter.addCategory(BluetoothHeadset.VENDOR_SPECIFIC_HEADSET_EVENT_COMPANY_ID_CATEGORY + "." + BluetoothAssignedNumbers.PLANTRONICS);
        btIntentFilter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
        btIntentFilter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECT_REQUESTED);
        btIntentFilter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
        btIntentFilter.addAction(BluetoothHeadset.ACTION_VENDOR_SPECIFIC_HEADSET_EVENT);
        btIntentFilter.addAction(BluetoothHeadset.ACTION_AUDIO_STATE_CHANGED);
        btIntentFilter.addAction(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED);

        registerReceiver(btReceiver, btIntentFilter);

    }

    /**
     * Handler for BluetoothReceiver events
     */
    public class BluetoothHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case PlantronicsReceiver.HEADSET_EVENT:
                    PlantronicsXEventMessage message = (PlantronicsXEventMessage) msg.obj;
                    writeToLogPane(message.toString());
                    break;
                default:
                    break;
            }
        }
    }

    /**
     * Prepends a message to the log pane
     *
     * @param message
     */
    public void writeToLogPane(String message) {
        Editable e = logPane.getEditableText();
        if(e == null){
            logPane.append(Html.fromHtml(message));
            logPane.append("\n\n");
        }
        else{
            e.insert(0, Html.fromHtml(message));
            e.insert(0, "\n\n");
        }

    }
}
