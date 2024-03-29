//
//  AppDelegate.m
//  PLTDeviceExample
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"



@interface PLTDLogger : NSObject
+ (PLTDLogger *)sharedLogger;
@property(nonatomic,assign)	NSInteger	level;
@end


@interface AppDelegate ()

@property(nonatomic,strong) MainWindowController *mainWindowController;

@end


@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[PLTDLogger sharedLogger].level = 0;
    self.mainWindowController = [[MainWindowController alloc] init];
    [self.mainWindowController showWindow:self];
}

@end
