//
//  AppDelegate.m
//  Example
//
//  Created by Keith Smiley on 7/18/14.
//

#import "AppDelegate.h"
#import <KSGithubStatusAPI/KSGithubStatusAPI.h>
#import <KSGithubStatusAPI/KSGithubStatus.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    KSGithubStatusAPI *statusAPI = [[KSGithubStatusAPI alloc] init];
    [statusAPI checkStatus:^(KSGithubStatus *status) {
        if (status.isAvailable) {
            NSLog(@"Github is available");
        } else {
            NSLog(@"Github isn't available");
        }

        NSLog(@"Status: %@", status.status);
        NSLog(@"Details: %@", status.details);

        NSLog(@"Last Checked: %@", status.readableCreatedAtDate);
        NSLog(@"Last Checked: %@", statusAPI.readableLastCheckedDate);

        NSLog(@"Github updated date: %@", status.readableGithubUpdatedDate);
    }];
}

@end
