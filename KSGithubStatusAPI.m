//
//  KSGithubStatusAPI.m
//
//  Created by Keith Smiley
//

#import "KSGithubStatusAPI.h"
#import "KSGithubStatus.h"

#import "Reachability.h"

// Github URL strings
static NSString * const KSGithubAPIURLString = @"https://status.github.com/api/last-message.json";
static NSString * const KSGithubStatusReachabilityString = @"status.github.com";
static NSString * const KSGithubReachabilityString = @"github.com";

static NSString * const KSGithubLastCheckedKey = @"githubAvailabilityLastChecked";
NSString * const KSGithubStatusErrorDomain = @"com.keithsmiley.KSGithubStatusAPI";


@interface KSGithubStatusAPI ()

@property (nonatomic, readwrite) KSGithubStatus *lastStatus;
@property (nonatomic, readwrite) NSDate *lastCheckedDate;
@property (nonatomic, readwrite) NSString *readableLastCheckedDate;

@end

@implementation KSGithubStatusAPI

@synthesize lastCheckedDate = _lastCheckedDate;

- (BOOL)isGithubStatusReachable
{
    return [[Reachability reachabilityWithHostname:KSGithubStatusReachabilityString] isReachable];
}

- (BOOL)isGithubReachable
{
    return [[Reachability reachabilityWithHostname:KSGithubReachabilityString] isReachable];
}

- (void)checkStatus:(KSGithubStatusBlock)block
{
    if (![self isGithubStatusReachable]) {
        [self statusBasedOnReachability:block];
        return;
    }

    [self statusBasedOnStatusAPI:block];
}

- (void)statusBasedOnReachability:(KSGithubStatusBlock)block
{
    KSGithubStatus *status;

    if ([self isGithubReachable]) {
        status = [KSGithubStatus statusWithState:KSGithubStatusMinor];
    } else {
        status = [KSGithubStatus statusWithState:KSGithubStatusUnreachable];
    }

    self.lastStatus = status;
    block(self.lastStatus);
}

- (void)statusBasedOnStatusAPI:(KSGithubStatusBlock)block
{
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self requestForStatusAPI]
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error) {
            self.lastStatus = [KSGithubStatus statusWithState:KSGithubStatusUnknown];
            block(self.lastStatus);
            return;
        }

        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        KSGithubStatus *status = [KSGithubStatus statusWithJSON:JSON];
        self.lastStatus = status;
        block(self.lastStatus);
    }] resume];
}

- (NSURLRequest *)requestForStatusAPI
{
    NSURL *requestURL = [NSURL URLWithString:KSGithubAPIURLString];
    return [NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
}

- (void)setLastStatus:(KSGithubStatus *)lastStatus
{
    _lastStatus = lastStatus;
    self.lastCheckedDate = lastStatus.createdAtDate;
    self.readableLastCheckedDate = lastStatus.readableCreatedAtDate;
}

- (void)setLastCheckedDate:(NSDate *)lastCheckedDate
{
    [[NSUserDefaults standardUserDefaults] setObject:lastCheckedDate forKey:KSGithubLastCheckedKey];
    _lastCheckedDate = lastCheckedDate;
}

- (NSDate *)lastCheckedDate
{
    if (!_lastCheckedDate) {
        _lastCheckedDate = [[NSUserDefaults standardUserDefaults] objectForKey:KSGithubLastCheckedKey];
    }

    return _lastCheckedDate;
}

@end
