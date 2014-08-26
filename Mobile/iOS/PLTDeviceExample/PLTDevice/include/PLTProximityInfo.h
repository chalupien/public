//
//  PLTProximityInfo.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


typedef NS_ENUM(NSUInteger, PLTProximity) {
	PLTProximityFar = 0,
    PLTProximityNear = 1,
	PLTProximityUnknown = 2
};


NSString *NSStringFromProximity(PLTProximity proximity);


@interface PLTProximityInfo : PLTInfo

@property(nonatomic,readonly)	PLTProximity	localProximity;
@property(nonatomic,readonly)	PLTProximity	remoteProximity;

@end
