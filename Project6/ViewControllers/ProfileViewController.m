//
//  ProfileViewController
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ProfileViewController.h"
#import "FBAlbumViewController.h"
#import "VPImageCropperViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "AppDelegate.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface ProfileViewController () <FBAlbumViewControllerDelegate, UITextViewDelegate,VPImageCropperDelegate>
{
    UIScrollView *imageScrollView;
    NSMutableArray *gallery_Array;
    UIScrollView *backScrollView;
    int selected_index;
    
    UIToolbar *toolbar;
    
    UITextView *tvIntroduction;
    UITextView *tvIntroduction2;
    UITextView *tvIntroduction3;
    
    UIImageView *cache_photo_view;
    
}
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[KIProgressViewManager manager] hideProgressView];
    
    backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64-44)];
    [self.view addSubview:backScrollView];
    
    cache_photo_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width*3.0/4.0)];
    
    self.title = @"Profile";
    
    toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(toolCancelClicked:)];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toolDoneClicked:)];
    [buttonDone setTintColor:COLOR_MENU];
    [buttonCancel setTintColor:COLOR_MENU];
    [toolbar setItems:[NSArray arrayWithObjects:buttonCancel,buttonflexible,buttonDone, nil]];

    gallery_Array = [NSMutableArray array];
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width/4.0*3.0)];
    [imageScrollView setContentSize:CGSizeMake(0, imageScrollView.height)];
    imageScrollView.pagingEnabled = YES;
    
    [backScrollView addSubview:imageScrollView];
    
    UIButton *plusBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 32, 32)];
    [plusBtn setImage:[[UIImage imageNamed:@"plusPhoto.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [plusBtn addTarget:self action:@selector(plusBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [plusBtn setTintColor:COLOR_TINT_SECOND];
    plusBtn.right = self.view.width-10;
    
    [backScrollView addSubview:plusBtn];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(0, imageScrollView.bottom+5, self.view.width, 22)];
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.font = [UIFont boldSystemFontOfSize:18];
    lblName.textColor = COLOR_IN_BLACK;
    lblName.text = self.user[PF_USER_FULLNAME];
    [backScrollView addSubview:lblName];
    
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(0, lblName.bottom, self.view.width, 22)];
    lblAddress.textAlignment = NSTextAlignmentCenter;
    lblAddress.font = [UIFont boldSystemFontOfSize:14];
    lblAddress.textColor = COLOR_IN_DARK_GRAY;
    lblAddress.text = [NSString stringWithFormat:@"%d | %@ | %@", (int)[NSDate age:self.user[PF_USER_BIRTHDAY]],[[self.user[PF_USER_GENDER] substringToIndex:1] uppercaseString],self.user[PF_USER_ZIPCODE]];
    [backScrollView addSubview:lblAddress];
    
    UIImageView *theView = [[UIImageView alloc] initWithFrame:CGRectMake(0, lblAddress.bottom, self.view.width, 8)];
    theView.image = [UIImage imageNamed:@"gradient_line.png"];
//    UIColor *topColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
//    UIColor *bottomColor = [UIColor colorWithRed:56.0/255.0 green:56.0/255.0 blue:56.0/255.0 alpha:1.0];
//    
//    // Create the gradient
//    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
//    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
//    theViewGradient.frame = theView.bounds;
//    
//    theView.layer.masksToBounds = YES;
//    //Add gradient to view
//    [theView.layer insertSublayer:theViewGradient atIndex:0];
    
    [backScrollView addSubview:theView];
    
    UIImageView *clipView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, theView.bottom+10, self.view.width, 120)];
    clipView1.backgroundColor = [UIColor clearColor];
    clipView1.userInteractionEnabled = YES;
    clipView1.tag = 1;
    
    [backScrollView addSubview:clipView1];
    
    UILabel *lblIntroductionMark = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, clipView1.width-20, 30)];
    lblIntroductionMark.textAlignment = NSTextAlignmentLeft;
    lblIntroductionMark.textColor = COLOR_IN_BLACK;
    lblIntroductionMark.font = [UIFont boldSystemFontOfSize:18];
    lblIntroductionMark.text = [GlobalPool sharedInstance].about_me;
    
