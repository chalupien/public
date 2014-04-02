/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.device.example

	Created by mdavis on 04/01/2014.
	Copyright (c) 2014 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.device.example;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import com.plantronics.device.*;
import com.plantronics.device.info.Info;
import java.util.ArrayList;

public class MainActivity extends Activity implements PairingListener, ConnectionListener, InfoListener {

	private static final String TAG = "com.plantronics.device.example.MainActivity";

	private Context 	_context;
	private Device 		_device;


	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		_context = this;

		Device.initialize(this, new Device.InitializationCallback() {
			@Override
			public void onInitialized() {
				Log.i(TAG, "onInitialized()");
				Device.registerPairingListener((PairingListener)_context);

				ArrayList<Device> devices = Device.getPairedDevices();
				Log.i(TAG, "devices: " + devices);

				if (devices.size() > 0) {
					_device = devices.get(0);
					_device.registerConnectionListener((ConnectionListener)_context);
					_device.openConnection();
				}
				else {
					Log.i(TAG, "No PLT devices found!");
				}
			}

			@Override
			public void onFailure() {
				Log.i(TAG, "onFailure()");
			}
		});
	}

	/* ****************************************************************************************************
			 PairingListener
	*******************************************************************************************************/

	public void onDevicePaired(Device device) {
		Log.i(TAG, "onDevicePaired(): " + device);
	}

	public void onDeviceUnpaired(Device device) {
		Log.i(TAG, "onDeviceUnpaired(): " + device);
	}

	/* ****************************************************************************************************
			 ConnectionListener
	*******************************************************************************************************/

	public void onConnectionOpen(Device device) {
		Log.i(TAG, "onConnectionOpen()");

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				//_connectedTextView.setText("Connected");
			}
		});
	}

	public void onConnectionClosed(Device device) {
		Log.i(TAG, "onConnectionClosed()");

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				//_connectedTextView.setText("Disconnected");
			}
		});
	}

	/* ****************************************************************************************************
			 InfoListener
	*******************************************************************************************************/

	public void onSubscriptionChanged(Subscription oldSubscription, Subscription newSubscription) {
		Log.i(TAG, "onSubscriptionChanged(): oldSubscription=" + oldSubscription + ", newSubscription=" + newSubscription);
	}

	public void onInfoReceived(Info info) {
		Log.i(TAG, "onInfoReceived(): " + info);
	}
}
