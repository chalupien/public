//
//  PLTInfo.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, PLTInfoRequestType) {
	PLTInfoRequestTypeSubscription = 0,
	PLTInfoRequestTypeQuery = 1,
	PLTInfoRequestTypeCached = 2
};


@class PLTDevice;
@class PLTCalibration;

@interface PLTInfo : NSObject

//@property(readonly)	PLTDevice			*device;
@property(nonatomic,readonly)	PLTInfoRequestType	requestType;
@property(nonatomic,readonly)	NSDate				*timestamp;
@property(nonatomic,readonly)	PLTCalibration		*calibration;

@end
