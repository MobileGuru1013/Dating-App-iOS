//
//  LoginViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "QueryViewController.h"
#import "Public.h"
#import "AppDelegate.h"
#import "push.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        [self.navigationController pushViewControllerRetro:[(AppDelegate*)[UIApplication sharedApplication].delegate sideMenuViewCtrl]];
//    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backImageView.image = [UIImage imageNamed:@"loginBack.png"];
    
    [self.view addSubview:backImageView];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    logoImageView.image = [UIImage imageNamed:@"logo2.png"];
    logoImageView.center = self.view.center;
    logoImageView.centerY = self.view.centerY-50;
    logoImageView.layer.cornerRadius = 12.0;
    logoImageView.layer.masksToBounds = YES;
    [self.view addSubview:logoImageView];
    
    UIButton *btnFbConnect = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width-280)/2, self.view.height-120, 280, 46)];
    [btnFbConnect setImage:[UIImage imageNamed:@"fbconnect.png"] forState:UIControlStateNormal];
    [btnFbConnect addTarget:self action:@selector(btnFbClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnFbConnect];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, btnFbConnect.top-50, self.view.width, 30)];
    lblDescription.text = @"Signup or login with Facebook to start using\nProject 6 today!";
    lblDescription.font = [UIFont systemFontOfSize:12];
    lblDescription.numberOfLines = 2;
    lblDescription.textColor = [UIColor whiteColor];
    lblDescription.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:lblDescription];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)btnFbClicked {
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    [PFFacebookUtils logInWithPermissions:@[@"user_about_me",@"email", @"user_birthday", @"user_location",@"user_photos"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            [[KIProgressViewManager manager] hideProgressView];

        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            
            ParsePushUserAssign();
            
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                // handle response
                if (!error) {
                    // Parse the data received
                    
                    NSDictionary *userData = (NSDictionary *)result;
                    NSLog(@"%@",userData);
                    NSString *facebookID = userData[@"id"];
                    
                    NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
                    
                    if (facebookID) {
                        userProfile[@"facebookId"] = facebookID;
                    }
                    
                    NSString *name = userData[@"name"];
                    if (name) {
                        userProfile[@"name"] = name;
                    }
                    
                    NSString *email = userData[@"email"];
                    if(email) {
                        userProfile[@"email"] = email;
                    }
                    
                    NSString *location = userData[@"location"][@"name"];
                    if (location) {
                        userProfile[@"location"] = location;
                    } else {
                        userProfile[@"location"] = @"N/A";
                    }
                    
                    NSString *gender = userData[@"gender"];
                    if (gender) {
                        userProfile[@"gender"] = gender;
                    }
                    
                    NSString *birthday = userData[@"birthday"];
                    if (birthday) {
                        userProfile[@"birthday"] = birthday;
                    } else {
                        userProfile[@"birthday"] = @"na";
                    }
                    
                    userProfile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
                    
                    QueryViewController *queryView = [[QueryViewController alloc] init];
                    queryView.fbData = userProfile;
                    [self.navigationController pushViewControllerRetro:queryView];
                    
                } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                            isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
                    NSLog(@"The facebook session was invalidated");
                } else {
                    NSLog(@"Some other error: %@", error);
                }
                [[KIProgressViewManager manager] hideProgressView];
            }];

        } else {
            NSLog(@"User logged in through Facebook!");
            ParsePushUserAssign();
            [[KIProgressViewManager manager] hideProgressView];
            [self.navigationController pushViewControllerRetro:[(AppDelegate*)[UIApplication sharedApplication].delegate sideMenuViewCtrl]];
            
            if([PFUser currentUser][PF_USER_ACTIVATE]) {
                if([[PFUser currentUser][PF_USER_ACTIVATE] boolValue] == NO) {

                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Your account has been re-activated! Welcome back!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                    
                    [PFUser currentUser][PF_USER_ACTIVATE] = [NSNumber numberWithBool:YES];
       
                }
            }
        }
    }];

//    UIWindow *window = (UIWindow*)[[UIApplication sharedApplication].windows firstObject];
//    window.rootViewController = [(AppDelegate*)[UIApplication sharedApplication].delegate sideMenuViewCtrl];
//    [self.navigationController pushViewControllerRetro:[(AppDelegate*)[UIApplication sharedApplication].delegate sideMenuViewCtrl]];
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
