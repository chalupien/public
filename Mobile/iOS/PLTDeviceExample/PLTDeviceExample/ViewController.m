//
//  ViewController.m
//  PLTDeviceExample
//
//  Created by Davis, Morgan on 9/12/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "ViewController.h"
#import "PLTDevice.h"


#define DEVICE_IPAD         ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


@interface ViewController () <PLTDeviceConnectionDelegate, PLTDeviceInfoObserver>

- (void)newDeviceAvailableNotification:(NSNotification *)notification;
- (void)subscribeToInfo;
- (void)startFreeFallResetTimer;
- (void)stopFreeFallResetTimer;
- (void)freeFallResetTimer:(NSTimer *)theTimer;
- (void)startTapsResetTimer;
- (void)stopTapsResetTimer;
- (void)tapsResetTimer:(NSTimer *)theTimer;
- (IBAction)calibrateOrientationButton:(id)sender;

@property(nonatomic, strong)	PLTDevice				*device;
@property(nonatomic, strong)	NSTimer					*freeFallResetTimer;
@property(nonatomic, strong)	NSTimer					*tapsResetTimer;
@property(nonatomic, strong)	IBOutlet UIProgressView	*headingProgressView;
@property(nonatomic, strong)	IBOutlet UIProgressView	*pitchProgressView;
@property(nonatomic, strong)	IBOutlet UIProgressView	*rollProgressView;
@property(nonatomic, strong)	IBOutlet UILabel		*headingLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*pitchLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*rollLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*wearingStateLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*mobileProximityLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*pcProximityLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*tapsLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*pedometerLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*freeFallLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*magnetometerCalLabel;
@property(nonatomic, strong)	IBOutlet UILabel		*gyroscopeCalLabel;

@end


@implementation ViewController

#pragma mark - Private

- (void)newDeviceAvailableNotification:(NSNotification *)notification
{
	NSLog(@"newDeviceAvailableNotification: %@", notification);
	
	if (!self.device) {
		self.device = notification.userInfo[PLTDeviceNewDeviceNotificationKey];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
}

- (void)subscribeToInfo
{
    NSError *err = [self.device subscribe:self toService:PLTServiceOrientationTracking withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceWearingState withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceProximity withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServicePedometer withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceFreeFall withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    // note: this doesn't work right.
    err = [self.device subscribe:self toService:PLTServiceTaps withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceMagnetometerCalStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
    
    err = [self.device subscribe:self toService:PLTServiceGyroscopeCalibrationStatus withMode:PLTSubscriptionModeOnChange minPeriod:0];
    if (err) NSLog(@"Error: %@", err);
}

- (void)startFreeFallResetTimer
{
	// currrently free fall is only reported as info indicating isInFreeFall, immediately followed by info indicating !isInFreeFall (during is not yet supported)
	// so to make sure the user sees a visual indication of the device having been in/is in free fall, a timer is used to display "Free Fall? yes" for three seconds.
	
	[self stopFreeFallResetTimer];
	self.freeFallResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(freeFallResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopFreeFallResetTimer
{
	if ([self.freeFallResetTimer isValid]) {
		[self.freeFallResetTimer invalidate];
		self.freeFallResetTimer = nil;
	}
}

- (void)freeFallResetTimer:(NSTimer *)theTimer
{
	self.freeFallLabel.text = @"no";
}

- (void)startTapsResetTimer
{
	// since taps are only reported in one brief info update, a timer is used to display the most recent taps for three seconds.
	
	[self stopTapsResetTimer];
	self.tapsResetTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(tapsResetTimer:) userInfo:nil repeats:NO];
}

- (void)stopTapsResetTimer
{
	if ([self.tapsResetTimer isValid]) {
		[self.tapsResetTimer invalidate];
		self.tapsResetTimer = nil;
	}
}

- (void)tapsResetTimer:(NSTimer *)theTimer
{
	self.tapsLabel.text = @"-";
}

- (IBAction)calibrateOrientationButton:(id)sender
{
	// zero's orientation tracking
	[self.device setCalibration:nil forService:PLTServiceOrientationTracking];
}

#pragma mark - PLTDeviceConnectionDelegate

- (void)PLTDeviceDidOpenConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidOpenConnection: %@", aDevice);
    
    [self subscribeToInfo];
}

- (void)PLTDevice:(PLTDevice *)aDevice didFailToOpenConnection:(NSError *)error
{
	NSLog(@"PLTDevice: %@ didFailToOpenConnection: %@", aDevice, error);
	self.device = nil;
}

- (void)PLTDeviceDidCloseConnection:(PLTDevice *)aDevice
{
	NSLog(@"PLTDeviceDidCloseConnection: %@", aDevice);
	self.device = nil;
}

#pragma mark - PLTDeviceInfoObserver

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo
{
	NSLog(@"PLTDevice: %@ didUpdateInfo: %@", aDevice, theInfo);
	
	if ([theInfo isKindOfClass:[PLTOrientationTrackingInfo class]]) {
         PLTEulerAngles eulerAngles = ((PLTOrientationTrackingInfo *)theInfo).eulerAngles;
         self.headingLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.x)];
         [self.headingProgressView setProgress:(eulerAngles.x + 180.0)/360.0 animated:YES];
         self.pitchLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.y)];
         [self.pitchProgressView setProgress:(eulerAngles.y + 180.0)/360.0 animated:YES];
         self.rollLabel.text = [NSString stringWithFormat:@"%ldº", lroundf(eulerAngles.z)];
         [self.rollProgressView setProgress:(eulerAngles.z + 180.0)/360.0 animated:YES];
	}
	else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
		self.wearingStateLabel.text = (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no");
	}
	else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
		PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
		self.mobileProximityLabel.text = NSStringFromProximity(proximityInfp.mobileProximity);
		self.pcProximityLabel.text = NSStringFromProximity(proximityInfp.pcProximity);
	}
	else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
		self.pedometerLabel.text = [NSString stringWithFormat:@"%u", ((PLTPedometerInfo *)theInfo).steps];
	}
	else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
		BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
		if (isInFreeFall) {
			self.freeFallLabel.text = (isInFreeFall ? @"yes" : @"no");
			[self startFreeFallResetTimer];
		}
	}
	else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
		PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
		NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
		self.tapsLabel.text = [NSString stringWithFormat:@"%u in %@", tapsInfo.taps, directionString];
		[self startTapsResetTimer];
	}
	else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
		self.magnetometerCalLabel.text = (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no");
	}
	else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
		self.gyroscopeCalLabel.text = (((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no" );
	}
}

#pragma mark - UIViewContorller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (DEVICE_IPAD) self = [super initWithNibName:@"ViewController_iPad" bundle:nil];
    else self = [super initWithNibName:@"ViewController_iPhone" bundle:nil];
	return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSArray *devices = [PLTDevice availableDevices];
	if ([devices count]) {
		self.device = devices[0];
		self.device.connectionDelegate = self;
		[self.device openConnection];
	}
	else {
		NSLog(@"No available devices.");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceAvailableNotification:) name:PLTDeviceNewDeviceAvailableNotification object:nil];
}

@end
