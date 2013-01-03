//
//  KSGithubStatusAPI.m
//  KSGithubStatusAPI Mac
//
//  Created by Keith Smiley on 1/3/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import "KSGithubStatusAPI.h"

#import "AFNetworking.h"
#import "Reachability.h"

// Github strings
static NSString * const kGithubAPIURLString = @"https://status.github.com/api/";
static NSString * const kGithubStatusReachabilityString = @"status.github.com";
static NSString * const kGithubReachabilityString = @"github.com";
static NSString * const kGithubLastAPIString = @"last-message.json";
static NSString * const kGithubStatusKey = @"status";
static NSString * const kGithubMessageKey = @"body";
static NSString * const kGithubDateKey = @"created_on";

static NSString * const kGithubNormalStatus = @"good";

static NSString * const kGithubLastCheckedKey = @"githubAvailabilityLastChecked";

@interface KSGithubStatusAPI()

@property (nonatomic, strong) NSMutableArray *validResponses;
@property (nonatomic, strong) NSNumber *currentAvailability;
@property (nonatomic, strong) NSDictionary *currentStatus;
@property (nonatomic, strong) NSDate *lastRefresh;

@end

@implementation KSGithubStatusAPI

+ (KSGithubStatusAPI *)sharedClient
{
    static KSGithubStatusAPI *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    
    return sharedClient;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.validResponses = [NSMutableArray arrayWithObjects:kGithubNormalStatus, nil];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kGithubLastCheckedKey]) {
        self.lastRefresh = [[NSUserDefaults standardUserDefaults] valueForKey:kGithubLastCheckedKey];
    } else {
        self.lastRefresh = [NSDate distantPast];
    }
    
    return self;
}

#pragma mark - Requests

- (void)checkStatus:(void(^)(NSNumber *available, NSError *error))block
{
    if (![[Reachability reachabilityWithHostname:kGithubStatusReachabilityString] isReachable])
    {
        if ([[Reachability reachabilityWithHostname:kGithubReachabilityString] isReachable]) {
            if (block) {
                block(@YES, nil);
            }
        } else {
            if (block) {
                block(@NO, [self statusUnreachableError]);
            }
        }
        
        return;
    }
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:kGithubAPIURLString]];
    NSURLRequest *request = [client requestWithMethod:@"GET" path:kGithubLastAPIString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        self.lastRefresh = [NSDate date];
        
        if ([JSON valueForKey:kGithubStatusKey]) {
            
        }
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        self.lastRefresh = [NSDate date];
        
    }];
    
    [operation start];
}


#pragma mark - Helper methods

- (void)refresh
{
    [self checkStatus:nil];
}

- (BOOL)isGithubAvaliable
{
    self checkStatus:<#^(NSNumber *available, NSError *error)block#>
}

- (NSDictionary *)currentStatus
{
    return self.currentStatus;
}

- (void)setCurrentStatusWithStatus:(NSString *)status
                           message:(NSString *)message
                       dataCreated:(NSDate *)date
{
    self.currentStatus = @{kGithubStatusKey : status, kGithubMessageKey : message, kGithubDateKey : date};
}

- (NSDate *)lastCheckedDate
{
    return self.lastRefresh;
}

- (NSString *)lastCheckedDateString
{
    [self prettyDateFromDate:self.lastRefresh];
}

- (NSString *)prettyDateFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:date];
}

#pragma mark - Acceptable Responses

- (NSArray *)acceptableResponses
{
    return [self.validResponses copy];
}

- (void)addAcceptableResponse:(NSString *)response
{
    [self.validResponses addObject:response];
}

- (void)addAcceptableResponses:(NSArray *)responses
{
    for (NSString *response in responses) {
        if (response.length > 0) {
            [self.validResponses addObject:response];
        }
    }
}

#pragma mark - Custom NSErrors

- (NSError *)statusUnreachableError
{
//    return [NSError errorWithDomain:<#(NSString *)#> code:<#(NSInteger)#> userInfo:<#(NSDictionary *)#>]
}

@end
