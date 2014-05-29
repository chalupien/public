//
//  PLTDevice.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLTCalibration.h"
#import "PLTOrientationTrackingCalibration.h"
#import "PLTPedometerCalibration.h"
#import "PLTInfo.h"
#import "PLTProximityInfo.h"
#import "PLTWearingStateInfo.h"
#import "PLTOrientationTrackingInfo.h"
#import "PLTTapsInfo.h"
#import "PLTPedometerInfo.h"
#import "PLTFreeFallInfo.h"
#import "PLTMagnetometerCalibrationInfo.h"
#import "PLTGyroscopeCalibrationInfo.h"


#define PLT_API_VERSION		2.0


extern NSString *const PLTDeviceAvailableNotification;
extern NSString *const PLTDeviceDidOpenConnectionNotification;
extern NSString *const PLTDeviceDidFailOpenConnectionNotification;
extern NSString *const PLTDeviceDidCloseConnectionNotification;

extern NSString *const PLTDeviceNotificationKey;
extern NSString *const PLTDeviceConnectionErrorNotificationKey;


typedef NS_ENUM(NSUInteger, PLTService) {
	PLTServiceWearingState =				0x1000,
	PLTServiceProximity =                   0x1001,
	PLTServiceOrientationTracking =         0x0000,
	PLTServicePedometer =                   0x0002,
	PLTServiceFreeFall =                    0x0003,
	PLTServiceTaps =                        0x0004,
	PLTServiceMagnetometerCalStatus =       0x0005,
	PLTServiceGyroscopeCalibrationStatus =  0x0006
};

typedef NS_ENUM(NSUInteger, PLTSubscriptionMode) {
	PLTSubscriptionModeOnChange = 0x01,
	PLTSubscriptionModePeriodic = 0x02
};

//typedef NS_ENUM(NSInteger, PLTDeviceErrorCode) {
//	PLTDeviceErrorCodeUnknownError =                -1,
//	PLTDeviceErrorCodeFailedToCreateDataSession =   1,
//	PLTDeviceErrorCodeNoAccessoryAssociated =       2,
//	PLTDeviceErrorCodeConnectionAlreadyOpen =       3,
//	PLTDeviceErrorInvalidArgument =                 4,
//	PLTDeviceErrorInvalidService =                  5,
//	PLTDeviceErrorUnsupportedService =              6,
//	PLTDeviceErrorInvalidMode =                     7,
//	PLTDeviceErrorUnsupportedMode =                 8,
//	PLTDeviceErrorIncompatibleVersions =            9
//};


@class PLTConfiguration;
@class PLTCalibration;
@class PLTInfo;
@protocol PLTDeviceSubscriber;


@interface PLTDevice : NSObject

// discovering devices

+ (NSArray *)availableDevices;

// connecting to and disconnecting from devices

- (void)openConnection;
- (void)closeConnection;

// setting and reading service configurations

- (void)setConfiguration:(PLTConfiguration *)configuration forService:(PLTService)service;
- (PLTConfiguration *)configurationForService:(PLTService)service;

// setting and reading service calibrations

- (void)setCalibration:(PLTCalibration *)calibration forService:(PLTService)service;
- (PLTCalibration *)calibrationForService:(PLTService)service;

// subscribing to and unsubscribing from service info

- (NSError *)subscribe:(id <PLTDeviceSubscriber>)subscriber toService:(PLTService)service withMode:(PLTSubscriptionMode)mode andPeriod:(NSUInteger)period;
- (void)unsubscribe:(id <PLTDeviceSubscriber>)subscriber fromService:(PLTService)service;
- (void)unsubscribeFromAll:(id <PLTDeviceSubscriber>)subscriber;

// querying service info

- (void)queryInfo:(id <PLTDeviceSubscriber>)subscriber forService:(PLTService)service;

// getting caches service info

- (PLTInfo *)cachedInfoForService:(PLTService)service;

// reading device info and state

@property(nonatomic,readonly)	BOOL					isConnectionOpen;
@property(nonatomic,readonly)	NSString				*address;
@property(nonatomic,readonly)	NSString				*model;
@property(nonatomic,readonly)	NSString				*name;
@property(nonatomic,readonly)	NSString				*serialNumber;
@property(nonatomic,readonly)	NSString				*hardwareVersion;
@property(nonatomic,readonly)	NSString				*firmwareVersion;
@property(nonatomic,readonly)	NSArray					*supportedServices;

@end


@interface PLTSubscription : NSObject

@property(nonatomic,readonly)	PLTService				service;
@property(nonatomic,readonly)	PLTSubscriptionMode		mode;
@property(nonatomic,readonly)	uint16_t				period;

@end


@protocol PLTDeviceSubscriber <NSObject>

- (void)PLTDevice:(PLTDevice *)aDevice didUpdateInfo:(PLTInfo *)theInfo;
- (void)PLTDevice:(PLTDevice *)aDevice didChangeSubscription:(PLTSubscription *)oldSubscription toSubscription:(PLTSubscription *)newSubscription;

@end
