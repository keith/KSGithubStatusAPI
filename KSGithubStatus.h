//
//  KSGithubStatus.h
//
//  Created by Keith Smiley
//

@import Foundation;

typedef NS_ENUM(NSInteger, KSGithubStatusState) {
    KSGithubStatusNormal,
    KSGithubStatusMinor,
    KSGithubStatusError,
    KSGithubStatusUnknown,
    KSGithubStatusUnreachable
};

@interface KSGithubStatus : NSObject

@property (nonatomic, readonly) NSString *status;
@property (nonatomic, readonly) NSString *details;

@property (nonatomic, readonly) NSDate *createdAtDate;
@property (nonatomic, readonly) NSString *readableCreatedAtDate;

@property (nonatomic, readonly) NSDate *githubUpdatedDate;
@property (nonatomic, readonly) NSString *readableGithubUpdatedDate;

+ (instancetype)statusWithJSON:(NSDictionary *)JSON;
+ (instancetype)statusWithState:(KSGithubStatusState)state;

- (instancetype)initWithJSON:(NSDictionary *)JSON;
- (instancetype)initWithState:(KSGithubStatusState)state;
- (BOOL)isAvailable;

@end
