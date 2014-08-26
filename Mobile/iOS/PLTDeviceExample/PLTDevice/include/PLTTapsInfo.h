//
//  PLTTapsInfo.h
//  PLTDevice
//
//  Created by Morgan Davis on 9/10/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "PLTInfo.h"


typedef NS_ENUM(uint8_t, PLTTapDirection) {
    PLTTapDirectionXUp = 1,
    PLTTapDirectionXDown,
    PLTTapDirectionYUp,
    PLTTapDirectionYDown,
    PLTTapDirectionZUp,
    PLTTapDirectionZDown
};


NSString *NSStringFromTapDirection(PLTTapDirection direction);


@interface PLTTapsInfo : PLTInfo

@property(nonatomic,readonly)	PLTTapDirection	direction;
@property(nonatomic,readonly)	NSUInteger		count;

@end
