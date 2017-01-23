//
//  KroneShopViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "KroneShopViewController.h"
#import "InviteViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"

#define IAP25  @"com.kenneth.project6.iap25"
#define IAP250 @"com.kenneth.project6.iap250"
#define IAP500 @"com.kenneth.project6.iap500"
#define IAP50  @"com.kenneth.project6.iap25"

@interface KroneShopViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *freeTableView;
@property (nonatomic, strong) UITableView *buyTableView;

@end

@implementation KroneShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Krone Shop";
    
    UILabel *lblIntroductionMark = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 24)];
    lblIntroductionMark.textAlignment = NSTextAlignmentCenter;
    lblIntroductionMark.textColor = COLOR_IN_BLACK;
    lblIntroductionMark.font = [UIFont boldSystemFontOfSize:18];
    lblIntroductionMark.text = @"Get Free Krones";

    UILabel *lblIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(0, lblIntroductionMark.bottom+5, self.view.width, 30)];
    lblIntroduction.textAlignment = NSTextAlignmentCenter;
    lblIntroduction.textColor = COLOR_IN_DARK_GRAY;
    lblIntroduction.font = [UIFont systemFontOfSize:14];
    lblIntroduction.text = @"Use Krones to unlock additional features!";
    
    [self.view addSubview:lblIntroductionMark];
    [self.view addSubview:lblIntroduction];
    
    self.freeTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, lblIntroduction.bottom,self.view.width,120) style:UITableViewStylePlain];
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
    [self.view addSubview:self.freeTableView];

    UILabel *lblBuyIntroductionMark = [[UILabel alloc] initWithFrame:CGRectMake(0,self.freeTableView.bottom + 10, self.view.width, 24)];
    lblBuyIntroductionMark.textAlignment = NSTextAlignmentCenter;
    lblBuyIntroductionMark.textColor = COLOR_IN_BLACK;
    lblBuyIntroductionMark.font = [UIFont boldSystemFontOfSize:18];
    lblBuyIntroductionMark.text = @"Buy Krones";
    
    UILabel *lblBuyIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(0, lblBuyIntroductionMark.bottom+5, self.view.width, 30)];
    lblBuyIntroduction.textAlignment = NSTextAlignmentCenter;
    lblBuyIntroduction.textColor = COLOR_IN_DARK_GRAY;
    lblBuyIntroduction.font = [UIFont systemFontOfSize:14];
    lblBuyIntroduction.text = @"Use Krones to unlock additional features!";
    
    [self.view addSubview:lblBuyIntroductionMark];
    [self.view addSubview:lblBuyIntroduction];
    
    self.buyTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, lblBuyIntroduction.bottom,self.view.width,120) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.tag = 11;
        tableView.backgroundView = nil;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.buyTableView];

// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.textLabel.textColor = COLOR_IN_DARK_GRAY;
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *crone_view = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 24, 24)];
    crone_view.image = [UIImage imageNamed:@"crown2.png"];
    [cell.contentView addSubview:crone_view];
    
    UILabel *croneVal_lbl = [[UILabel alloc] initWithFrame:CGRectMake(crone_view.right+5, 8, 50, 24)];
    croneVal_lbl.font = [UIFont systemFontOfSize:14];
    croneVal_lbl.textAlignment = NSTextAlignmentLeft;
    croneVal_lbl.textColor = COLOR_IN_DARK_GRAY;
    [cell.contentView addSubview:croneVal_lbl];
    
    UILabel *price_lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width-40-150, 8, 150, 24)];
    price_lbl.font = [UIFont systemFontOfSize:14];
    price_lbl.right = self.view.width-32;
    price_lbl.textAlignment = NSTextAlignmentRight;
    price_lbl.textColor = COLOR_Border;
    [cell.contentView addSubview:price_lbl];
    if(tableView.tag == 10) {
        if(indexPath.row == 0) {
            croneVal_lbl.text = @"5";
            price_lbl.text = @"Invite a Friend";
        } else if(indexPath.row == 1) {
            price_lbl.text = @"Tweet #TheProjectSix";
            croneVal_lbl.text = @"25";
            UIImageView *tweet_view = [[UIImageView alloc] initWithFrame:CGRectMake(110, 8, 24, 24)];
            tweet_view.image = [UIImage imageNamed:@"tweetIcon.png"];
            [cell.contentView addSubview:tweet_view];
        } else if(indexPath.row == 2) {
            croneVal_lbl.text = @"25";
            price_lbl.text = @"Follow #TheProjectSix";
            UIImageView *tweet_view = [[UIImageView alloc] initWithFrame:CGRectMake(110, 8, 24, 24)];
            tweet_view.image = [UIImage imageNamed:@"tweetIcon.png"];
            [cell.contentView addSubview:tweet_view];
        }
    } else {
        if(indexPath.row == 0) {
            croneVal_lbl.text = @"25";
            price_lbl.text = @"$1.99";
        } else if(indexPath.row == 1) {
            croneVal_lbl.text = @"250";
            price_lbl.text = @"$15.99";
        } else if(indexPath.row == 2) {
            croneVal_lbl.text = @"500";
            price_lbl.text = @"$17.99";
        }
    }

    return cell;
}
-(int) generateRandomNumberWithlowerBound:(int)lowerBound
                               upperBound:(int)upperBound
{
    int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    return rndValue;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView.tag == 10) {
        //Follow
        
        switch (indexPath.row) {
            case 0:
            {
                InviteViewController *inviteViewCtrl = [[InviteViewController alloc] init];
                [self.navigationController pushViewController:inviteViewCtrl animated:YES];
                break;
            }
            case 1:
            {
                
                PFQuery *query = [PFQuery queryWithClassName:PF_FREEKRONE_CLASS];
                [query whereKey:PF_FREEKRONE_OWNER equalTo:[PFUser currentUser]];
                [query whereKey:PF_FREEKRONE_TYPE equalTo:@"tweet"];
                [query whereKey:@"createdAt" greaterThan:[[NSDate date] dateAtStartOfDay]];
                [query whereKey:@"createdAt" lessThan:[[NSDate date] dateAtEndOfDay]];
                [[KIProgressViewManager manager] showProgressOnView:self.view];
                int countTweets = (int)[query countObjects];
                
                PFQuery *query_tweets = [PFQuery queryWithClassName:PF_TWEETS_CLASS];
                NSArray *tweet_contents = [query_tweets findObjects];
                NSString *tweet_content;
                if(tweet_contents.count == 0) {
                    tweet_content =@"Fantastic #TheProjectSix\nhttps://twitter.com/theprojectsix";
                } else {
                    PFObject* obj = [tweet_contents objectAtIndex:[self generateRandomNumberWithlowerBound:0 upperBound:(int)(tweet_contents.count)]];
                    tweet_content = obj[PF_TWEETS_CONTENT];
                }
                
                [[KIProgressViewManager manager] hideProgressView];
                
                if(countTweets == 0) {
                    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                    {
                        SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                        [tweet setInitialText:tweet_content];
                        [tweet setTitle:@"TheProjectSix"];
                        [tweet setCompletionHandler:^(SLComposeViewControllerResult result)
                         {
                             if (result == SLComposeViewControllerResultCancelled)
                             {
                                 NSLog(@"The user cancelled.");
                             }
                             else if (result == SLComposeViewControllerResultDone)
                             {
                                 NSLog(@"The user sent the tweet");
                                 int currentVal = [[PFUser currentUser][PF_USER_CRONES] intValue];
                                 currentVal = currentVal + 25;
                                 if(currentVal>=0) {
                                     [PFUser currentUser][PF_USER_CRONES] = [NSNumber numberWithInt:currentVal];
                                     [[PFUser currentUser] saveInBackground];
                                     [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
                                 }
                                 
                                 PFObject *object = [PFObject objectWithClassName:PF_FREEKRONE_CLASS];
                                 object[PF_FREEKRONE_OWNER] = [PFUser currentUser];
                                 object[PF_FREEKRONE_TYPE] = @"tweet";
                                 object[PF_FREEKRONE_CONTENT] = @"tweet";
                                 [object saveInBackground];
                                 
                             }
                         }];
                        [self presentViewController:tweet animated:YES completion:nil];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Project6 Notice"
                                                                        message:@"Twitter integration is not available.  A Twitter account must be set up on your device."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    }
                }
                else {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Project6 Notice"
                                                                    message:@"You have to wait for tomorrow to tweet again."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }
                break;

            }
            case 2:
            {
                
                [self followTweet];

                break;
            }
            default:
                break;
        }
        
    } else {
        //In app purchase
        switch (indexPath.row) {
            case 0:
            {
                [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:IAP25];
                break;
            }
            case 1: {
                [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:IAP250];
                break;
            }
            case 2: {
                [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:IAP500];
                break;
            }
            default:
                break;
        }
    }
}
- (void)followTweet {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"theprojectsix", @"true", nil] forKeys:[NSArray arrayWithObjects:@"screen_name", @"follow", nil]]];
                [postRequest setAccount:twitterAccount];
                
                [[KIProgressViewManager manager] showProgressOnView:self.view];

                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    dispatch_sync( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{

                        if(!error) {
                            id json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                            int notificationValue = [[json objectForKey:@"notifications"] intValue];
                            if(notificationValue == 0) {
                                
                                PFQuery *query = [PFQuery queryWithClassName:PF_FREEKRONE_CLASS];
                                [query whereKey:PF_FREEKRONE_OWNER equalTo:[PFUser currentUser]];
                                [query whereKey:PF_FREEKRONE_TYPE equalTo:@"tweet_following"];
                                [query whereKey:PF_FREEKRONE_CONTENT equalTo:twitterAccount.username];
                                
                                int count_twfollowing = (int)[query countObjects];
                                if(count_twfollowing == 0) {
                                    [self performSelectorOnMainThread:@selector(manageFollow2:) withObject:twitterAccount.username waitUntilDone:NO];

                                } else {
                                    [self performSelectorOnMainThread:@selector(manageFollow1) withObject:nil waitUntilDone:NO];

                                }
                                
                            } else {
                                
                                [self performSelectorOnMainThread:@selector(manageFollow) withObject:nil waitUntilDone:NO];
                            }
                        } else {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Please try again later!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                            [alertView show];
                        }
                        
                    });

                    
                    [[KIProgressViewManager manager] hideProgressView];
                }];
            }
            
        }
    }];
    