//    PFQuery *query_about_me = [PFQuery queryWithClassName:PF_PROFILEOVERVIEW_CLASS];
//    [query_about_me whereKey:PF_PROFILEOVERVIEW_COLNAME equalTo:@"about_me"];
//    [query_about_me findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error) {
//            PFObject *object = [objects firstObject];
//            lblIntroductionMark.text = object[PF_PROFILEOVERVIEW_TITLE];
//        } else {
//            lblIntroductionMark.text = @"Overview";
//        }
//    }];
    
    [clipView1 addSubview:lblIntroductionMark];
    
    UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    btnEdit.top = lblIntroductionMark.top;
    btnEdit.right = self.view.width - 10;
    [btnEdit setImage:[[UIImage imageNamed:@"pencil_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    [btnEdit setContentMode:UIViewContentModeCenter];
    btnEdit.tag = 1;
    [btnEdit setTintColor:COLOR_MENU_NEW];
    [btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [clipView1 addSubview:btnEdit];
    
    tvIntroduction = [[UITextView alloc] initWithFrame:CGRectMake(10, lblIntroductionMark.bottom, clipView1.width-20, 20)];
    tvIntroduction.textAlignment = NSTextAlignmentLeft;
    tvIntroduction.textColor = COLOR_IN_DARK_GRAY;
    tvIntroduction.editable = YES;
    tvIntroduction.tag = 1;
    tvIntroduction.delegate = self;
    tvIntroduction.userInteractionEnabled = YES;
    tvIntroduction.backgroundColor = [UIColor clearColor];
    tvIntroduction.font = [UIFont systemFontOfSize:14];
    tvIntroduction.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_ME]];
    [tvIntroduction sizeToFit];
    tvIntroduction.inputAccessoryView = toolbar;
    [clipView1 addSubview:tvIntroduction];
    
    clipView1.height = tvIntroduction.height+lblIntroductionMark.bottom+10;

    UIImageView *clipView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, clipView1.bottom+5, self.view.width, 120)];
    clipView2.backgroundColor = [UIColor clearColor];
    clipView2.userInteractionEnabled = YES;
    clipView2.tag = 2;

    [backScrollView addSubview:clipView2];
    
    UILabel *lblIntroductionMark2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, clipView2.width-20, 30)];
    lblIntroductionMark2.textAlignment = NSTextAlignmentLeft;
    lblIntroductionMark2.textColor = COLOR_IN_BLACK;
    lblIntroductionMark2.font = [UIFont boldSystemFontOfSize:18];
    lblIntroductionMark2.text = [GlobalPool sharedInstance].about_life;
    
//    PFQuery *query_about_life = [PFQuery queryWithClassName:PF_PROFILEOVERVIEW_CLASS];
//    [query_about_life whereKey:PF_PROFILEOVERVIEW_COLNAME equalTo:@"about_life"];
//    [query_about_life findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error) {
//            PFObject *object = [objects firstObject];
//            lblIntroductionMark2.text = object[PF_PROFILEOVERVIEW_TITLE];
//        } else {
//            lblIntroductionMark2.text = @"Overview";
//        }
//    }];
    
    [clipView2 addSubview:lblIntroductionMark2];
    
    UIButton *btnEdit2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    btnEdit2.top = lblIntroductionMark2.top;
    btnEdit2.right = self.view.width - 10;
    [btnEdit2 setImage:[[UIImage imageNamed:@"pencil_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    [btnEdit2 setContentMode:UIViewContentModeCenter];
    btnEdit2.tag = 2;
    [btnEdit2 setTintColor:COLOR_MENU_NEW];
    [btnEdit2 addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [clipView2 addSubview:btnEdit2];

    
    tvIntroduction2 = [[UITextView alloc] initWithFrame:CGRectMake(10, lblIntroductionMark2.bottom, clipView2.width-20, 20)];
    tvIntroduction2.textAlignment = NSTextAlignmentLeft;
    tvIntroduction2.textColor = COLOR_IN_DARK_GRAY;
    tvIntroduction2.editable = YES;
    tvIntroduction2.delegate = self;
    tvIntroduction2.tag = 2;
    tvIntroduction2.inputAccessoryView = toolbar;
    tvIntroduction2.userInteractionEnabled = YES;
    tvIntroduction2.backgroundColor = [UIColor clearColor];
    tvIntroduction2.font = [UIFont systemFontOfSize:14];
    tvIntroduction2.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_LIFE]];
    [tvIntroduction2 sizeToFit];

    clipView2.height = tvIntroduction2.height+lblIntroductionMark2.bottom+10;

    [clipView2 addSubview:tvIntroduction2];
    [backScrollView setContentSize:CGSizeMake(self.view.width, clipView2.bottom+20)];
    
    UIImageView *clipView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, clipView2.bottom+5, self.view.width, 120)];
    clipView3.backgroundColor = [UIColor clearColor];
    clipView3.userInteractionEnabled = YES;
    clipView3.tag = 3;

    [backScrollView addSubview:clipView3];
    
    UILabel *lblIntroductionMark3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, clipView3.width-20, 30)];
    lblIntroductionMark3.textAlignment = NSTextAlignmentLeft;
    lblIntroductionMark3.textColor = COLOR_IN_BLACK;
    lblIntroductionMark3.font = [UIFont boldSystemFontOfSize:18];
    lblIntroductionMark3.text = [GlobalPool sharedInstance].about_you;
    
