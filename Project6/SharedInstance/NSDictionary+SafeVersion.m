//
//  NSDictionary+SafeVersion.m
//  RPG
//
//  Created by Mountain on 7/16/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import "NSDictionary+SafeVersion.h"

@implementation NSDictionary (SafeVersion)
- (id) safeObjectForKey: (NSString*) key
{
    NSObject* object = [self objectForKey: key];
    if (object == nil) {
        return nil;
    }
    else
        return object;
    return @"";
}
@end
