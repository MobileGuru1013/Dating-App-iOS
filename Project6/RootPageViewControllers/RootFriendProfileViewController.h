//
//  RootFriendProfileViewController.h
//  Project6
//
//  Created by superman on 3/15/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"
#import "SHViewPager.h"
#import "Public.h"

@interface RootFriendProfileViewController : UIViewController

@property (nonatomic,strong) PFUser *user;
@property (nonatomic,assign) int type;
@property (nonatomic,strong) NSDate *date;

@property (nonatomic, assign) BOOL isDeepLink;

@end
