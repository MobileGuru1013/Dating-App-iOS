//
//  FBAlbumViewController.m
//  Project6
//
//  Created by superman on 2/23/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "FBAlbumViewController.h"

@interface FBAlbumViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *albumArray;
}
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation FBAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneBtnClicked)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"My Album";
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width,self.view.height-64) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.tag = 10;
        tableView.backgroundView = nil;
        tableView.bounces = NO;
        tableView;
    });
    
    [self.view addSubview:self.tableView];
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    [FBRequestConnection startWithGraphPath:@"/me/albums"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                              [[KIProgressViewManager manager] hideProgressView];
                              albumArray = [NSArray arrayWithArray:[result objectForKey:@"data"]];
                              [self.tableView reloadData];
                          }];
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    selectedPhotos = [NSMutableArray array];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.textLabel.textColor = COLOR_IN_DARK_GRAY;
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dictAlbum = [albumArray objectAtIndex:indexPath.row];
    if([[dictAlbum valueForKey:@"count"] intValue] > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [dictAlbum valueForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Photos",[dictAlbum valueForKey:@"count"]];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = YES;
    BOOL displayNavArrows = YES;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;

    NSDictionary *dictAlbum = [albumArray objectAtIndex:indexPath.row];
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/photos",[dictAlbum valueForKey:@"id"]]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                              [[KIProgressViewManager manager] hideProgressView];
                              NSMutableArray *photos = [[NSMutableArray alloc] init];
                              NSMutableArray *thumbs = [[NSMutableArray alloc] init];
                              NSMutableArray *urls = [[NSMutableArray alloc] init];
                              
                              for(NSDictionary *dictPhoto in [result objectForKey:@"data"]) {
                                  [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dictPhoto valueForKey:@"source"]]]];
                                  [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dictPhoto valueForKey:@"picture"]]]];
                                  NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[dictPhoto valueForKey:@"source"],@"picture",[dictPhoto valueForKey:@"picture"],@"thumb", nil];
                                  [urls addObject:dictionary];
                              }                              
                              self.photos = photos;
                              self.thumbs = thumbs;
                              self.urls = urls;
                              
                              MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                              browser.displayActionButton = displayActionButton;
                              browser.displayNavArrows = displayNavArrows;
                              browser.displaySelectionButtons = displaySelectionButtons;
                              browser.alwaysShowControls = displaySelectionButtons;
                              browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                              browser.wantsFullScreenLayout = YES;
#endif
                              browser.enableGrid = enableGrid;
                              browser.startOnGrid = startOnGrid;
                              browser.enableSwipeToDismiss = YES;
                              
                              [browser setCurrentPhotoIndex:0];
                              
                              if (displaySelectionButtons) {
                                  _selections = [NSMutableArray new];
                                  for (int i = 0; i < photos.count; i++) {
                                      [_selections addObject:[NSNumber numberWithBool:NO]];
                                  }
                              }
                              
                              [self.navigationController pushViewController:browser animated:YES];

                              double delayInSeconds = 3;
                              dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                              dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                  
                              });

                          }];
}
#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
//    return [[_selections objectAtIndex:index] boolValue];
//  
    NSDictionary *dictionary = [self.urls objectAtIndex:index];
    if((int)[selectedPhotos indexOfObject:dictionary]>=0) {
        return YES;
    } else {
        return NO;
    }
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    
    NSDictionary *dictionary = [self.urls objectAtIndex:index];

    if(selected) {
        [selectedPhotos addObject:dictionary];
    } else {
        [selectedPhotos removeObject:dictionary];
    }
    if(selectedPhotos.count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.title = [NSString stringWithFormat:@"My Album(%d)",(int)selectedPhotos.count];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.title = @"My Album";
    }
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)doneBtnClicked {
    if(self.delegate && [self.delegate respondsToSelector:@selector(albumDoneBtnClicked:)]) {
        [self.delegate albumDoneBtnClicked:selectedPhotos];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)privateDoneBtnClicked:(MWPhotoBrowser *)browser {
    if(self.delegate && [self.delegate respondsToSelector:@selector(albumDoneBtnClicked:)]) {
        [self.delegate albumDoneBtnClicked:selectedPhotos];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
