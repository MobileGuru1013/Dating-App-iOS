//
//  CreateTestViewController.h
//  Project6
//
//  Created by superman on 2/22/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"
#import "MWPhotoBrowser.h"
#import "SDImageCache.h"
#import "MWCommon.h"

@interface CreateTestViewController : ViewController <MWPhotoBrowserDelegate>
{
    NSMutableArray *_selections;
    NSMutableArray *selectedPhotos;
}
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *urls;

@end
