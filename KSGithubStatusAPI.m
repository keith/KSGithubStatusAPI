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

// Github URL strings
static NSString * const kGithubAPIURLString = @"https://status.github.com/api/";
static NSString * const kGithubStatusReachabilityString = @"status.github.com";
static NSString * const kGithubReachabilityString = @"github.com";
static NSString * const kGithubLastAPIString = @"last-message.json";

// Github Status Strings
static NSString * const kGithubNormalStatus = @"good";
static NSString * const kGithubMinorStatus = @"minor";
static NSString * const kGithubErrorStatus = @"error";

static NSString * const kGithubLastCheckedKey = @"githubAvailabilityLastChecked";
NSString * const KSGithubStatusErrorDomain = @"com.keithsmiley.KSGithubStatusAPI";


@interface KSGithubStatusAPI()
// List of acceptable responses
@property (nonatomic, strong) NSMutableArray *validResponses;

// Most recent response string
@property (nonatomic, strong) NSString *currentAvailability;

// All info passed from github on last check
@property (nonatomic, strong) NSDictionary *currentGithubStatus;

// The time of the last status check
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
    
    // Populate valid responses
    self.validResponses = [NSMutableArray arrayWithObjects:kGithubNormalStatus, kGithubMinorStatus, nil];

    if ([[NSUserDefaults standardUserDefaults] valueForKey:kGithubLastCheckedKey]) {
        [self setLastChecked:[[NSUserDefaults standardUserDefaults] valueForKey:kGithubLastCheckedKey]];
    } else {
        [self setLastChecked:[NSDate distantPast]];
    }
    
    return self;
}

#pragma mark - Requests

- (void)checkStatus:(void(^)(NSNumber *available, NSError *error))block
{
    // Check status.github.com to make sure it's available
    if (![[Reachability reachabilityWithHostname:kGithubStatusReachabilityString] isReachable])
    {
        [self setLastChecked:[NSDate date]];

        // If status.github.com is down check github.com
        if ([[Reachability reachabilityWithHostname:kGithubReachabilityString] isReachable]) {
            if (block) {
                block(@YES, nil);
            }
            self.currentAvailability = kGithubNormalStatus;
        } else {
            if (block) {
                block(@NO, [self statusUnreachableError]);
            }
            self.currentAvailability = kGithubErrorStatus;
        }
        
        return;
    }
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:kGithubAPIURLString]];
    NSURLRequest *request = [client requestWithMethod:@"GET" path:kGithubLastAPIString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        [self setLastChecked:[NSDate date]];

        self.currentAvailability = [JSON valueForKey:kGithubStatusKey];
        
        if ([JSON valueForKey:kGithubDateKey])
        {
            NSString *dateString = [JSON valueForKey:kGithubDateKey];
            NSDate *githubUpdateDate = [NSDate dateWithNaturalLanguageString:[JSON valueForKey:kGithubDateKey]];
            if (githubUpdateDate)
            {
                [self setCurrentStatusWithStatus:[JSON valueForKey:kGithubStatusKey]
                                         message:[JSON valueForKey:kGithubMessageKey]
                                            date:githubUpdateDate
                                      prettyDate:[self prettyDateFromDate:githubUpdateDate]];
            }
            else
            {
                [self setCurrentStatusWithStatus:[JSON valueForKey:kGithubStatusKey]
                                         message:[JSON valueForKey:kGithubMessageKey]
                                            date:nil
                                      prettyDate:dateString];
            }
        }
        else
        {
            [self setCurrentStatusWithStatus:[JSON valueForKey:kGithubStatusKey]
                                     message:[JSON valueForKey:kGithubMessageKey]
                                        date:nil
                                  prettyDate:nil];
        }
        
        if (block) {
            if ([self isGithubAvailable]) {
                block(@YES, nil);
            } else {
                block(@NO, nil);
            }
        }
        
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        [self setLastChecked:[NSDate date]];
        self.currentAvailability = nil;
        
        if (block) {
            block(@NO, [self unknownError]);
        }
        
        NSLog(@"KSGithubStatusAPI Error %@ : %@", [error localizedDescription], error);
    }];
    
    [operation start];
}

- (void)setLastChecked:(NSDate *)lastChecked
{
    [[NSUserDefaults standardUserDefaults] setObject:lastChecked forKey:kGithubLastCheckedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.lastRefresh = lastChecked;
}


#pragma mark - Helper methods

- (KSGithubStatus)currentStatus
{
    if ([self.currentAvailability isEqualToString:kGithubNormalStatus]) {
        return KSGithubStatusNormal;
    } else if ([self.currentAvailability isEqualToString:kGithubMinorStatus]) {
        return KSGithubStatusMinor;
    } else if ([self.currentAvailability isEqualToString:kGithubErrorStatus]) {
        return KSGithubStatusError;
    } else {
        return KSGithubStatusUnknown;
    }
}

- (void)refresh
{
    [self checkStatus:nil];
}

- (BOOL)isGithubAvailable
{
    return [self isAcceptableResponse:self.currentAvailability];
}

- (NSDictionary *)currentStatusDetails
{
    return self.currentGithubStatus;
}

- (void)setCurrentStatusWithStatus:(NSString *)status
                           message:(NSString *)message
                              date:(NSDate *)date
                        prettyDate:(NSString *)prettyDate
{
    self.currentGithubStatus = @{kGithubStatusKey : status, kGithubMessageKey : message, kGithubDateKey : date, kGithubPrettyDateKey : prettyDate};
}

- (NSDate *)lastCheckedDate
{
    return self.lastRefresh;
}

- (NSString *)lastCheckedPrettyDate
{
    return [self prettyDateFromDate:self.lastRefresh];
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

- (BOOL)isAcceptableResponse:(NSString *)response
{
    return [self.validResponses containsObject:response];
}

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
    return [NSError errorWithDomain:KSGithubStatusErrorDomain
                               code:KSGithubUnreachableError
                           userInfo:@{
         NSLocalizedDescriptionKey : NSLocalizedString(@"Github Status Error", @"Error title"),
NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Github is unreachable.", @"Can't access Github")}];
}

- (NSError *)unknownError
{
    return [NSError errorWithDomain:KSGithubStatusErrorDomain
                               code:KSGithubUnknownError
                           userInfo:@{
         NSLocalizedDescriptionKey : NSLocalizedString(@"Github Status Error", @"Error title"),
NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"An unknown error occurred.", @"Unknown error text")}];
}

@end
