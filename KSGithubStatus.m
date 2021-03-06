//
//  KSGithubStatus.m
//
//  Created by Keith Smiley
//

#import "KSGithubStatus.h"
#import "NSDictionary+KSAdditions.h"

// From https://gist.github.com/kyleve/8213806 renamed for collisions
#define KSSQKeyPath(object, keyPath) ({ if (NO) { (void)((object).keyPath); } @#keyPath; })

static NSString * const KSGithubNormalStatus = @"good";
static NSString * const KSGithubMinorStatus = @"minor";
static NSString * const KSGithubErrorStatus = @"error";
static NSString * const KSGithubDateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";

@interface KSGithubStatus ()

@property (nonatomic, readwrite) KSGithubStatusState currentState;
@property (nonatomic, readwrite) NSString *status;
@property (nonatomic, readwrite) NSString *details;
@property (nonatomic, readwrite) NSDate *createdAtDate;
@property (nonatomic, readwrite) NSDate *githubUpdatedDate;

@property (nonatomic) NSArray *validStates;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSDateFormatter *readableDateFormatter;

@end

@implementation KSGithubStatus

+ (instancetype)statusWithJSON:(NSDictionary *)JSON
{
    return [[self alloc] initWithJSON:JSON];
}

+ (instancetype)statusWithState:(KSGithubStatusState)state
{
    return [[self alloc] initWithState:state];
}

- (instancetype)initWithJSON:(NSDictionary *)JSON
{
    self = [self init];
    if (!self) return nil;

    [self setupWithJSON:[JSON ks_dictionaryByRemovingNulls]];

    return self;
}

- (instancetype)initWithState:(KSGithubStatusState)state
{
    self = [self init];
    if (!self) return nil;

    self.currentState = state;

    return self;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    self.currentState = KSGithubStatusUnknown;
    self.createdAtDate = [NSDate date];

    return self;
}

- (BOOL)isAvailable
{
    return [self isAvailableForState:self.currentState];
}

#pragma mark - Private

- (void)setupWithJSON:(NSDictionary *)JSON
{
    NSString *statusString = JSON[@"status"];
    self.status = statusString;
    self.currentState = [self statusStateForString:self.status];
    self.details = JSON[@"body"];
    NSString *createdDateString = JSON[@"created_on"];
    self.githubUpdatedDate = [self.dateFormatter dateFromString:createdDateString];
}

- (KSGithubStatusState)statusStateForString:(NSString *)string
{
    if ([string isEqualToString:KSGithubNormalStatus]) {
        return KSGithubStatusNormal;
    } else if ([string isEqualToString:KSGithubMinorStatus]) {
        return KSGithubStatusMinor;
    } else if ([string isEqualToString:KSGithubErrorStatus]) {
        return KSGithubStatusError;
    }

    return KSGithubStatusUnknown;
}

- (NSString *)stringFromStatesState:(KSGithubStatusState)state
{
    if (state == KSGithubStatusNormal) {
        return NSLocalizedString(@"normal", nil);
    } else if (state == KSGithubStatusMinor) {
        return NSLocalizedString(@"minor", nil);
    } else if (state == KSGithubStatusError) {
        return NSLocalizedString(@"error", nil);
    } else if (state == KSGithubStatusUnreachable) {
        return NSLocalizedString(@"unreachable", nil);
    }

    return NSLocalizedString(@"unknown", nil);
}

- (BOOL)isAvailableForState:(KSGithubStatusState)state
{
    return [self.validStates containsObject:@(state)];
}

#pragma mark - Lazy Accessors

- (NSString *)status
{
    if (!_status) {
        _status = [self stringFromStatesState:self.currentState];
    }

    return _status;
}

- (NSArray *)validStates
{
    if (!_validStates) {
        _validStates = @[@(KSGithubStatusNormal), @(KSGithubStatusMinor)];
    }

    return _validStates;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = KSGithubDateFormat;
        _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _dateFormatter.locale = [NSLocale currentLocale];
    }

    return _dateFormatter;
}

- (NSDateFormatter *)readableDateFormatter
{
    if (!_readableDateFormatter) {
        _readableDateFormatter = [[NSDateFormatter alloc] init];
        _readableDateFormatter.locale = [NSLocale currentLocale];
        _readableDateFormatter.timeStyle = NSDateFormatterShortStyle;
        _readableDateFormatter.dateStyle = NSDateFormatterShortStyle;
    }

    return _readableDateFormatter;
}

- (NSString *)readableCreatedAtDate
{
    return [self.readableDateFormatter stringFromDate:self.createdAtDate];
}

- (NSString *)readableGithubUpdatedDate
{
    return [self.readableDateFormatter stringFromDate:self.githubUpdatedDate];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.currentState forKey:KSSQKeyPath(self, currentState)];
    [aCoder encodeObject:self.status forKey:KSSQKeyPath(self, status)];
    [aCoder encodeObject:self.details forKey:KSSQKeyPath(self, details)];
    [aCoder encodeObject:self.createdAtDate forKey:KSSQKeyPath(self, createdAtDate)];
    [aCoder encodeObject:self.githubUpdatedDate forKey:KSSQKeyPath(self, githubUpdatedDate)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (!self) return nil;

    self.currentState = [aDecoder decodeIntegerForKey:KSSQKeyPath(self, currentState)];
    self.status = [aDecoder decodeObjectForKey:KSSQKeyPath(self, status)];
    self.details = [aDecoder decodeObjectForKey:KSSQKeyPath(self, details)];
    self.createdAtDate = [aDecoder decodeObjectForKey:KSSQKeyPath(self, createdAtDate)];
    self.githubUpdatedDate = [aDecoder decodeObjectForKey:KSSQKeyPath(self, githubUpdatedDate)];

    return self;
}

@end
