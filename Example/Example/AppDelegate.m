//
//  AppDelegate.m
//  Example
//
//  Created by Keith Smiley on 7/18/14.
//

#import "AppDelegate.h"
#import <KSGithubStatusAPI/KSGithubStatusAPI.h>

@implementation AppDelegate

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
