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

@property(nonatomic,strong)	PLTDevice						*device;
@property(nonatomic,strong)	IBOutlet NSButton				*calibrateButton;
@property(nonatomic,assign) IBOutlet NSTextField            *connectedTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *wearingStateTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *localProximityTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *remoteProximityTextField;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *headingIndicator;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *pitchIndicator;
@property(nonatomic,assign) IBOutlet NSProgressIndicator    *rollIndicator;
@property(nonatomic,assign) IBOutlet NSTextField            *freeFallTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *tapsTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *pedometerTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *gyroCalTextField;
@property(nonatomic,assign) IBOutlet NSTextField            *magnoCalTextField;

@end


@implementation MainWindowController

#pragma mark - Private

- (IBAction)calibrateButton:(id)sender
{
	NSLog(@"calibrateButton:");
	
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
}

- (void)setUIConnected:(BOOL)flag
{
	[self.calibrateButton setEnabled:flag];
	
	if (!flag) {
		self.connectedTextField.stringValue = @"no";
		[self.headingIndicator setDoubleValue:-180];
		[self.pitchIndicator setDoubleValue:-90];
		[self.rollIndicator setDoubleValue:-90];
		self.localProximityTextField.stringValue = @"-";
		self.localProximityTextField.stringValue = @"-";
		self.wearingStateTextField.stringValue = @"-";
		self.tapsTextField.stringValue = @"-";
		self.freeFallTextField.stringValue = @"-";
		self.pedometerTextField.stringValue = @"-";
		self.gyroCalTextField.stringValue = @"-";;
		self.magnoCalTextField.stringValue = @"-";
	}
	else {
		self.connectedTextField.stringValue = @"yes";
	}
}

#pragma mark - PLTDeviceSubscriber

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
    NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
        PLTWearingStateInfo *i = (PLTWearingStateInfo *)theInfo;
        self.wearingStateTextField.stringValue = (i.isBeingWorn ? @"yes" : @"no");
    }
    else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
        PLTProximityInfo *i = (PLTProximityInfo *)theInfo;
        self.localProximityTextField.stringValue = NSStringFromProximity(i.localProximity);
		self.localProximityTextField.stringValue = NSStringFromProximity(i.remoteProximity);
    }
    else if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
        PLTOrientationTrackingInfo *i = (PLTOrientationTrackingInfo *)theInfo;
		PLTEulerAngles eulerAngles = EulerAnglesFromQuaternion(i.quaternion);		
        [self.headingIndicator setDoubleValue:-eulerAngles.x];
        [self.pitchIndicator setDoubleValue:eulerAngles.y];
        [self.rollIndicator setDoubleValue:eulerAngles.z];
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
        self.gyroCalTextField.stringValue = (i.isCalibrated ? @"yes" : @"no");
    }
	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
        PLTMagnetometerCalibrationInfo *i = (PLTMagnetometerCalibrationInfo *)theInfo;
        self.magnoCalTextField.stringValue = (i.isCalibrated ? @"yes" : @"no");
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
        
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceAvailableNotification object:Nil queue:NULL usingBlock:^(NSNotification *note)
		 {
			 PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			 
			 NSLog(@"Device available: %@", device);
			 
			 // if we're not already connected to a device, connect to this one.
			 
			 if (!self.device) {
				 self.device = device;
				 [self.device openConnection];
			 }
		 }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note)
		 {
			 NSLog(@"Device conncetion open: %@", (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]));
			 
			 [self setUIConnected:YES];
			 
			 // now that a connection is established, subscribe to all services with mode "on-change"
			 
			 [self.device subscribe:self toService:PLTServiceOrientationTracking			withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 [self.device setCalibration:nil forService:PLTServiceOrientationTracking];
			 [self.device subscribe:self toService:PLTServiceWearingState					withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 [self.device subscribe:self toService:PLTServiceProximity						withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 [self.device subscribe:self toService:PLTServicePedometer						withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 [self.device subscribe:self toService:PLTServiceFreeFall						withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 [self.device subscribe:self toService:PLTServiceTaps							withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 [self.device subscribe:self toService:PLTServiceMagnetometerCalibrationStatus	withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 [self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus		withMode:PLTSubscriptionModeOnChange	andPeriod:0];
			 
		 }];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidFailOpenConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note)
		 {
			 PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			 NSInteger error = [(NSNumber *)([note userInfo][PLTDeviceConnectionErrorNotificationKey]) intValue];
			 
			 NSLog(@"Device conncetion failed with error: %ld, device: %@", (long)error, device);
			 
			 self.device = nil;
			 [self setUIConnected:NO];
		 }];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceDidCloseConnectionNotification object:nil queue:NULL usingBlock:^(NSNotification *note)
		 {
			 PLTDevice *device = (PLTDevice *)([note userInfo][PLTDeviceNotificationKey]);
			 
			 NSLog(@"Device conncetion closed: %@", device);
			 
			 self.device = nil;
			 [self setUIConnected:NO];
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
	NSLog(@"awakeFromNib");
	
	[super awakeFromNib];
	
	[self setUIConnected:NO];
	
	// look for devices and connect to the first one
	
	NSArray *devices = [PLTDevice availableDevices];
	
	NSLog(@"availableDevices: %@", devices);
	
	if ([devices count]) {
		self.device = devices[0];
		[self.device openConnection];
	}
	else {
		NSLog(@"No devices!");
	}
}

@end
