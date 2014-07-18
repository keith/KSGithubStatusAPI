//
//  KSGithubStatusAPI.h
//
//  Created by Keith Smiley
//

@import Foundation;

@class KSGithubStatus;

typedef void (^KSGithubStatusBlock)(KSGithubStatus *status);

@interface KSGithubStatusAPI : NSObject

@property (nonatomic, readonly) KSGithubStatus *lastStatus;
@property (nonatomic, readonly) NSDate *lastCheckedDate;
@property (nonatomic, readonly) NSString *readableLastCheckedDate;

- (void)checkStatus:(KSGithubStatusBlock)block;

@end
