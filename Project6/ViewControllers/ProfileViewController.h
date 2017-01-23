//
//  ProfileViewController
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"
#import "MWPhotoBrowser.h"

@interface ProfileViewController : ViewController<MWPhotoBrowserDelegate>

@property (nonatomic, strong) PFUser* user;
@property (nonatomic, strong) NSMutableArray *photos;

@end
