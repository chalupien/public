//
//  MainWindowController.m
//  PLTDeviceExample
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "MainWindowController.h"
#import <PLTDevice/PLTDevice.h>


@interface MainWindowController () <PLTDeviceSubscriber>

- (IBAction)calibrateButton:(id)sender;
- (void)setUIConnected:(BOOL)flag;

@property(nonatomic,strong)		PLTDevice						*device;
@property(nonatomic,strong)		IBOutlet NSButton				*calibrateButton;
@property(nonatomic,assign)		IBOutlet NSTextField			*headingTextField;
@property(nonatomic,assign)		IBOutlet NSTextField			*pitchTextField;
@property(nonatomic,assign)		IBOutlet NSTextField			*rollTextField;
@property(nonatomic,assign)		IBOutlet NSTextField            *wearingStateTextField;
@property(nonatomic,assign)		IBOutlet NSTextField            *localProximityTextField;
@property(nonatomic,assign)		IBOutlet NSTextField            *remoteProximityTextField;
@property(nonatomic,assign)		IBOutlet NSProgressIndicator    *headingIndicator;
@property(nonatomic,assign)		IBOutlet NSProgressIndicator    *pitchIndicator;
@property(nonatomic,assign)		IBOutlet NSProgressIndicator    *rollIndicator;
@property(nonatomic,assign)		IBOutlet NSTextField            *freeFallTextField;
@property(nonatomic,assign)		IBOutlet NSTextField            *tapsTextField;
@property(nonatomic,assign)		IBOutlet NSTextField            *pedometerTextField;
@property(nonatomic,assign)		IBOutlet NSTextField            *gyroscopeCalLabel;
@property(nonatomic,assign)		IBOutlet NSTextField            *magnetometerCalLabel;

@end

extern int _pltDLogLevel;

@implementation MainWindowController

#pragma mark - Private

- (IBAction)calibrateButton:(id)sender
{
	// "zero" orientation tracking to current position
	NSError *err = nil;
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking error:&err];
	if (err) {
		NSLog(@"Error calibrating orientation tracking: %@", err);
	}
	
	// the above is equivelent to:
	// PLTOrientationTrackingInfo *oldOrientationInfo = (PLTOrientationTrackingInfo *)[self.device cachedInfoForService:PLTServiceOrientationTracking error:nil];
	// PLTOrientationTrackingCalibration *orientationCal = [PLTOrientationTrackingCalibration calibrationWithReferenceOrientationTrackingInfo:oldOrientationInfo];
	// [self.device setCalibration:orientationCal forService:PLTServiceOrientationTracking error:&err];
}

