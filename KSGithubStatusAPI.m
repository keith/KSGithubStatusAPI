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

static NSString * const KSGithubLastStatusKey = @"KSGithubStatusAPILastStatus";

@interface KSGithubStatusAPI ()

@property (nonatomic, readwrite) KSGithubStatus *lastStatus;

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

- (void)dealloc
{
    NSData *statusData = [NSKeyedArchiver archivedDataWithRootObject:self.lastStatus];
    [[NSUserDefaults standardUserDefaults] setObject:statusData forKey:KSGithubLastStatusKey];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.lastStatus = [KSGithubStatus statusWithState:KSGithubStatusUnknown];
                block(self.lastStatus);
                return;
            }

            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            KSGithubStatus *status = [KSGithubStatus statusWithJSON:JSON];
            self.lastStatus = status;
            block(self.lastStatus);
        });
    }] resume];
}

- (NSURLRequest *)requestForStatusAPI
{
    NSURL *requestURL = [NSURL URLWithString:KSGithubAPIURLString];
    return [NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
}

- (KSGithubStatus *)lastStatus
{
    if (!_lastStatus) {
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:KSGithubLastStatusKey];
        _lastStatus = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    return _lastStatus;
}

- (NSDate *)lastCheckedDate
{
    return self.lastStatus.createdAtDate;
}

- (NSString *)readableLastCheckedDate
{
    return self.lastStatus.readableCreatedAtDate;
}

@end
