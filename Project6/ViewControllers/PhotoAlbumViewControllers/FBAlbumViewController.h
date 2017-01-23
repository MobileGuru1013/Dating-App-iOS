//
//  FBAlbumViewController.h
//  Project6
//
//  Created by superman on 2/23/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"
#import "Public.h"
#import "MWPhotoBrowser.h"
#import "SDImageCache.h"
#import "MWCommon.h"

@protocol FBAlbumViewControllerDelegate;

@interface FBAlbumViewController : UIViewController<MWPhotoBrowserDelegate>
{
    NSMutableArray *_selections;
    NSMutableArray *selectedPhotos;
}
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *urls;

@property (nonatomic, strong) id<FBAlbumViewControllerDelegate> delegate;

@end

@protocol FBAlbumViewControllerDelegate <NSObject>

- (void)albumDoneBtnClicked:(NSArray*) array;

@end