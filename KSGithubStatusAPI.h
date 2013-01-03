//
//  KSGithubStatusAPI.h
//  KSGithubStatusAPI Mac
//
//  Created by Keith Smiley on 1/3/13.
//  Copyright (c) 2013 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

// Keys for accessing the currentStatusDetails NSDictionary
static NSString * const kGithubStatusKey = @"status";
static NSString * const kGithubMessageKey = @"body";
static NSString * const kGithubDateKey = @"created_on";
static NSString * const kGithubPrettyDateKey = @"created_on_pretty";

// The different states returned from currentStatus
typedef NS_ENUM(NSInteger, KSGithubStatus) {
    KSGithubStatusNormal,
    KSGithubStatusMinor,
    KSGithubStatusError,
    KSGithubStatusUnknown
};

// Custom Error info
typedef NS_ENUM(NSInteger, KSGithubStatusErrorCode) {
    KSGithubUnreachableError,
    KSGithubUnknownError
};

extern NSString * const KSGithubStatusErrorDomain;


@interface KSGithubStatusAPI : NSObject

+ (KSGithubStatusAPI *)sharedClient;


// Check github's current status with a return block
- (void)checkStatus:(void(^)(NSNumber *available, NSError *error))block;

// Get the most recent status
- (KSGithubStatus)currentStatus;

// Attempt to refresh the status (use checkStatus: instead)
- (void)refresh;

// Returns a bool based of the most recent status
- (BOOL)isGithubAvailable;

// Returns all the data returned from github including the message, status, and updated date along with another pretty formatted date
- (NSDictionary *)currentStatusDetails;


// The date or pretty date of the last time the status was checked
- (NSDate *)lastCheckedDate;
- (NSString *)lastCheckedPrettyDate;


// The acceptable strings Github may return
- (NSArray *)acceptableResponses;
- (void)addAcceptableResponse:(NSString *)response;
- (void)addAcceptableResponses:(NSArray *)responses;

@end
