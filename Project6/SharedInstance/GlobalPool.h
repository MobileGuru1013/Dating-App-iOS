//
//  GlobalPool.h
//  LYchee
//
//  Created by Glenn Chiu on 1/31/13.
//  Copyright (c) 2013 Glenn Chiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "INTULocationManager.h"
#import "INTULocationManager+Internal.h"

@interface GlobalPool : NSObject

+ (GlobalPool *)sharedInstance;

@property (nonatomic, assign) BOOL isLoggedIn;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *cityName;

//
@property (nonatomic, strong) NSString *about_me;
@property (nonatomic, strong) NSString *about_life;
@property (nonatomic, strong) NSString *about_you;
//
@property (nonatomic, assign) int kMoreMatchLimit;
@property (nonatomic, assign) int kUnlockLimit;
@property (nonatomic, assign) int kMatchLimit;

- (BOOL)unLock:(int) value;

@end