//    PFQuery *query_about_you = [PFQuery queryWithClassName:PF_PROFILEOVERVIEW_CLASS];
//    [query_about_you whereKey:PF_PROFILEOVERVIEW_COLNAME equalTo:@"about_you"];
//    [query_about_you findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error) {
//            PFObject *object = [objects firstObject];
//            lblIntroductionMark3.text = object[PF_PROFILEOVERVIEW_TITLE];
//        } else {
//            lblIntroductionMark3.text = @"Overview";
//        }
//    }];

    [clipView3 addSubview:lblIntroductionMark3];
    
    UIButton *btnEdit3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    btnEdit3.top = lblIntroductionMark3.top;
    btnEdit3.right = self.view.width - 10;
    [btnEdit3 setImage:[[UIImage imageNamed:@"pencil_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    [btnEdit3 setContentMode:UIViewContentModeCenter];
    btnEdit3.tag = 3;
    [btnEdit3 setTintColor:COLOR_MENU_NEW];
    [btnEdit3 addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [clipView3 addSubview:btnEdit3];
    
    tvIntroduction3 = [[UITextView alloc] initWithFrame:CGRectMake(10, lblIntroductionMark3.bottom, clipView3.width-20, 20)];
    tvIntroduction3.textAlignment = NSTextAlignmentLeft;
    tvIntroduction3.textColor = COLOR_IN_DARK_GRAY;
    tvIntroduction3.editable = YES;
    tvIntroduction3.tag = 3;
    tvIntroduction3.delegate = self;
    tvIntroduction3.inputAccessoryView = toolbar;
    tvIntroduction3.userInteractionEnabled = YES;
    tvIntroduction3.backgroundColor = [UIColor clearColor];
    tvIntroduction3.font = [UIFont systemFontOfSize:14];
    tvIntroduction3.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_YOU]];
    [tvIntroduction3 sizeToFit];
    
    clipView3.height = tvIntroduction3.height+lblIntroductionMark3.bottom+10;
    
    [clipView3 addSubview:tvIntroduction3];
    [backScrollView setContentSize:CGSizeMake(self.view.width, clipView3.bottom+20)];

    
    [self loadPhotoLibrary];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
}


- (void)toolCancelClicked:(id)sender {
    
    tvIntroduction.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_ME]];
    tvIntroduction2.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_LIFE]];
    tvIntroduction3.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_YOU]];

    [self.view endEditing:YES];
    
    [backScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void)toolDoneClicked:(id)sender {
    [self.view endEditing:YES];
    
    self.user[PF_USER_ABOUT_ME] = tvIntroduction.text;
    self.user[PF_USER_ABOUT_LIFE] = tvIntroduction2.text;
    self.user[PF_USER_ABOUT_YOU] = tvIntroduction3.text;
    
    [self.user saveInBackground];
    
    [backScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)plusBtnClicked {
    FBAlbumViewController *albumCtrl = [[FBAlbumViewController alloc] init];
    albumCtrl.delegate = self;
    [self.navigationController pushViewController:albumCtrl animated:YES];
}
- (void)loadPhotoLibrary {
    [[KIProgressViewManager manager] showProgressOnView:self.view];

    PFQuery *query = [PFQuery queryWithClassName:PF_PHOTO_GALLERY_CLASS_NAME];
    [query whereKey:PF_PHOTO_USER equalTo:self.user];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            int skip = 0;
            for(PFObject *object in objects) {
                UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width/4.0*3.0)];
                backImageView.clipsToBounds = YES;
                
                if(object[PF_PHOTO_EDITED_PICTURE]) {
                    PFFile *profileImage = object[PF_PHOTO_EDITED_PICTURE];
                    [profileImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        backImageView.image = [UIImage imageWithData:imageData];
                    }];

                } else {
                    [backImageView setImageWithURL:[NSURL URLWithString:object[PF_PHOTO_PICTURE]]];
                }

                backImageView.contentMode = UIViewContentModeScaleAspectFill;
                backImageView.left = skip * imageScrollView.width;
                backImageView.userInteractionEnabled = YES;
                backImageView.tag = skip+100;
                [imageScrollView addSubview:backImageView];
                
                UILabel *lbl_cap = [[UILabel alloc] initWithFrame:CGRectMake(0, backImageView.height-40, backImageView.width, 40)];
                lbl_cap.backgroundColor = [COLOR_IN_BLACK colorWithAlphaComponent:0.9];
                lbl_cap.textColor = [UIColor whiteColor];
                lbl_cap.font = [UIFont boldSystemFontOfSize:14];
                lbl_cap.textAlignment = NSTextAlignmentCenter;
                lbl_cap.tag = 300;
                lbl_cap.text = [NSString stringWithFormat:@"%d / %d",skip+1,(int)objects.count];
                
                [backImageView addSubview:lbl_cap];
                
                UIButton *btnView = [[UIButton alloc] initWithFrame:CGRectMake(backImageView.width-40, backImageView.height-38, 32, 32)];
                [btnView setImage:[[UIImage imageNamed:@"detailViewIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [btnView setTintColor:COLOR_TINT_SECOND];
                [btnView addTarget:self action:@selector(btnViewClicked:) forControlEvents:UIControlEventTouchUpInside];
                [backImageView addSubview:btnView];
                //delete_icon@2x
                UIButton *btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(15, backImageView.height-32, 24, 24)];
                [btnDelete setImage:[[UIImage imageNamed:@"delete_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [btnDelete setTintColor:COLOR_TINT_SECOND];
                [btnDelete addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
                [backImageView addSubview:btnDelete];
                
                UITapGestureRecognizer *tap_ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClicked:)];
                tap_ges.numberOfTapsRequired = 1;
                [backImageView addGestureRecognizer:tap_ges];
                
                skip++;
                
                [gallery_Array addObject:object];
            }
            [imageScrollView setContentSize:CGSizeMake(imageScrollView.width*objects.count, self.view.width/4.0*3.0)];
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
}

#pragma mark -
#pragma mark FBAlbumViewControllerDelegate
- (void)albumDoneBtnClicked:(NSArray*) array {
    NSLog(@"%@",array);
    int skip = imageScrollView.contentSize.width/imageScrollView.width;
    
    int currnetGalleryCount = (int)gallery_Array.count;
    
    for(NSDictionary *dict in array) {
        
        PFObject *obj = [PFObject objectWithClassName:PF_PHOTO_GALLERY_CLASS_NAME];
        [obj setObject:self.user forKey:PF_PHOTO_USER];
        [obj setValue:[dict valueForKey:@"picture"] forKey:PF_PHOTO_PICTURE];
        [obj setValue:[dict valueForKey:@"thumb"] forKey:PF_PHOTO_THUMB];
        [obj saveInBackground];
        
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width/4.0*3.0)];
        backImageView.clipsToBounds = YES;
        [backImageView setImageWithURL:[dict valueForKey:@"picture"]];
        backImageView.contentMode = UIViewContentModeScaleAspectFill;
        backImageView.userInteractionEnabled = YES;
        backImageView.left = skip * imageScrollView.width;
        backImageView.tag = skip+100;
        [imageScrollView addSubview:backImageView];
        
        UILabel *lbl_cap = [[UILabel alloc] initWithFrame:CGRectMake(0, backImageView.height-40, backImageView.width, 40)];
        lbl_cap.backgroundColor = [COLOR_MENU colorWithAlphaComponent:0.8];
        lbl_cap.textColor = [UIColor whiteColor];
        lbl_cap.font = [UIFont boldSystemFontOfSize:14];
        lbl_cap.textAlignment = NSTextAlignmentCenter;
        lbl_cap.tag = 300;
        lbl_cap.text = [NSString stringWithFormat:@"%d / %d",skip+1,currnetGalleryCount+(int)array.count];
        
        [backImageView addSubview:lbl_cap];

        UIButton *btnView = [[UIButton alloc] initWithFrame:CGRectMake(backImageView.width-40, backImageView.height-38, 32, 32)];
        [btnView setImage:[[UIImage imageNamed:@"detailViewIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btnView setTintColor:COLOR_TINT_SECOND];
        [btnView addTarget:self action:@selector(btnViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backImageView addSubview:btnView];
        //delete_icon@2x
        UIButton *btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(15, backImageView.height-32, 24, 24)];
        [btnDelete setImage:[[UIImage imageNamed:@"delete_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btnDelete setTintColor:COLOR_TINT_SECOND];
        [btnDelete addTarget:self action:@selector(btnDeleteClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backImageView addSubview:btnDelete];
        
        UITapGestureRecognizer *tap_ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClicked:)];
        tap_ges.numberOfTapsRequired = 1;
        [backImageView addGestureRecognizer:tap_ges];
        
        skip++;
        
        [gallery_Array addObject:obj];
        
    }
    [imageScrollView setContentSize:CGSizeMake(imageScrollView.width*skip, 200)];
    
    for(int i=0; i<gallery_Array.count; i++) {
        UIImageView *image_temp = (UIImageView*)[imageScrollView viewWithTag:i+100];
        UILabel *lbl_cap = (UILabel*)[image_temp viewWithTag:300];
        lbl_cap.text = [NSString stringWithFormat:@"%d / %d",i+1,(int)gallery_Array.count];
    }


}
- (void)btnDeleteClicked:(UIButton*) sender {
    selected_index = [sender superview].right/imageScrollView.width-1 ;
    
    UIImageView *image_view = (UIImageView*)[imageScrollView viewWithTag:selected_index+100];
    [image_view removeFromSuperview];
    
    for(int i=selected_index+1; i<gallery_Array.count; i++) {
        UIImageView *image_temp = (UIImageView*)[imageScrollView viewWithTag:i+100];
        image_temp.left = image_temp.left-imageScrollView.width;
        image_temp.tag = image_temp.tag-1;
    }
    
    [imageScrollView setContentSize:CGSizeMake(imageScrollView.width*(gallery_Array.count-1), imageScrollView.height)];
    
    PFObject* obj = [gallery_Array objectAtIndex:selected_index];
    [gallery_Array removeObjectAtIndex:selected_index];
    [obj deleteInBackground];
    
    for(int i=0; i<gallery_Array.count; i++) {
        UIImageView *image_temp = (UIImageView*)[imageScrollView viewWithTag:i+100];
        UILabel *lbl_cap = (UILabel*)[image_temp viewWithTag:300];
        lbl_cap.text = [NSString stringWithFormat:@"%d / %d",i+1,(int)gallery_Array.count];
    }

}
#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    UIImageView *image_view = (UIImageView*)[imageScrollView viewWithTag:selected_index+100];
    image_view.image = editedImage;
    
    PFObject *obj_selected = [gallery_Array objectAtIndex:selected_index];
    
    NSData* data = UIImageJPEGRepresentation(editedImage, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            obj_selected[PF_PHOTO_EDITED_PICTURE] = imageFile;
            [obj_selected saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Successfully Updated" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to Update" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alertView show];
                }
                [[KIProgressViewManager manager] hideProgressView];
            }]; }
        [[KIProgressViewManager manager] hideProgressView];
    }];

    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}
