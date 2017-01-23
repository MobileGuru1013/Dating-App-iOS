//
//  SettingsViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "IQDropDownTextField.h"
#import "ASValueTrackingSlider.h"
#import "ASValuePopUpView.h"
#import "UIImage+ResizeMagick.h"
#import "GlobalPool.h"
#import "EthicBeliefPickerViewController.h"
#import "LocationPickerViewController.h"
#import "MJCollectionViewCell.h"
#import "MJRootViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"

#import "TWPhotoPickerController.h"
#import "TWPhotoCollectionViewCell.h"
#import "TWImageScrollView.h"
#import "TWPhotoLoader.h"
#import "AppDelegate.h"

#define kCellHeight 64

/*
- I am
 Photo
 Name
 Birthday
 Address
 Male/Female
 Ethic/
 Belief/
 
- Looking For
 Male/Female
 Distance
 Min Age/
 Max Age/
 Ethic/
 Belief/
 
 */

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,EthicBeliefPickerViewControllerDelegate,LocationPickerViewControllerDelegate,EMJRootViewControllerDelegate>
{
    APAvatarImageView *AvatarView;
    BOOL isImageLoaded;
    UIImage *imagePhoto;
    
    UITextField *displayTextField;
    IQDropDownTextField *birthDaySelect;
    UISegmentedControl *segIam;
    UISegmentedControl *segLook;
    IQDropDownTextField *milesTextField;
    UITextField *addressTextField;
    UILabel *ethnTextField;
    UILabel *beliefTextField;
    
    IQDropDownTextField *myEthnicityField;
    IQDropDownTextField *myBeliefField;
    
    ASValueTrackingSlider *sliderMinAge;
    ASValueTrackingSlider *sliderMaxAge;
    
    NSArray *ageRangeArray;
    UIToolbar *toolbar;
    
    NSString *displayName;
    NSDate *birthday;
    NSString *gender;
    NSString *lookGender;
    NSString *mileStr;
    int minAge;
    int maxAge;
    NSString *address;
    NSMutableArray *ethnicity;
    NSMutableArray *belief;
    PFGeoPoint *geolocation;
    NSString *myEthnicity;
    NSString *myBelief;
    
    UIButton *btnLocationPicker;
}
@property (nonatomic, strong) UITableView* contentTableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    
    displayName = [PFUser currentUser][PF_USER_FULLNAME];
    birthday = [PFUser currentUser][PF_USER_BIRTHDAY];
    gender = [PFUser currentUser][PF_USER_GENDER];
    lookGender = [PFUser currentUser][PF_USER_L_GENDER];
    mileStr = [PFUser currentUser][PF_USER_L_DISTANCE];
    minAge = [[PFUser currentUser][PF_USER_L_MINAGE] intValue];
    maxAge = [[PFUser currentUser][PF_USER_L_MAXAGE] intValue];
    address = [PFUser currentUser][PF_USER_ZIPCODE];
    geolocation = [PFUser currentUser][PF_USER_GEOLOCATION];
    ethnicity = [NSMutableArray arrayWithArray:[PFUser currentUser][PF_USER_ETHNICITY]];
    belief = [NSMutableArray arrayWithArray:[PFUser currentUser][PF_USER_BELIEF]];
    
    [GlobalPool sharedInstance].location = [[CLLocation alloc] initWithLatitude:geolocation.latitude longitude:geolocation.longitude];
    
    self.contentTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.width,self.view.height-64-50) style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.bounces = YES;
        tableView.clipsToBounds = YES;
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        tableView.tableFooterView = [UIView new];
        tableView;
    });
    
    [self.view addSubview:self.contentTableView];
    
    UIButton *btnSignout = [[UIButton alloc] initWithFrame:CGRectMake(0, self.contentTableView.bottom, self.view.width, 50)];
    [btnSignout setBackgroundColor:COLOR_MENU];
    [btnSignout setTitle:@"Sign Out" forState:UIControlStateNormal];
    [btnSignout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSignout setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnSignout addTarget:self action:@selector(btnSignoutClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnSignout];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(btnSaveClicked)];

    ageRangeArray = @[@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55"];
    
    toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    [buttonDone setTintColor:[UIColor whiteColor]];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible,buttonDone, nil]];
    
    AvatarView = [[APAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    AvatarView.center = CGPointMake(self.view.width/2, 80);
    AvatarView.contentMode = UIViewContentModeScaleAspectFill;
    AvatarView.userInteractionEnabled = YES;
    if([PFUser currentUser][PF_USER_THUMBNAIL]) {
        PFFile *profileImage = [PFUser currentUser][PF_USER_THUMBNAIL];
        [profileImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            UIImage *thumbnailImage = [UIImage imageWithData:imageData];
            AvatarView.image = thumbnailImage;
        }];
        
    } else {
        [AvatarView setImageWithURL:[NSURL URLWithString:[PFUser currentUser][PF_USER_PICTURE]] placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    }

    UITapGestureRecognizer *tapGes_Avatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesAvatarClicked)];
    [AvatarView addGestureRecognizer:tapGes_Avatar];
    
    ethnTextField = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    ethnTextField.textColor = COLOR_IN_DARK_GRAY;
    ethnTextField.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    ethnTextField.backgroundColor = [UIColor whiteColor];
    ethnTextField.textAlignment = NSTextAlignmentCenter;
    ethnTextField.backgroundColor = [UIColor clearColor];
    
    if(ethnicity.count == 0) {
        ethnTextField.text = @"Ethnicity - ALL";
    } else {
        ethnTextField.text = [self convertArrayToText:ethnicity];
    }
    
    beliefTextField = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    beliefTextField.textColor = COLOR_IN_DARK_GRAY;
    beliefTextField.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    beliefTextField.backgroundColor = [UIColor whiteColor];
    beliefTextField.textAlignment = NSTextAlignmentCenter;
    beliefTextField.backgroundColor = [UIColor clearColor];
    
    if(belief.count == 0) {
        beliefTextField.text = @"Belief - ALL";
    } else {
        beliefTextField.text = [self convertArrayToText:belief];
    }
    
    milesTextField = [[IQDropDownTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    milesTextField.textColor = COLOR_IN_DARK_GRAY;
    milesTextField.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    milesTextField.placeholder = @"Distance Range";
    milesTextField.backgroundColor = [UIColor whiteColor];
    milesTextField.textAlignment = NSTextAlignmentCenter;
    milesTextField.inputAccessoryView = toolbar;
    [milesTextField setItemList:@[@"10 miles",@"25 miles",@"50 miles"]];
    milesTextField.backgroundColor = [UIColor clearColor];
    [milesTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    segLook = [[UISegmentedControl alloc] initWithItems:@[@"Male",@"Female"]];
    [segLook setFrame:CGRectMake(self.view.width-180, 15, 160, kCellHeight - 32)];
    [segLook setTintColor:COLOR_IN_DARK_GRAY];
    if([lookGender isEqualToString:@"Male"])
        [segLook setSelectedSegmentIndex:0];
    else
        [segLook setSelectedSegmentIndex:1];

    segLook.centerX = self.view.width/2;
    [segLook addTarget:self action:@selector(segLookChanged:) forControlEvents:UIControlEventValueChanged];
    
    segIam = [[UISegmentedControl alloc] initWithItems:@[@"Male",@"Female"]];
    [segIam setFrame:CGRectMake(self.view.width-180, 15, 160, kCellHeight - 32)];
    [segIam setTintColor:COLOR_IN_DARK_GRAY];
    segIam.centerX = self.view.width/2;
    if([gender isEqualToString:@"Male"])
        [segIam setSelectedSegmentIndex:0];
    else
        [segIam setSelectedSegmentIndex:1];

    [segIam addTarget:self action:@selector(segIamChanged:) forControlEvents:UIControlEventValueChanged];

    addressTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    addressTextField.textColor = COLOR_IN_DARK_GRAY;
    addressTextField.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    addressTextField.placeholder = @"Address";
    addressTextField.backgroundColor = [UIColor whiteColor];
    addressTextField.textAlignment = NSTextAlignmentCenter;
    addressTextField.delegate = self;
    addressTextField.backgroundColor = [UIColor clearColor];
    addressTextField.enabled = NO;
    [addressTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    birthDaySelect = [[IQDropDownTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    birthDaySelect.textColor = COLOR_IN_DARK_GRAY;
    birthDaySelect.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    birthDaySelect.placeholder = @"Birthday";
    birthDaySelect.backgroundColor = [UIColor whiteColor];
    birthDaySelect.textAlignment = NSTextAlignmentCenter;
    [birthDaySelect setDropDownMode:IQDropDownModeDatePicker];
    birthDaySelect.inputAccessoryView = toolbar;
    birthDaySelect.backgroundColor = [UIColor clearColor];
    [birthDaySelect setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    displayTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    displayTextField.textColor = COLOR_IN_DARK_GRAY;
    displayTextField.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    displayTextField.placeholder = @"Display Name";
    displayTextField.backgroundColor = [UIColor whiteColor];
    displayTextField.textAlignment = NSTextAlignmentCenter;
    displayTextField.delegate = self;
    displayTextField.backgroundColor = [UIColor clearColor];
    [displayTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    sliderMinAge = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(100, 50, self.view.width-120, kCellHeight-40)];
    
    sliderMinAge.maximumValue = 100;
    sliderMinAge.minimumValue = 18;
    sliderMinAge.popUpViewCornerRadius = 0.0;
    [sliderMinAge setMaxFractionDigitsDisplayed:0];
    sliderMinAge.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    sliderMinAge.font = [UIFont systemFontOfSize:14];
    sliderMinAge.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    [sliderMinAge addTarget:self action:@selector(sliderMinAgeChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIColor *coldBlue = [UIColor colorWithHue:0.6 saturation:0.7 brightness:1.0 alpha:1.0];
    UIColor *blue = [UIColor colorWithHue:0.55 saturation:0.75 brightness:1.0 alpha:1.0];
    UIColor *green = [UIColor colorWithHue:0.3 saturation:0.65 brightness:0.8 alpha:1.0];
    UIColor *yellow = [UIColor colorWithHue:0.15 saturation:0.9 brightness:0.9 alpha:1.0];
    UIColor *red = [UIColor colorWithHue:0.0 saturation:0.8 brightness:1.0 alpha:1.0];
    
    [sliderMinAge setPopUpViewAnimatedColors:@[coldBlue, blue, green, yellow, red]
                               withPositions:@[@18, @30, @40, @60, @100]];
    [sliderMinAge showPopUpView];
    
    sliderMaxAge = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(100, 50, self.view.width-120, kCellHeight-40)];
    
    sliderMaxAge.maximumValue = 100;
    sliderMaxAge.minimumValue = 18;
    sliderMaxAge.popUpViewCornerRadius = 0.0;
    [sliderMaxAge setMaxFractionDigitsDisplayed:0];
    sliderMaxAge.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    sliderMaxAge.font = [UIFont systemFontOfSize:14];
    sliderMaxAge.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    [sliderMaxAge addTarget:self action:@selector(sliderMaxAgeChanged:) forControlEvents:UIControlEventValueChanged];
    
    [sliderMaxAge setPopUpViewAnimatedColors:@[coldBlue, blue, green, yellow, red]
                               withPositions:@[@18, @30, @40, @60, @100]];
    [sliderMaxAge showPopUpView];
    
    btnLocationPicker = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [btnLocationPicker setImage:[[UIImage imageNamed:@"locationPicker.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btnLocationPicker setTintColor:COLOR_IN_DARK_GRAY];
    [btnLocationPicker addTarget:self action:@selector(btnLocationClicked) forControlEvents:UIControlEventTouchUpInside];

    myBeliefField = [[IQDropDownTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    myBeliefField.textColor = COLOR_IN_DARK_GRAY;
    myBeliefField.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    myBeliefField.placeholder = @"Not Specified";
    myBeliefField.backgroundColor = [UIColor whiteColor];
    myBeliefField.textAlignment = NSTextAlignmentCenter;
    myBeliefField.inputAccessoryView = toolbar;
    myBeliefField.backgroundColor = [UIColor clearColor];
    [myBeliefField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    PFQuery *query = [PFQuery queryWithClassName:PF_BELIEF_CLASS];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        if(!error) {
            for(PFObject *obj in objects) {
                [array addObject:obj[PF_ETHIC_CONTENT]];
            }
            [myBeliefField setItemList:array];
        }
        
    }];
    
    myEthnicityField = [[IQDropDownTextField alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kCellHeight)];
    myEthnicityField.textColor = COLOR_IN_DARK_GRAY;
    myEthnicityField.font = [UIFont fontWithName:@"Gotham-Light" size:18];
    myEthnicityField.placeholder = @"Not Specified";
    myEthnicityField.backgroundColor = [UIColor whiteColor];
    myEthnicityField.textAlignment = NSTextAlignmentCenter;
    myEthnicityField.inputAccessoryView = toolbar;
    myEthnicityField.backgroundColor = [UIColor clearColor];
    [myEthnicityField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];

    PFQuery *eth_query = [PFQuery queryWithClassName:PF_ETHIC_CLASS];
    [eth_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        if(!error) {
            for(PFObject *obj in objects) {
                [array addObject:obj[PF_ETHIC_CONTENT]];
            }
            [myEthnicityField setItemList:array];
        }
        
    }];
    
    myBeliefField.text = [PFUser currentUser][PF_USER_MY_BELIEF];
    myEthnicityField.text = [PFUser currentUser][PF_USER_MY_ETHNICITY];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
}

- (void)sliderMinAgeChanged: (ASValueTrackingSlider *) sender {
    minAge = sender.value;
}
- (void)sliderMaxAgeChanged: (ASValueTrackingSlider *) sender {
    maxAge = sender.value;
}

- (void)segIamChanged:(UISegmentedControl *) segCtrl {
    if(segCtrl.selectedSegmentIndex == 0)
        gender = @"Male";
    else
        gender = @"Female";
}
- (void)segLookChanged:(UISegmentedControl *) segCtrl {
    if(segCtrl.selectedSegmentIndex == 0)
        lookGender = @"Male";
    else
        lookGender = @"Female";
}
- (void)doneClicked:(id) sender {
    
    displayName = displayTextField.text;
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateStyle:NSDateFormatterMediumStyle];

    birthday = [formatter1 dateFromString:birthDaySelect.text];
    
    if(segIam.selectedSegmentIndex == 0)
        gender = @"Male";
    else
        gender = @"Female";
    
    if(segLook.selectedSegmentIndex == 0)
        lookGender = @"Male";
    else
        lookGender = @"Female";
    
    mileStr = milesTextField.text;
    minAge = sliderMinAge.value;
    maxAge = sliderMaxAge.value;
    address = addressTextField.text;
    ethnicity = [self convertTextToArray:ethnTextField.text];
    belief = [self convertTextToArray:beliefTextField.text];
    
    myEthnicity = myEthnicityField.text;
    myBelief = myBeliefField.text;
    
    [self.view endEditing:YES];

}
- (NSMutableArray *)convertTextToArray:(NSString *)text {
    if([text isEqualToString:@"Ethnicity - ALL"] || [text isEqualToString:@"Belief - ALL"]) {
        return [NSMutableArray array];
    } else {
        return [NSMutableArray arrayWithArray:[text componentsSeparatedByString:@","]];
    }
}
- (NSString *)convertArrayToText:(NSMutableArray *)array {
    NSString *str = @"";
    for(NSString *string in array) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@,",string]];
    }
    str = [str substringToIndex:[str length]-1];
    return str;
}
- (void)btnSignoutClicked {
    
    [PFUser logOut];
    
    UIViewController * control = self.sideMenuViewController;
    [control.navigationController popViewControllerRetroToRoot];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)btnSaveClicked {

    [self.view endEditing:YES];
    
    [PFUser currentUser][PF_USER_FULLNAME] = displayName ;
    [PFUser currentUser][PF_USER_BIRTHDAY] = birthday ;
    [PFUser currentUser][PF_USER_GENDER] = gender;
    [PFUser currentUser][PF_USER_L_GENDER] = lookGender;
    [PFUser currentUser][PF_USER_L_DISTANCE] = mileStr;
    [PFUser currentUser][PF_USER_L_MINAGE] = [NSNumber numberWithInt:minAge];
    [PFUser currentUser][PF_USER_L_MAXAGE] = [NSNumber numberWithInt:maxAge];
    [PFUser currentUser][PF_USER_ZIPCODE] = addressTextField.text;
    [PFUser currentUser][PF_USER_ETHNICITY] = [self convertTextToArray:ethnTextField.text];
    [PFUser currentUser][PF_USER_BELIEF] = [self convertTextToArray:beliefTextField.text];
    [PFUser currentUser][PF_USER_GEOLOCATION] = geolocation;
    [PFUser currentUser][PF_USER_MY_BELIEF] = myBeliefField.text;
    [PFUser currentUser][PF_USER_MY_ETHNICITY] = myEthnicityField.text;
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];

    if(!isImageLoaded && [PFUser currentUser][PF_USER_THUMBNAIL]) {
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Successfully Updated" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to Update" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            [[KIProgressViewManager manager] hideProgressView];
        }];
    } else {
        NSData* data = UIImageJPEGRepresentation(AvatarView.image, 0.5f);
        PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:data];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [PFUser currentUser][PF_USER_THUMBNAIL] = imageFile;
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];

}
#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"My information";
    } else {
        return @"I am looking for";
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 70)];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 10,300, 60);
    label.font = [UIFont boldSystemFontOfSize:20];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = COLOR_IN_BLACK;
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    headerView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 60;
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            height = 160;
        }
    } else {
        if(indexPath.row == 1 | indexPath.row == 2)
            height = 80;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if(sectionIndex == 0) {
        return 7;
    } else {
        return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = COLOR_IN_DARK_GRAY;
        cell.preservesSuperviewLayoutMargins = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    cell.textLabel.text = @"";
    [cell setIndentationLevel:0];
    [cell setIndentationWidth:0];
    if(indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"";
                AvatarView.tag = indexPath.row+100;
                cell.accessoryView = nil;
                [cell.contentView addSubview:AvatarView];
                break;
            }
            case 1: {
                cell.textLabel.text = @"";
                displayTextField.tag = indexPath.row+100;
                displayTextField.text = displayName;
                                cell.accessoryView = nil;
                [cell.contentView addSubview:displayTextField];
                break;
            }
            case 2: {
                cell.textLabel.text = @"";
                NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
                [formatter1 setDateStyle:NSDateFormatterMediumStyle];
                birthDaySelect.text = [formatter1 stringFromDate:birthday];
                birthDaySelect.tag = indexPath.row+100;
                                cell.accessoryView = nil;
                [cell.contentView addSubview:birthDaySelect];
                break;
            }
            case 3: {
                cell.textLabel.text = @"";
                addressTextField.tag = indexPath.row+100;
                addressTextField.text = address;
                [cell.contentView addSubview:addressTextField];
                
                cell.accessoryView = btnLocationPicker;
                break;
            }
            case 4: {
                [cell setIndentationLevel:3];
                [cell setIndentationWidth:20];
                                cell.accessoryView = nil;
                if([gender isEqualToString:@"Male"])
                    [segIam setSelectedSegmentIndex:0];
                else
                    [segIam setSelectedSegmentIndex:1];
                [cell.contentView addSubview:segIam];
                break;
            }
            case 5: {
                cell.textLabel.text = @"";
                                cell.accessoryView = nil;
                [cell.contentView addSubview:myEthnicityField];
                break;
            }
            case 6: {
                cell.textLabel.text = @"";
                [cell.contentView addSubview:myBeliefField];
                break;
            }
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
            {
                [cell setIndentationLevel:3];
                [cell setIndentationWidth:20];
                                cell.accessoryView = nil;
                if([lookGender isEqualToString:@"Male"])
                    [segLook setSelectedSegmentIndex:0];
                else
                    [segLook setSelectedSegmentIndex:1];
                cell.textLabel.text = @"";
                [cell.contentView addSubview:segLook];

                break;
            }
            case 1: {
                                cell.accessoryView = nil;
                cell.textLabel.text = @"Min Age";
                sliderMinAge.value = minAge;
                [cell.contentView addSubview:sliderMinAge];

                break;
            }
            case 2: {
                                cell.accessoryView = nil;
                cell.textLabel.text = @"Max Age";
                sliderMaxAge.value = maxAge;
                [cell.contentView addSubview:sliderMaxAge];

                break;
            }
            case 3: {
                                cell.accessoryView = nil;
                cell.textLabel.text = @"";
                milesTextField.text = mileStr;
                milesTextField.tag = indexPath.row+100;
                [cell.contentView addSubview:milesTextField];

                break;
            }
            case 4: {
                                cell.accessoryView = nil;
                if(ethnicity.count == 0) {
                    ethnTextField.text = @"Ethnicity - ALL";
                } else {
                    ethnTextField.text = [self convertArrayToText:ethnicity];
                }
                ethnTextField.tag = indexPath.row+100;
                ethnTextField.userInteractionEnabled = NO;
                cell.textLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.contentView addSubview:ethnTextField];
                break;

            }
            case 5: {
                                cell.accessoryView = nil;
                if(belief.count == 0) {
                    beliefTextField.text = @"Belief - ALL";
                } else {
                    beliefTextField.text = [self convertArrayToText:belief];
                }
                cell.textLabel.text = @"";
                beliefTextField.tag = indexPath.row+100;
                beliefTextField.userInteractionEnabled = NO;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.contentView addSubview:beliefTextField];
                break;
            }
                
            case 6: {
                cell.accessoryView = nil;
                
                cell.textLabel.text = @"Deactivate Account";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor redColor];
                cell.textLabel.font = [UIFont systemFontOfSize:18];
                break;
            }
                
            default:
                break;
        }
    }


    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 4 && indexPath.section == 1) {
        
        EthicBeliefPickerViewController *ethicCtrl = [[EthicBeliefPickerViewController alloc] init];
        ethicCtrl.isEthic = YES;
        ethicCtrl.delegate = self;
        ethicCtrl.contentStr = ethnTextField.text;
        [self.navigationController pushViewController:ethicCtrl animated:YES];
        
    } else if(indexPath.row == 5 && indexPath.section == 1) {
        
        EthicBeliefPickerViewController *ethicCtrl = [[EthicBeliefPickerViewController alloc] init];
        ethicCtrl.isEthic = NO;
        ethicCtrl.delegate = self;
        ethicCtrl.contentStr = beliefTextField.text;
        [self.navigationController pushViewController:ethicCtrl animated:YES];
        
    } else if(indexPath.section == 0 && indexPath.row == 3) {
        
        LocationPickerViewController *locationPickerCtrl = [[LocationPickerViewController alloc] init];
        locationPickerCtrl.delegate = self;
        [self.navigationController pushViewController:locationPickerCtrl animated:YES];

    } else if(indexPath.section == 1 && indexPath.row == 6) {
        
        [PFUser currentUser][PF_USER_ACTIVATE] = [NSNumber numberWithBool:NO];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error) {
                if(succeeded) {
                    [self btnSignoutClicked];
                }
            }
        }];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(textField.tag - 100 <3 )
        return;
    [self.contentTableView setContentOffset:CGPointMake(0, (textField.tag-100)*kCellHeight-140) animated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    address = addressTextField.text;
    displayName = displayTextField.text;
    [self.contentTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    address = addressTextField.text;
    displayName = displayTextField.text;
    [self.contentTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [textField resignFirstResponder];
    return NO;
}

#pragma mark -
#pragma mark BtnAvatarClicked

- (void)tapGesAvatarClicked {
    
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Image Source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Library" otherButtonTitles:@"Camera", nil];
//    [sheet showInView:self.view];

    PFQuery *query = [PFQuery queryWithClassName:PF_PHOTO_GALLERY_CLASS_NAME];
    [query whereKey:PF_PHOTO_USER equalTo:[PFUser currentUser]];
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [[KIProgressViewManager manager] hideProgressView];
        if(!error) {
            if(number == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You didn't import profile photos from Facebook Album" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
                [alertView show];

            } else {
//                MJRootViewController *mjViewCtrl = [[MJRootViewController alloc] init];
//                mjViewCtrl.delegate = self;
//                [self.navigationController pushViewController:mjViewCtrl animated:YES];
                TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
                
                photoPicker.cropBlock = ^(UIImage *image) {
                    //do something
                    isImageLoaded = YES;

                    AvatarView.image = image;
                };
                
                UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:photoPicker];
                [navCon setNavigationBarHidden:YES];
                
                [self presentViewController:navCon animated:YES completion:NULL];
                
                
                
            }
        }
    }];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 0) {
        NSLog(@"Library");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    } else  if(buttonIndex == 1) {
        NSLog(@"Camera");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    } else if(buttonIndex == 2) {
        
        NSLog(@"Cancel");
        
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    chosenImage = [chosenImage resizedImageByWidth:200];
    [AvatarView setImage:chosenImage];
    isImageLoaded = YES;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)btnLocationClicked {
    LocationPickerViewController *locationPickerCtrl = [[LocationPickerViewController alloc] init];
    locationPickerCtrl.delegate = self;
    [self.navigationController pushViewController:locationPickerCtrl animated:YES];
}

#pragma mark -
#pragma mark EthicController Delegate
- (void)ethicBeliefControllerSaveBtnClicked:(NSString *) resultStr isEthic:(BOOL) isEthic {
    if(isEthic) {
        ethnTextField.text = resultStr;
        ethnicity = [self convertTextToArray:resultStr];
    } else {
        beliefTextField.text = resultStr;
        belief = [self convertTextToArray:resultStr];
    }
}
- (void)saveBtnClicked:(NSString *) city location:(CLLocation*) location {
    addressTextField.text = city;
    address = city;
    geolocation = [PFGeoPoint geoPointWithLocation:location];
    [GlobalPool sharedInstance].location = [[CLLocation alloc] initWithLatitude:geolocation.latitude longitude:geolocation.longitude];

}

#pragma mark -
#pragma mark MJControllerDelegate
- (void)photoSelected:(NSString *)resultStr {
    isImageLoaded = YES;
    [AvatarView setImageWithURL:[NSURL URLWithString:resultStr]];
}

@end