- (void)setUIConnected:(BOOL)flag
{
	[self.calibrateButton setEnabled:flag];
	
	if (!flag) {
		[self.headingIndicator setDoubleValue:-180];
		[self.pitchIndicator setDoubleValue:-90];
		[self.rollIndicator setDoubleValue:-180];
		self.headingTextField.stringValue = @"0˚";
		self.pitchTextField.stringValue = @"0˚";
		self.rollTextField.stringValue = @"0˚";
		self.localProximityTextField.stringValue = @"-";
		self.localProximityTextField.stringValue = @"-";
		self.wearingStateTextField.stringValue = @"-";
		self.tapsTextField.stringValue = @"-";
		self.freeFallTextField.stringValue = @"-";
		self.pedometerTextField.stringValue = @"-";
		self.gyroscopeCalLabel.stringValue = @"-";;
		self.magnetometerCalLabel.stringValue = @"-";
	}
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	// since we subscribed to receive info updates (and conform to the PLTDeviceInfoObserver protocol), this method is called when new device info is available.
	// we must check the info's 'class' to see which subclass of PLTInfo it is.
	
	//NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
		PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
		
		[self.headingIndicator setDoubleValue:eulerAngles.x];
		[self.pitchIndicator setDoubleValue:eulerAngles.y];
		[self.rollIndicator setDoubleValue:eulerAngles.z];
		
		self.headingTextField.stringValue = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.x)];
		self.pitchTextField.stringValue = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.y)];
		self.rollTextField.stringValue = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.z)];
	}
	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
        PLTWearingStateInfo *i = (PLTWearingStateInfo *)theInfo;
        self.wearingStateTextField.stringValue = (i.isBeingWorn ? @"yes" : @"no");
    }
    else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
        PLTProximityInfo *i = (PLTProximityInfo *)theInfo;
        self.localProximityTextField.stringValue = NSStringFromProximity(i.localProximity);
		self.localProximityTextField.stringValue = NSStringFromProximity(i.remoteProximity);
    }
    else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
        PLTTapsInfo *i = (PLTTapsInfo *)theInfo;
        if (i.count) self.tapsTextField.stringValue = [NSString stringWithFormat:@"%lu in %@", (unsigned long)i.count, NSStringFromTapDirection(i.direction)];
        else self.tapsTextField.stringValue = @"-";
    }
    else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
        PLTFreeFallInfo *i = (PLTFreeFallInfo *)theInfo;
        self.freeFallTextField.stringValue = (i.isInFreeFall ? @"yes" : @"no");
    }
    else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
        PLTPedometerInfo *i = (PLTPedometerInfo *)theInfo;
        self.pedometerTextField.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)i.steps];
    }
    else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
        PLTGyroscopeCalibrationInfo *i = (PLTGyroscopeCalibrationInfo *)theInfo;
        self.gyroscopeCalLabel.stringValue = (i.isCalibrated ? @"yes" : @"no");
    }
	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
        PLTMagnetometerCalibrationInfo *i = (PLTMagnetometerCalibrationInfo *)theInfo;
        self.magnetometerCalLabel.stringValue = (i.isCalibrated ? @"yes" : @"no");
    }
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
	NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - NSWindowController

- (id)init
{
	if (self = [super initWithWindowNibName:@"MainWindow.xib"]) {
        
		// connection open
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
			NSLog(@"Device conncetion open: %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
			
			[self setUIConnected:YES];
			
			// now that a connection is established, subscribe to all services with mode "on-change"
			
			NSError *err = nil;
			
			[self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to wearing state service: %@", err);
			
			[self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to proximity service: %@", err);
			
			[self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to orientation tracking state service: %@", err);
			
			[self.device subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to pedometer service: %@", err);
			
			[self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to free fall service: %@", err);
			
			[self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to taps service: %@", err);
			
			[self.device subscribe:self toService:PLTServiceMagnetometerCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to magnetometer calibration service: %@", err);
			
			[self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange andPeriod:0 error:&err];
			if (err) NSLog(@"Error subscribing to hyroscope calibration service: %@", err);
			
			// "zero" orientation tracking to current orientation
			
			[self.device setCalibration:nil forService:PLTServiceOrientationTracking error:&err];
			if (err) NSLog(@"Error calibrating orientation tracking: %@", err);
		}];
		
		// connection failed
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidFailOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
			PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			NSInteger error = [(NSNumber *)([note userInfo][PLTDeviceConnectionErrorNotificationKey]) intValue];
			
			NSLog(@"Device conncetion failed with error: %ld, device: %@", (long)error, device);
			
			self.device = nil;
			[self setUIConnected:NO];
		}];
		
		// connection closed
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidCloseConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
			PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			
			NSLog(@"Device conncetion closed: %@", device);
			
			self.device = nil;
			[self setUIConnected:NO];
		}];
		
		// new device available
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceAvailableNotification object:Nil queue:NULL usingBlock:^(NSNotification *note) {
			PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			
			NSLog(@"Device available: %@", device);
			
			// if we're not already connected to a device, connect to this one.
			
			if (!self.device) {
	   NSLog(@"Opening connection to %@...", device);
		  self.device = device;
		  NSError *err = nil;
		  [self.device openConnection:&err];
		  if (err) {
			  NSLog(@"Error opening connection: %@", err);
		  }
			}
		}];
		
		return self;
	}
	return nil;
}

- (NSString *)windowNibName
{
    return @"MainWindow";
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self setUIConnected:NO];
	
    // check to see if there are any devices currently avaialble to conenct to
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		NSError *err = nil;
		[self.device openConnection:&err];
		if (err) {
			NSLog(@"Error opening connection: %@", err);
		}
	}
	else {
		NSLog(@"No available devices.");
	}
}

@end
