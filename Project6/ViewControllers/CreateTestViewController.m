//
//  CreateTestViewController.m
//  Project6
//
//  Created by superman on 2/22/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "CreateTestViewController.h"
#import "AppDelegate.h"

#define kSmallWidth 100

@interface CreateTestViewController ()
{
    NSArray *albumArray;
    NSMutableArray *photoArray;
    UIImageView *testBoxView;
}
@end

@implementation CreateTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Create Test";
    photoArray = [NSMutableArray array];
    
    testBoxView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSmallWidth*5, kSmallWidth*2)];
    
    [self.view addSubview:testBoxView];
    
    UILabel *lblIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(10, testBoxView.bottom + 5, self.view.width-20, 220)];
    lblIntroduction.textAlignment = NSTextAlignmentLeft;
    lblIntroduction.textColor = COLOR_IN_DARK_GRAY;
    lblIntroduction.font = [UIFont systemFontOfSize:12];
    lblIntroduction.numberOfLines = 14;
    lblIntroduction.text = @"Profile pictures are one of the most important factors in online dating. We want all our users to find success so we created Phototastic to help everyone find their best photos.\n\nYou can chose up to 10 photos from your profile pictures and create a test. Your profile photo will be rated by the gender you are looking for. Each photo will require you to rate 5 others in return. (i.e. If you have 2 photos in a test you must rate 10 others to unlock the result.)\n\nEach day you can rate up to 50 others and when you are not rating for your own test,you can earn 1 Krone for every 10 people you rate.";
    
    [self.view addSubview:lblIntroduction];

    UIButton *startTestBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 160, 32)];
    [startTestBtn setTitle:@"Start a Test Now!" forState:UIControlStateNormal];

    startTestBtn.bottom = self.view.height-64-44-12-6;
    [startTestBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [startTestBtn addTarget:self action:@selector(startTestBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    startTestBtn.centerX = self.view.width/2;
    [startTestBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    [startTestBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [startTestBtn setBackgroundColor:COLOR_BUTTON];
    [startTestBtn.layer setCornerRadius:6.0];
    startTestBtn.layer.masksToBounds = YES;
    
    startTestBtn.enabled = NO;
    
    [self.view addSubview:startTestBtn];

    PFQuery *query = [PFQuery queryWithClassName:PF_CONTEST_CLASS];
    [query whereKey:PF_CONTEST_USER equalTo:[PFUser currentUser]];
    [query whereKey:@"createdAt" greaterThan:[NSDate dateYesterday]];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(!error) {
            if(number == 0) {
                startTestBtn.enabled = YES;
            } else {
                startTestBtn.enabled = YES;
            }
        }
    }];
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    [FBRequestConnection startWithGraphPath:@"/me/albums"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                              [[KIProgressViewManager manager] hideProgressView];
                              albumArray = [NSArray arrayWithArray:[result objectForKey:@"data"]];
                              NSLog(@"%@",result);
                              [self loadPhotosFromAlbum];
                              
                          }];

    
    // Do any additional setup after loading the view.
}
- (void) loadPhotosFromAlbum {
    int sum = 0;

    for(NSDictionary *dictAlbum in albumArray) {
        
        sum+=[[dictAlbum objectForKey:@"count"] intValue];
    }
    
    for(NSDictionary *dictAlbum in albumArray) {
        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/photos",[dictAlbum valueForKey:@"id"]]
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
                                  
                                  for(NSDictionary *dictPhoto in [result objectForKey:@"data"]) {
                                      NSDictionary *dict_photo = [NSDictionary dictionaryWithObjectsAndKeys:[dictPhoto valueForKey:@"source"],@"source",[dictPhoto valueForKey:@"picture"],@"picture", nil];

                                      [photoArray addObject:dict_photo];
                                      AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                                      appDelegate.photoArray = photoArray;
                                  }
                                  if(photoArray.count == sum) {
                                      NSLog(@"the end");
                                      [self loadAnimations];
                                  }
                              }];

    }
}
- (void)loadAnimations {
    
    for(int i=0; i<photoArray.count/2; i++) {
        
        NSDictionary *dict_photo = [photoArray objectAtIndex:i];
        NSString *str_photo = [dict_photo objectForKey:@"picture"];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*kSmallWidth, 0, kSmallWidth, kSmallWidth)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setImageWithURL:[NSURL URLWithString:str_photo]];
        [testBoxView addSubview:imageView];
        
    }
    
    for(int i= (int)photoArray.count/2; i<photoArray.count; i++) {
        
        NSDictionary *dict_photo = [photoArray objectAtIndex:i];
        NSString *str_photo = [dict_photo objectForKey:@"picture"];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((i-(int)photoArray.count/2)*kSmallWidth, kSmallWidth, kSmallWidth, kSmallWidth)];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setImageWithURL:[NSURL URLWithString:str_photo]];
        [testBoxView addSubview:imageView];
    }
    
    [UIView animateWithDuration:20.0 delay:0 options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat) animations:^{
        testBoxView.transform = CGAffineTransformMakeTranslation(-testBoxView.width, 0);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:20.0 animations:^{
            testBoxView.transform = CGAffineTransformIdentity;
        } completion:nil];
        
    }];

}
- (void)startTestBtnClicked {
    
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = YES;
    BOOL displayNavArrows = YES;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dictPhoto in photoArray) {
        [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dictPhoto valueForKey:@"picture"]]]];
        [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[dictPhoto valueForKey:@"source"]]]];
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
             AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            appDelegate.selectArry = _selections;
        }
    }
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:151.0/255.0 green:79.0/255.0 blue:181.0/255.0 alpha:1.0];
    
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });

    [self.navigationController pushViewController:browser animated:YES];
//    [self.navigationController presentViewController:browser animated:YES completion:ni]
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
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
        self.title = @"Create Test";
    }
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneBtnClicked {

}

- (void)privateDoneBtnClicked:(MWPhotoBrowser *) browser {
    int count = 0;
    for(NSNumber *num in _selections) {
        if([num boolValue]) {
            count++;
        }
    }
        
    if(count >1) {
        
        [browser.navigationController popViewControllerAnimated:YES];
        
        NSMutableArray *array_test = [NSMutableArray array];
        
        for(int i=0; i<photoArray.count; i++) {
            
            NSNumber *photo_val = [_selections objectAtIndex:i];
            if([photo_val boolValue]) {
                
                [array_test addObject:[photoArray objectAtIndex:i]];
            }
            
        }
        
        for(NSDictionary *dict_test in array_test) {
            
            PFObject *object = [PFObject objectWithClassName:PF_CONTEST_CLASS];
            object[PF_CONTEST_USER] = [PFUser currentUser];
            object[PF_CONTEST_PICTURE] = [dict_test objectForKey:@"picture"];
            object[PF_CONTEST_THUMB] = [dict_test objectForKey:@"source"];
            [object saveInBackground];
        }
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You should select at least 2 photos for test" delegate:nil cancelButtonTitle:@"Ok"otherButtonTitles: nil];
        [alertView show];
        
    }
}

@end