- (void)btnViewClicked:(UIButton*) sender {

    selected_index = [sender superview].right/imageScrollView.width-1 ;
    PFObject *obj_selected = [gallery_Array objectAtIndex:selected_index];
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:obj_selected[PF_PHOTO_PICTURE]]];
    
    __weak typeof(self) weakSelf = self;
    
//    UIImageView *image_view = (UIImageView*)[imageScrollView viewWithTag:selected_index+100];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSURL *imageURL = [NSURL URLWithString:obj_selected[PF_PHOTO_PICTURE]];
                       NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                       
                       //This is your completion handler
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           //If self.image is atomic (not declared with nonatomic)
                           // you could have set it directly above
                           UIImage *image = [UIImage imageWithData:imageData];

                           VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:image cropFrame:CGRectMake(0, weakSelf.view.height/2-weakSelf.view.width*3.0/4.0/2.0, weakSelf.view.width, weakSelf.view.width*3.0/4.0) limitScaleRatio:3.0];
                   
                           imgCropperVC.delegate = weakSelf;
                   
                           [weakSelf presentViewController:imgCropperVC animated:YES completion:^{
                               // TO DO
                           }];

                           
                       });
                   });
    
//    [cache_photo_view setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        
//        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:[weakSelf imageByScalingToMaxSize:image] cropFrame:CGRectMake(0, weakSelf.view.height/2-weakSelf.view.width*3.0/4.0/2.0, weakSelf.view.width, weakSelf.view.width*3.0/4.0) limitScaleRatio:3.0];
//
//        imgCropperVC.delegate = weakSelf;
//        
//        [weakSelf presentViewController:imgCropperVC animated:YES completion:^{
//            // TO DO
//        }];
//
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        
//        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:image_view.image cropFrame:CGRectMake(0, weakSelf.view.height/2-weakSelf.view.width*3.0/4.0/2.0, weakSelf.view.width, weakSelf.view.width*3.0/4.0) limitScaleRatio:3.0];
//        imgCropperVC.delegate = weakSelf;
//        [weakSelf presentViewController:imgCropperVC animated:YES completion:^{
//            // TO DO
//        }];
//        
//    }];
    
}
#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)tapGesClicked:(UITapGestureRecognizer *) tapGes {
    
    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    
    selected_index = tapGes.view.right/imageScrollView.width-1 ;
    
    PFObject *obj_selected = [gallery_Array objectAtIndex:selected_index];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    photo = [MWPhoto photoWithURL:[NSURL URLWithString:obj_selected[PF_PHOTO_PICTURE]]];
    [photos addObject:photo];
    self.photos = photos;
    
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
    browser.enableDeleteBtn = YES;
    [browser setCurrentPhotoIndex:0];

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];

    
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
    });

}
#pragma mark - MWPhotoBrowserDelegate

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}
- (void)deleteBtnClicked {

    UIImageView *image_view = (UIImageView*)[imageScrollView viewWithTag:selected_index+100];
    [image_view removeFromSuperview];
    
    for(int i=selected_index+1; i<gallery_Array.count; i++) {
        UIImageView *image_temp = (UIImageView*)[imageScrollView viewWithTag:i+100];
        image_temp.left = image_temp.left-imageScrollView.width;
        image_temp.tag = image_temp.tag-1;
    }
    [imageScrollView setContentSize:CGSizeMake(imageScrollView.width*(gallery_Array.count-1), imageScrollView.height)];

    PFObject* obj = [gallery_Array objectAtIndex:selected_index];
    [gallery_Array removeObjectAtIndex:selected_index];
    [obj deleteInBackground];
    
    for(int i=0; i<gallery_Array.count; i++) {
        UIImageView *image_temp = (UIImageView*)[imageScrollView viewWithTag:i+100];
        UILabel *lbl_cap = (UILabel*)[image_temp viewWithTag:300];
        lbl_cap.text = [NSString stringWithFormat:@"%d / %d",i+1,(int)gallery_Array.count];
    }
}

