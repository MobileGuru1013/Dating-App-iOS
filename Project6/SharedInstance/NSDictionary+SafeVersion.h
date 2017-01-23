//
//  NSDictionary+SafeVersion.h
//  RPG
//
//  Created by Mountain on 7/16/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SafeVersion)
- (id) safeObjectForKey: (NSString*) key;
@end
