//
//  KSAppDelegate.m
//  KSGithubStatusAPI Mac
//
//  Created by Keith Smiley on 1/3/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KSAppDelegate.h"
#import "KSGithubStatusAPI.h"

@implementation KSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[KSGithubStatusAPI sharedClient] checkStatus:^(NSNumber *available, NSError *error) {
        if ([available boolValue]) {
            NSLog(@"Github is available");
        } else {
            NSLog(@"Github isn't available");
        }
        
        NSLog(@"Details: %@", [[KSGithubStatusAPI sharedClient] currentStatusDetails]);
        
        NSLog(@"Last Checked: %@", [[KSGithubStatusAPI sharedClient] lastCheckedDate]);
        NSLog(@"Last Checked Pretty: %@", [[KSGithubStatusAPI sharedClient] lastCheckedPrettyDate]);
    }];
}

@end
