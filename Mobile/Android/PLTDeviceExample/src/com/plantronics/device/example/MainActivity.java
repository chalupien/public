/* ********************************************************************************************************
	MainActivity.java
	com.plantronics.device.example

	Created by mdavis on 04/01/2014.
	Copyright (c) 2014 Plantronics, Inc. All rights reserved.
***********************************************************************************************************/

package com.plantronics.device.example;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.plantronics.device.*;
import com.plantronics.device.calibration.OrientationTrackingCalibration;
import com.plantronics.device.info.*;

import java.util.ArrayList;

public class MainActivity extends Activity implements PairingListener, ConnectionListener, InfoListener {

	private static final String TAG = "com.plantronics.device.example.MainActivity";

	private Context 		_context;
	private Device 			_device;
	private AlertDialog		_noPairedDevicesAlert;

	private ProgressBar		_headingProgressBar;
	private ProgressBar		_pitchProgressBar;
	private ProgressBar		_rollProgressBar;
	private TextView		_headingValueTextView;
	private TextView		_pitchValueTextView;
	private TextView		_rollValueTextView;
	private TextView		_wearingStateValueTextView;
	private TextView		_localProximityValueTextView;
	private TextView		_remoteProximityValueTextView;
	private TextView		_tapsValueTextView;
	private TextView		_pedometerValueTextView;
	private TextView		_freeFallValueTextView;
	private TextView		_magnetometerCalValueTextView;
	private TextView		_gyroscopeCalValueTextView;
	private Button			_calOrientationButton;
	private OrientationTrackingInfo _someSavedOrientationTrackingInfo;


	/* ****************************************************************************************************
		 Activity
	*******************************************************************************************************/

	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		// set view background white
//		View relativeLayout = findViewById(R.id.relativeLayout);
//		View root = relativeLayout.getRootView();
//		root.setBackgroundColor(android.R.color.white);

		_context = this;

