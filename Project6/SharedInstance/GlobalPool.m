//
//  GlobalPool.m
//  LYchee
//
//  Created by Glenn Chiu on 1/31/13.
//  Copyright (c) 2013 Glenn Chiu. All rights reserved.
//

#import "GlobalPool.h"
#import "Public.h"

@implementation GlobalPool

+ (GlobalPool *)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^
                  {
                      sharedInstance = [self new];
                  });
    
    return sharedInstance;
}

- (id)init {
    
    if(self = [super init]) {
        self.isLoggedIn = NO;
        self.location = [[CLLocation alloc] initWithLatitude:-90.0 longitude:89.99];
        self.cityName = @"Not found";
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [timer fire];
        [self loadStaticValues];
    }
    return self;
    
}

- (void)timerTick:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Timer_Refresh object:nil];
    
}

- (BOOL)unLock:(int) value {
    int currentVal = [[PFUser currentUser][PF_USER_CRONES] intValue];
    currentVal = currentVal - value;
    if(currentVal>=0) {
        [PFUser currentUser][PF_USER_CRONES] = [NSNumber numberWithInt:currentVal];
        [[PFUser currentUser] saveInBackground];
        return YES;
    } else {
        return NO;
    }
}

- (void)loadStaticValues {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([defaults objectForKey:@"about_you"])
        self.about_you = [defaults objectForKey:@"about_you"];
    else
        self.about_you = @"Overview";
    if([defaults objectForKey:@"about_life"])
        self.about_life = [defaults objectForKey:@"about_life"];
    else
        self.about_life = @"Overview";
    if([defaults objectForKey:@"about_me"])
        self.about_me = [defaults objectForKey:@"about_me"];
    else
        self.about_me = @"Overview";

    self.kMatchLimit = 80;
    self.kUnlockLimit = 20;
    self.kMoreMatchLimit = 50;
    
    PFQuery *query_about_you = [PFQuery queryWithClassName:PF_PROFILEOVERVIEW_CLASS];
    [query_about_you findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for(PFObject *object in objects) {
                if([object[PF_PROFILEOVERVIEW_COLNAME] isEqualToString:@"about_you"]) {
                    self.about_you = object[PF_PROFILEOVERVIEW_TITLE];
                    [defaults setValue:self.about_you forKey:@"about_you"];
                }
                
                if([object[PF_PROFILEOVERVIEW_COLNAME] isEqualToString:@"about_life"]) {
                    self.about_life = object[PF_PROFILEOVERVIEW_TITLE];
                    [defaults setValue:self.about_life forKey:@"about_life"];
                }
                
                if([object[PF_PROFILEOVERVIEW_COLNAME] isEqualToString:@"about_me"]) {
                    self.about_me = object[PF_PROFILEOVERVIEW_TITLE];
                    [defaults setValue:self.about_me forKey:@"about_me"];
                }
            }
            
        }
    }];
    
    PFQuery *query_KroneLimit = [PFQuery queryWithClassName:PF_KRONELIMIT_CLASS];
    [query_KroneLimit findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for(PFObject *object in objects) {
                
                if([object[PF_KRONELIMIT_KEY] isEqualToString:PF_KRONELIMIT_KEY_MATCH_LIMIT])
                    self.kMatchLimit = [object[PF_KRONELIMIT_VALUE] intValue];
                if([object[PF_KRONELIMIT_KEY] isEqualToString:PF_KRONELIMIT_KEY_UNLOCK_LIMIT])
                    self.kUnlockLimit = [object[PF_KRONELIMIT_VALUE] intValue];
                if([object[PF_KRONELIMIT_KEY] isEqualToString:PF_KRONELIMIT_KEY_MORE_LIMIT])
                    self.kMoreMatchLimit = [object[PF_KRONELIMIT_VALUE] intValue];
                
            }
        }
    }];
    
}

@end
