//
//  LeftMenuViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "Public.h"
#import "MatchesViewController.h"
#import "RootMatchViewController.h"
#import "MessagesViewController.h"
#import "RootProfileViewController.h"
#import "InviteViewController.h"
#import "KroneShopViewController.h"
#import "PhototasticViewController.h"
#import "SettingsViewController.h"
#import "RootPhototasticViewController.h"
#import "QueryViewController.h"
#import "RecentView.h"
#import "LoginViewController.h"

#define kWidth 240
#define kButtonWidth 60

@interface LeftMenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (strong, nonatomic) APAvatarImageView *avatarView;
@property (strong, nonatomic) UILabel *lblTitle;
@property (strong, nonatomic) UILabel *lblNumberOfCrones;

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_IN_BLACK;

    self.avatarView = [[APAvatarImageView alloc] initWithFrame:CGRectMake(70, 50, 100, 100)];
    [self.avatarView setBorderWidth:4.0];
    [self.avatarView setBorderColor:COLOR_MENU_NEW];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.avatarView];
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, self.avatarView.bottom+10, kWidth-40, 22)];
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.font = [UIFont boldSystemFontOfSize:18];
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.lblTitle];
    
    UIImageView *croneView = [[UIImageView alloc] initWithFrame:CGRectMake(self.lblTitle.centerX-40, self.lblTitle.bottom+10, 30, 30)];
    croneView.image = [UIImage imageNamed:@"crown2"];
    
    [self.view addSubview:croneView];
    
    self.lblNumberOfCrones = [[UILabel alloc] initWithFrame:CGRectMake(croneView.right+10, self.lblTitle.bottom+10, kWidth-20, 20)];
    self.lblNumberOfCrones.textColor = [UIColor whiteColor];
    self.lblNumberOfCrones.centerY = croneView.centerY;
    self.lblNumberOfCrones.font = [UIFont boldSystemFontOfSize:16];
    [self.view addSubview:self.lblNumberOfCrones];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(30, (self.view.frame.size.height - 40 * 7) / 2.0f+70, kWidth-60, 40 * 7) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];

//    UIButton *btnSettings = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    [btnSettings setImage:[UIImage imageNamed:@"settingsIcon.png"] forState:UIControlStateNormal];
//    [btnSettings addTarget:self action:@selector(btnSettingsClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    btnSettings.centerX = self.tableView.centerX;
//    btnSettings.centerY = self.view.height-50;
//    
//    [self.view addSubview:btnSettings];
    
    [self loadInitalProfile];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInitalProfile) name:Notification_InitialSetting_Refresh object:nil];
    // Do any additional setup after loading the view.
}
- (void)loadInitalProfile {
    if([PFUser currentUser][PF_USER_THUMBNAIL]) {
        PFFile *profileImage = [PFUser currentUser][PF_USER_THUMBNAIL];
        [profileImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            UIImage *thumbnailImage = [UIImage imageWithData:imageData];
            self.avatarView.image = thumbnailImage;
        }];
        
    } else {
        [self.avatarView setImageWithURL:[NSURL URLWithString:[PFUser currentUser][PF_USER_PICTURE]] placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    }
    self.lblTitle.text = [[PFUser currentUser] valueForKey:PF_USER_FULLNAME];
    self.lblNumberOfCrones.text = [NSString stringWithFormat:@"%d",[[[PFUser currentUser] objectForKey:PF_USER_CRONES] intValue]];

}
- (void)btnSettingsClicked {
    NSLog(@"Settings Clicked");
    SettingsViewController *settingsCtrl = [[SettingsViewController alloc] init];
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:settingsCtrl]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];

}
#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[RootMatchViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 1: {
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[RecentView alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 2: {
            RootProfileViewController *rootProfileView =  [[RootProfileViewController alloc] init];
            rootProfileView.user = [PFUser currentUser];
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:rootProfileView]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 3: {
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[InviteViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 4: {
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[KroneShopViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 5: {
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[RootPhototasticViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        case 6: {
            
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]]
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSArray *titles = @[@"Matches", @"Messages", @"Profile", @"Invite", @"Krone Shop",@"Phototastic",@"Settings"];
    NSArray *images = @[@"loveIcon", @"messageIcon", @"profileIcon", @"mailIcon", @"crown3",@"photoIcon",@"settingsIcon"];
    
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [[UIImage imageNamed:images[indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.imageView setTintColor:COLOR_MENU_NEW];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