		_headingProgressBar = ((ProgressBar)findViewById(R.id.headingProgressBar));
		_pitchProgressBar = ((ProgressBar)findViewById(R.id.pitchProgressBar));
		_rollProgressBar = ((ProgressBar)findViewById(R.id.rollProgressBar));
		_headingValueTextView = ((TextView)findViewById(R.id.headingValueTextView));
		_pitchValueTextView = ((TextView)findViewById(R.id.pitchValueTextView));
		_rollValueTextView = ((TextView)findViewById(R.id.rollValueTextView));
		_wearingStateValueTextView = ((TextView)findViewById(R.id.wearingStateValueTextView));
		_localProximityValueTextView = ((TextView)findViewById(R.id.localProximityValueTextView));
		_remoteProximityValueTextView = ((TextView)findViewById(R.id.remoteProximityValueTextView));
		_tapsValueTextView = ((TextView)findViewById(R.id.tapsValueTextView));
		_pedometerValueTextView = ((TextView)findViewById(R.id.pedometerValueTextView));
		_freeFallValueTextView = ((TextView)findViewById(R.id.freeFallValueTextView));
		_magnetometerCalValueTextView = ((TextView)findViewById(R.id.magnetometerCalValueTextView));
		_gyroscopeCalValueTextView = ((TextView)findViewById(R.id.gyroscopeCalValueTextView));
		_calOrientationButton = ((Button)findViewById(R.id.calOrientationButton));
		_calOrientationButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				calOrientationButton();
			}
		});

		Device.initialize(this, new Device.InitializationCallback() {
			@Override
			public void onInitialized() {
				Log.i(TAG, "onInitialized()");
				Device.registerPairingListener((PairingListener)_context);

				tryConnecting();
			}

			@Override
			public void onFailure(int error) {
				Log.i(TAG, "onFailure()");

				if (error == Device.ERROR_PLTHUB_NOT_AVAILABLE) {
					Log.i(TAG, "PLTHub was not found.");
				} else if (error == Device.ERROR_FAILED_GET_DEVICE_LIST) {
					Log.i(TAG, "Failed to get device list.");
				}
			}
		});
	}

	@Override
	public void onResume() {
		Log.i(TAG, "onResume()");
		super.onResume();

		_context = this;

		if (_device != null) {
			_device.onResume();
		}
	}

	@Override
	protected void onPause() {
		Log.i(TAG, "onPause()");
		super.onPause();

		_context = null;

		if (_device != null) {
			_device.onPause();
		}
	}

	/* ****************************************************************************************************
			 Private
	*******************************************************************************************************/

	private void tryConnecting() {
		ArrayList<Device> devices = Device.getPairedDevices();
		Log.i(TAG, "devices: " + devices);

		if (devices.size() > 0) {
			_device = devices.get(0);
			_device.registerConnectionListener((ConnectionListener)_context);
			_device.openConnection();
		}
		else {
			Log.i(TAG, "No paired PLT devices found!");

//			runOnUiThread(new Runnable() {
//				@Override
//				public void run() {
//					AlertDialog.Builder builder = new AlertDialog.Builder(_context);
//					builder.setCancelable(true);
//					builder.setTitle("No Paired Devices");
//					builder.setMessage("Please pair a device in the Settings app.");
//					builder.setPositiveButton("OK",
//							new DialogInterface.OnClickListener() {
//								@Override
//								public void onClick(DialogInterface dialog, int which) {
//									dialog.dismiss();
//								}
//							});
//
//					_noPairedDevicesAlert = builder.create();
//					_noPairedDevicesAlert.show();
//				}
//			});
		}
	}

	private void calOrientationButton() {
		// "zero" orientation tracking at current orientation
		_device.setCalibration(null, Device.SERVICE_ORIENTATION_TRACKING);


		OrientationTrackingInfo calOrientation = this._someSavedOrientationTrackingInfo;
		OrientationTrackingCalibration calibration = new OrientationTrackingCalibration(calOrientation);
		_device.setCalibration(calibration, Device.SERVICE_ORIENTATION_TRACKING);
	}

	/* ****************************************************************************************************
			 PairingListener
	*******************************************************************************************************/

	public void onDevicePaired(Device device) {
		Log.i(TAG, "onDevicePaired(): " + device);

		_noPairedDevicesAlert.dismiss();
		tryConnecting();
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

		// subscribe to all services
		_device.subscribe(this, Device.SERVICE_ORIENTATION_TRACKING, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
		//_device.subscribe(this, Device.SERVICE_ORIENTATION_TRACKING, Device.SUBSCRIPTION_MODE_PERIODIC, 100);
		_device.subscribe(this, Device.SERVICE_WEARING_STATE, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
		_device.subscribe(this, Device.SERVICE_PROXIMITY, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
		_device.subscribe(this, Device.SERVICE_TAPS, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
		_device.subscribe(this, Device.SERVICE_PEDOMETER, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
		_device.subscribe(this, Device.SERVICE_FREE_FALL, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
		_device.subscribe(this, Device.SERVICE_MAGNETOMETER_CAL_STATUS, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);
		_device.subscribe(this, Device.SERVICE_GYROSCOPE_CAL_STATUS, Device.SUBSCRIPTION_MODE_ON_CHANGE, 0);

		calOrientationButton();
	}

	public void onConnectionFailedToOpen(Device device, int error) {
		Log.i(TAG, "onConnectionFailedToOpen()");

		if (error == Device.ERROR_CONNECTION_TIMEOUT) {
			Log.i(TAG, "Open connection timed out.");
		}
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

	public void onInfoReceived(final Info info) {
		Log.i(TAG, "onInfoReceived(): " + info);

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (info.getClass() == OrientationTrackingInfo.class) {
					OrientationTrackingInfo theInfo = (OrientationTrackingInfo)info;
					EulerAngles eulerAngles = theInfo.getEulerAngles();

					int heading = (int)Math.round(-eulerAngles.getX());
					int pitch = (int)Math.round(eulerAngles.getY());
					int roll = (int)Math.round(eulerAngles.getZ());

					_headingProgressBar.setProgress(heading + 180);
					_pitchProgressBar.setProgress(pitch + 90);
					_rollProgressBar.setProgress(roll + 90);

					// heading uses the "right-hand" rule. http://en.wikipedia.org/wiki/Right-hand_rule
					// most people find it more intuitive if the angle increases when rotated in the opposite direction
					_headingValueTextView.setText(heading + "˚");
					_pitchValueTextView.setText(pitch + "˚");
					_rollValueTextView.setText(roll + "˚");

				}
				else if (info.getClass() == WearingStateInfo.class) {
					WearingStateInfo theInfo = (WearingStateInfo)info;
					_wearingStateValueTextView.setText((theInfo.getIsBeingWorn() ? "yes" : "no"));
				}
				else if (info.getClass() == ProximityInfo.class) {
					ProximityInfo theInfo = (ProximityInfo)info;
					_localProximityValueTextView.setText(ProximityInfo.getStringForProximity(theInfo.getLocalProximity()));
				}
				else if (info.getClass() == TapsInfo.class) {
					TapsInfo theInfo = (TapsInfo)info;
					int count = theInfo.getCount();
					String tapss = (count > 1 ? " taps " : " tap ");
					_tapsValueTextView.setText((count == 0 ? "-" : count + tapss + "in " + TapsInfo.getStringForTapDirection(theInfo.getDirection())));
				}
				else if (info.getClass() == PedometerInfo.class) {
					PedometerInfo theInfo = (PedometerInfo)info;
					_pedometerValueTextView.setText(theInfo.getSteps() + " steps");
				}
				else if (info.getClass() == FreeFallInfo.class) {
					FreeFallInfo theInfo = (FreeFallInfo)info;
					_freeFallValueTextView.setText((theInfo.getIsInFreeFall() ? "yes" : "no"));
				}
				else if (info.getClass() == MagnetometerCalInfo.class) {
					MagnetometerCalInfo theInfo = (MagnetometerCalInfo)info;
					_magnetometerCalValueTextView.setText((theInfo.getIsCalibrated() ? "yes" : "no"));
				}
				else if (info.getClass() == GyroscopeCalInfo.class) {
					GyroscopeCalInfo theInfo = (GyroscopeCalInfo)info;
					_gyroscopeCalValueTextView.setText((theInfo.getIsCalibrated() ? "yes" : "no"));
				}
			}
		});
	}
}
