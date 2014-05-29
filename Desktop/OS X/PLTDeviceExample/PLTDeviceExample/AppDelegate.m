//
//  AppDelegate.m
//  PLTDeviceExample
//
//  Created by Morgan Davis on 5/28/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"


@interface AppDelegate ()

@property(nonatomic,strong) MainWindowController *mainWindowController;

@end


@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainWindowController = [[MainWindowController alloc] init];
    [self.mainWindowController showWindow:self];
}

@end
