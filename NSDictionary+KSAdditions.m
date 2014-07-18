//
//  NSDictionary+KSAdditions.m
//
//  Created by Keith Smiley
//

#import "NSDictionary+KSAdditions.h"

@implementation NSDictionary (KSAdditions)

- (NSDictionary *)ks_dictionaryByRemovingNulls
{
    NSMutableDictionary *dict = [self mutableCopy];
    NSSet *keys = [dict keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id key, id obj, BOOL *stop)
    {
        return obj == [NSNull null];
    }];

    [dict removeObjectsForKeys:[keys allObjects]];
    return [dict copy];
}

@end