//    NSArray *urls = [NSArray arrayWithObjects:
//                     @"twitter://user?screen_name={handle}", // Twitter
//                     @"tweetbot:///user_profile/{handle}", // TweetBot
//                     @"echofon:///user_timeline?{handle}", // Echofon
//                     @"twit:///user?screen_name={handle}", // Twittelator Pro
//                     @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
//                     @"x-birdfeed://user?screen_name={handle}", // Birdfeed
//                     @"tweetings:///user?screen_name={handle}", // Tweetings
//                     @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
//                     @"icebird://user?screen_name={handle}", // IceBird
//                     @"fluttr://user/{handle}", // Fluttr
//                     @"http://twitter.com/{handle}",
//                     nil];
//    
//    UIApplication *application = [UIApplication sharedApplication];
//    
//    for (NSString *candidate in urls) {
//        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:@"theprojectsix"]];
//        if ([application canOpenURL:url]) {
//            [application openURL:url];
//            // Stop trying after the first URL that succeeds
//            return;
//        }
//    }
}

- (void)manageFollow {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are already following @TheProjecctSix" message:@"No Krones have been awarded." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];

}
- (void)manageFollow1 {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are now following @TheProjecctSix" message:@"25 Krones had been already awarded." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];

}
- (void)manageFollow2:(id) username {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You are now following @TheProjecctSix" message:@"25 Krones have been awarded." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    
    int currentVal = [[PFUser currentUser][PF_USER_CRONES] intValue];
    currentVal = currentVal + 25;
    if(currentVal>=0) {
        [PFUser currentUser][PF_USER_CRONES] = [NSNumber numberWithInt:currentVal];
        [[PFUser currentUser] saveInBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
    }
    
    PFObject *object = [PFObject objectWithClassName:PF_FREEKRONE_CLASS];
    object[PF_FREEKRONE_OWNER] = [PFUser currentUser];
    object[PF_FREEKRONE_TYPE] = @"tweet_following";
    object[PF_FREEKRONE_CONTENT] = username;
    [object saveInBackground];
    

}
@end
