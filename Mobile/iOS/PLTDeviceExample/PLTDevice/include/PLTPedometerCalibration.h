//
//  PLTPedometerCalibration.h
//  PLTDevice
//
//  Created by Morgan Davis on 5/27/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "PLTCalibration.h"


@interface PLTPedometerCalibration : PLTCalibration

+ (PLTPedometerCalibration *)calibrationWithReset:(BOOL)reset;

@property(nonatomic,assign)	BOOL		reset;

@end
