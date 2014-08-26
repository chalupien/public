//
//  PLTOrientationTrackingInfo.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/9/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


typedef struct {
	double x;
	double y;
	double z;
} PLTEulerAngles;

typedef struct {
	double w;
	double x;
	double y;
	double z;
} PLTQuaternion;


PLTEulerAngles EulerAnglesFromQuaternion(PLTQuaternion quaternion);
PLTQuaternion QuaternionFromEulerAngles(PLTEulerAngles eulerAngles);
NSString *NSStringFromEulerAngles(PLTEulerAngles angles);
NSString *NSStringFromQuaternion(PLTQuaternion quaternion);


@interface PLTOrientationTrackingInfo : PLTInfo

@property(nonatomic,readonly)	PLTEulerAngles	eulerAngles;
@property(nonatomic,readonly)	PLTQuaternion	quaternion;

@end
