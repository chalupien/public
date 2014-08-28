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


@interface ViewController () <PLTDeviceSubscriber>

- (IBAction)calibrateButton:(id)sender;
- (void)setUIConnected:(BOOL)flag;

@property(nonatomic,strong)	  PLTDevice				*device;
@property(nonatomic,strong)	  NSTimer					*freeFallResetTimer;
@property(nonatomic,strong)	  NSTimer					*tapsResetTimer;
@property(nonatomic,strong)	  IBOutlet UIButton			*calibrateButton;
@property(nonatomic,strong)	  IBOutlet UIProgressView	*headingProgressView;
@property(nonatomic,strong)	  IBOutlet UIProgressView	*pitchProgressView;
@property(nonatomic,strong)	  IBOutlet UIProgressView	*rollProgressView;
@property(nonatomic,strong)	  IBOutlet UILabel			*headingLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*pitchLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*rollLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*wearingStateLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*localProximityLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*remoteProximityLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*tapsLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*pedometerLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*freeFallLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*magnetometerCalLabel;
@property(nonatomic,strong)	  IBOutlet UILabel			*gyroscopeCalLabel;

@end


@implementation ViewController

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
	   self.headingProgressView.progress = 0;
	   self.pitchProgressView.progress = 0;
	   self.rollProgressView.progress = 0;
	   self.headingLabel.text = @"0˚";
	   self.pitchLabel.text = @"0˚";
	   self.rollLabel.text = @"0˚";
	   self.localProximityLabel.text = @"-";
	   self.localProximityLabel.text = @"-";
	   self.wearingStateLabel.text = @"-";
	   self.tapsLabel.text = @"-";
	   self.freeFallLabel.text = @"-";
	   self.pedometerLabel.text = @"-";
	   self.gyroscopeCalLabel.text = @"-";;
	   self.magnetometerCalLabel.text = @"-";
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
        
        [self.headingProgressView setProgress:(eulerAngles.x + 180.0)/360.0 animated:YES];
        [self.pitchProgressView setProgress:(eulerAngles.y + 90.0)/180.0 animated:YES];
        [self.rollProgressView setProgress:(eulerAngles.z + 180.0)/360.0 animated:YES];
	   
	   self.headingLabel.text = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.x)];
	   self.pitchLabel.text = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.y)];
	   self.rollLabel.text = [NSString stringWithFormat:@"%ld˚", lroundf(eulerAngles.z)];
    }
    else if ([theInfo isKindOfClass:[PLTWearingStateInfo class]]) {
        self.wearingStateLabel.text = (((PLTWearingStateInfo *)theInfo).isBeingWorn ? @"yes" : @"no");
    }
    else if ([theInfo isKindOfClass:[PLTProximityInfo class]]) {
        PLTProximityInfo *proximityInfp = (PLTProximityInfo *)theInfo;
        self.localProximityLabel.text = NSStringFromProximity(proximityInfp.localProximity);
        self.remoteProximityLabel.text = NSStringFromProximity(proximityInfp.remoteProximity);
    }
    else if ([theInfo isKindOfClass:[PLTPedometerInfo class]]) {
        self.pedometerLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)((PLTPedometerInfo *)theInfo).steps];
    }
    else if ([theInfo isKindOfClass:[PLTFreeFallInfo class]]) {
        BOOL isInFreeFall = ((PLTFreeFallInfo *)theInfo).isInFreeFall;
	   self.freeFallLabel.text = (isInFreeFall ? @"yes" : @"no");
    }
    else if ([theInfo isKindOfClass:[PLTTapsInfo class]]) {
        PLTTapsInfo *tapsInfo = (PLTTapsInfo *)theInfo;
        NSString *directionString = NSStringFromTapDirection(tapsInfo.direction);
        self.tapsLabel.text = [NSString stringWithFormat:@"%lu in %@", (unsigned long)tapsInfo.count, directionString];
    }
    else if ([theInfo isKindOfClass:[PLTMagnetometerCalibrationInfo class]]) {
        self.magnetometerCalLabel.text = (((PLTMagnetometerCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no");
    }
    else if ([theInfo isKindOfClass:[PLTGyroscopeCalibrationInfo class]]) {
        self.gyroscopeCalLabel.text = (((PLTGyroscopeCalibrationInfo *)theInfo).isCalibrated ? @"yes" : @"no" );
    }
}

- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription
{
    NSLog(@"PLTDevice: %@, didChangeSubscription: %@, toSubscription: %@", self, oldSubscription, newSubscription);
}

#pragma mark - UIViewContorller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (DEVICE_IPAD) self = [super initWithNibName:@"ViewController_iPad" bundle:nil];
    else self = [super initWithNibName:@"ViewController_iPhone" bundle:nil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register for device connectivity-related notifications
    
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
    [[NSNotificationCenter defaultCenter] addObserverForName:PLTDeviceAvailableNotification object:nil queue:NULL usingBlock:^(NSNotification *note) {
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUIConnected:NO];
    
    // check to see if there are any devices currently avaialble to conenct to
    
    NSArray *devices = [PLTDevice availableDevices];
    if ([devices count]) {
        self.device = devices[0];
	   NSLog(@"Opening connection to %@...", self.device);
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