#pragma mark -
#pragma mark UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{

    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.width = self.view.width-20;
    UIImageView *coverView = (UIImageView*)textView.superview;
    NSLog(@"%f",coverView.bottom);
    [backScrollView setContentOffset:CGPointMake(0, coverView.bottom-240) animated:YES];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
//    [backScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [textView sizeToFit];
    UIImageView *backImageView = (UIImageView*)[backScrollView viewWithTag:textView.tag];
    backImageView.height = textView.height+30+10;
    float topY = backImageView.bottom;
    for(int i=(int)textView.tag+1;i<4; i++ ) {
        UIImageView *tempImageView = (UIImageView*)[backScrollView viewWithTag:i];
        tempImageView.top = topY +5;
        topY = tempImageView.bottom;
    }
    [backScrollView setContentSize:CGSizeMake(self.view.width, topY+20)];

    return YES;
}

- (void)btnEditClicked:(UIButton*) sender {
    switch (sender.tag) {
        case 1:
        {
            [tvIntroduction becomeFirstResponder];
            break;
        }
        case 2:
        {
            [tvIntroduction2 becomeFirstResponder];
            break;
        }
        case 3:
        {
            [tvIntroduction3 becomeFirstResponder];
            break;
        }
        default:
            break;
    }
   // [backScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
