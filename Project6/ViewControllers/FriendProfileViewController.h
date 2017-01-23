//
//  FriendProfileViewController.h
//  Project6
//
//  Created by superman on 3/15/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"
#import "MWPhotoBrowser.h"

@interface FriendProfileViewController : ViewController<MWPhotoBrowserDelegate>

@property (nonatomic, strong) PFUser* user;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic,assign) int type;
@property (nonatomic, strong) NSDate *date;

@end
