//
//  FriendProfileViewController.m
//  Project6
//
//  Created by superman on 3/15/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "Public.h"
#import "GlobalPool.h"

@interface UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding;
- (void)centerVertically;

@end


@implementation UIButton (VerticalLayout)

- (void)centerVerticallyWithPadding:(float)padding
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    CGFloat totalHeight = (imageSize.height + titleSize.height + padding);
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),
                                            15.0f,
                                            0.0f,
                                            -15.0);
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f,
                                            - imageSize.width,
                                            - (totalHeight - titleSize.height),
                                            0.0f);
    
}


- (void)centerVertically
{
    const CGFloat kDefaultPadding = 6.0f;
    
    [self centerVerticallyWithPadding:kDefaultPadding];
}  


@end

@interface FriendProfileViewController ()<UIAlertViewDelegate>
{
    UIScrollView *imageScrollView;
    NSMutableArray *gallery_Array;
    UIScrollView *desScrollView;
    UIScrollView *backScrollView;
    int selected_index;
    TimerView *timerView;
    UIButton *btnChat;
    
    CGFloat scrYInset;
}

@property (nonatomic, strong) UILabel *matchLbl;
@property (nonatomic, strong) UIImageView *matchBackImageView;

@end

@implementation FriendProfileViewController
- (void)purchaseMade {
    
    NSDate *obj_date = nil;
    
    DataManager *dm = [DataManager SharedDataManager];
    
    NSDate *startOfDay = [[NSDate date] dateAtEndOfDay];
    NSDate *endOfDay = [[NSDate dateWithDaysBeforeNow:9] dateAtStartOfDay];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((date >= %@) AND (date < %@)) || (date = nil)",endOfDay,startOfDay];
    NSArray *yesterday_array = [dm getResultsWithEntity:@"Matches" sortDescriptor:@"date" sortPredicate:predicate batchSize:300];
    NSMutableArray *pfusersArray = [NSMutableArray array];
    for(NSManagedObject *object in yesterday_array) {
        [pfusersArray addObject:[object valueForKey:@"pfObjectID"]];
        if([[object valueForKey:@"pfObjectID"] isEqualToString:self.user.objectId]) {
            obj_date = [object valueForKey:@"date"];
        }
    }
    
    PFObject *objectUser = self.user;
    NSManagedObject *purchase = [dm newObjectForEntityForName:@"Purchases"];
    [purchase setValue:objectUser.objectId forKey:@"pfObjectID"];
    [purchase setValue:obj_date forKey:@"date"];
    [purchase didSave];
    
    [dm update];

}
- (int)calcComfortablePercent:(PFObject*) object {
    float sum = 0;
    float tsum = 0;
    for(int i=0; i<15; i++) {
        NSString *key = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
        float number_p = [object[key] floatValue];
        float number_m = [[PFUser currentUser][key] floatValue];
        sum+=ABS(number_m-number_p);
        if(i==3) {
            tsum += sum*2;
            sum = 0;
        }
        if(i == 6) {
            tsum += sum*0.6;
            sum = 0;
        }
        if(i == 14) {
            tsum += sum*0.3;
            sum = 0;
        }
    }
    return (1.0-tsum/1500.0)*100.0;
}
- (BOOL)isPurchaseMade:(PFObject*) obj {
    DataManager *dm = [DataManager SharedDataManager];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pfObjectID = %@", obj.objectId];
    int count = (int)[dm getCountWithEntry:@"Purchases" sortDescriptor:@"date" sortPredicate:predicate batchSize:300];
    if(count>0)
        return YES;
    else
        return NO;
}

- (void)btnUnLockClicked:(UIButton*) sender {
    
    NSString *str_alert = [NSString stringWithFormat:@"Unlock [%@] with 20 Krone",self.user[PF_USER_FULLNAME]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:str_alert delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alertView show];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[KIProgressViewManager manager] hideProgressView];

    scrYInset = self.view.width/4.0*3.0/2.0;
    
    backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0 , self.view.width, self.view.height-44)];
    
    backScrollView.backgroundColor = [UIColor clearColor];
  
    self.title = self.user[PF_USER_FULLNAME];
    
    gallery_Array = [NSMutableArray array];
    
    imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width/4.0*3.0)];
    [imageScrollView setContentSize:CGSizeMake(0, imageScrollView.height)];
    

    //added by Michal 7-7 Tap Gesture
    UIView *tapView = [[UIView alloc] initWithFrame:imageScrollView.bounds];
    tapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap_ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClicked:)];
    [tapView addGestureRecognizer:tap_ges];
    [backScrollView addSubview:tapView];
    //
    
    self.matchBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 86, 86)];
    self.matchBackImageView.image = [UIImage imageNamed:@"matchMark.png"];
    
    CGRect rect = self.matchBackImageView.frame;
    rect.origin.y = imageScrollView.frame.origin.y + imageScrollView.frame.size.height - (rect.size.height / 2) ;
    rect.origin.x = (self.view.width - self.matchBackImageView.frame.size.width) / 2;
    self.matchBackImageView.frame = rect;
    
    self.matchBackImageView.clipsToBounds = NO;
    
    self.matchLbl = [[UILabel alloc] initWithFrame:self.matchBackImageView.bounds];
    self.matchLbl.font = [UIFont boldSystemFontOfSize:48];
    self.matchLbl.textColor = [UIColor whiteColor];
    self.matchLbl.shadowColor = COLOR_IN_DARK_GRAY;
    self.matchLbl.shadowOffset = CGSizeMake(1, 1);
    self.matchLbl.textAlignment = NSTextAlignmentCenter;
    self.matchLbl.text = [NSString stringWithFormat:@"%d",[self calcComfortablePercent:self.user]];
    self.matchLbl.clipsToBounds = NO;
    
    [backScrollView addSubview:self.matchBackImageView];
    [self.matchBackImageView addSubview:self.matchLbl];
    
    [self.view addSubview:imageScrollView];
    [self.view addSubview:backScrollView];

    timerView = [[TimerView alloc] initWithFrame:CGRectMake(self.matchBackImageView.right+10,-25, self.view.width, 50)];
    timerView.centerX = pubWidth/2;
    timerView.top = self.matchBackImageView.bottom+15;
    [backScrollView addSubview:timerView];
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(self.matchBackImageView.right+5, self.matchBackImageView.top+44, 200, 22)];
    lblName.centerX = pubWidth/2;
    lblName.top = self.matchBackImageView.bottom+5;
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.font = [UIFont boldSystemFontOfSize:18];
    lblName.textColor = COLOR_IN_BLACK;
    lblName.text = self.user[PF_USER_FULLNAME];
    [backScrollView addSubview:lblName];
    
    UILabel *lblAddress = [[UILabel alloc] initWithFrame:CGRectMake(self.matchBackImageView.right+5, lblName.bottom, 200, 22)];
    lblAddress.textAlignment = NSTextAlignmentCenter;
    lblAddress.centerX = pubWidth/2;
    lblAddress.top = lblName.bottom;
    lblAddress.font = [UIFont boldSystemFontOfSize:14];
    lblAddress.textColor = COLOR_IN_DARK_GRAY;
    lblAddress.text = [NSString stringWithFormat:@"%d | %@ | %@", (int)[NSDate age:self.user[PF_USER_BIRTHDAY]],[[self.user[PF_USER_GENDER] substringToIndex:1] uppercaseString],self.user[PF_USER_ZIPCODE]];
    [backScrollView addSubview:lblAddress];
    
    btnChat = [[UIButton alloc] initWithFrame:CGRectMake(0,self.view.height -64-48-44, pubWidth, 44)];
    [btnChat setBackgroundColor:COLOR_TINT_SECOND];
    [btnChat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnChat.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnChat setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    NSArray *banArray = [PFUser currentUser][PF_USER_BANS];
    
    if(!banArray)
        banArray = [NSArray array];
    
    if([banArray containsObject:self.user.objectId]) {

        [btnChat setImage:[[UIImage imageNamed:@"endedIcon@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btnChat setTintColor:[UIColor whiteColor]];
        btnChat.titleLabel.numberOfLines = 1;
        btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btnChat setTitle:@" Banned" forState:UIControlStateNormal];

    
    } else {
        
        if([self.date isEarlierThanDate:[[NSDate dateWithDaysBeforeNow:5] dateAtStartOfDay]]) {
            
            if([[PFUser currentUser][PF_USER_UNLOCKED] containsObject:self.user.objectId])
            {
                
                [btnChat setImage:[[UIImage imageNamed:@"messageSendIcon@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [btnChat setTintColor:[UIColor whiteColor]];
                [btnChat addTarget:self action:@selector(btnChatClicked:) forControlEvents:UIControlEventTouchUpInside];
                btnChat.titleLabel.numberOfLines = 1;
                btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
                [btnChat setTitle:@" Message" forState:UIControlStateNormal];
                
            } else {
                
                NSString *unlockStr = [NSString stringWithFormat:@"Unlock\n%d\nKrones",[GlobalPool sharedInstance].kUnlockLimit];
                btnChat.titleLabel.numberOfLines = 1;
                btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
                [btnChat setTitle:unlockStr forState:UIControlStateNormal];
                [btnChat addTarget:self action:@selector(btnUnLockClicked:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            
        } else {
            
            [btnChat setImage:[[UIImage imageNamed:@"messageSendIcon@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [btnChat setTintColor:[UIColor whiteColor]];
            [btnChat addTarget:self action:@selector(btnChatClicked:) forControlEvents:UIControlEventTouchUpInside];
            btnChat.titleLabel.numberOfLines = 1;
            btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btnChat setTitle:@" Message" forState:UIControlStateNormal];
            
        }
    }
    
    imageScrollView.pagingEnabled = YES;
    
    UIImageView *theView = [[UIImageView alloc] initWithFrame:CGRectMake(0, timerView.bottom-10, self.view.width, 8)];
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
    
    
    UILabel *lblIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(10, lblIntroductionMark.bottom, clipView1.width-20, 90)];
    lblIntroduction.textAlignment = NSTextAlignmentLeft;
    lblIntroduction.textColor = COLOR_IN_DARK_GRAY;
    lblIntroduction.font = [UIFont systemFontOfSize:14];
    lblIntroduction.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_ME]] ;

    [lblIntroduction resizeToFit];
    [clipView1 addSubview:lblIntroduction];
    
    clipView1.height = lblIntroduction.height+lblIntroductionMark.bottom+10;
    
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
    
    UILabel *lblIntroduction2 = [[UILabel alloc] initWithFrame:CGRectMake(10, lblIntroductionMark2.bottom, clipView2.width-20, 90)];
    lblIntroduction2.textAlignment = NSTextAlignmentLeft;
    lblIntroduction2.textColor = COLOR_IN_DARK_GRAY;
    lblIntroduction2.font = [UIFont systemFontOfSize:14];
    lblIntroduction2.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_LIFE]] ;
    [lblIntroduction2 resizeToFit];
    [clipView2 addSubview:lblIntroduction2];

    clipView2.height = lblIntroduction2.height+lblIntroductionMark2.bottom+10;
    [backScrollView setContentSize:CGSizeMake(self.view.width, clipView2.bottom + scrYInset)];
    
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

    UILabel *lblIntroduction3 = [[UILabel alloc] initWithFrame:CGRectMake(10, lblIntroductionMark3.bottom, clipView3.width-20, 90)];
    lblIntroduction3.textAlignment = NSTextAlignmentLeft;
    lblIntroduction3.textColor = COLOR_IN_DARK_GRAY;
    lblIntroduction3.font = [UIFont systemFontOfSize:14];
    lblIntroduction3.text = [NSString stringWithFormat:@"%@",self.user[PF_USER_ABOUT_YOU]] ;
    [lblIntroduction3 resizeToFit];

    [clipView3 addSubview:lblIntroduction3];
    clipView3.height = lblIntroduction3.height+lblIntroductionMark3.bottom+10;

    float totalHeight = clipView1.height+clipView2.height+clipView3.height;
    desScrollView.left = 0;
    desScrollView.right = 0;
    [desScrollView setContentSize:CGSizeMake(pubWidth, totalHeight)];
    
    [backScrollView setContentSize:CGSizeMake(self.view.width, clipView3.bottom + scrYInset)];

    UIImageView *back_white_view = [[UIImageView alloc] initWithFrame:CGRectMake(0, scrYInset, pubWidth, backScrollView.contentSize.height)];
    
    rect = back_white_view.frame;
    rect.origin.y = imageScrollView.frame.origin.y + imageScrollView.frame.size.height;
    back_white_view.frame = rect;

    back_white_view.backgroundColor = [UIColor whiteColor];
    
    [backScrollView addSubview:back_white_view];
    [backScrollView sendSubviewToBack:back_white_view];
    
    [self.view addSubview:btnChat];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Ban_On) name:Notification_Ban_On object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Ban_Off) name:Notification_Ban_Off object:nil];
    
    [self loadPhotoLibrary];
    // Do any additional setup after loading the view.
}

- (void)Ban_On {
    
    [btnChat removeTarget:self action:@selector(btnUnLockClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnChat removeTarget:self action:@selector(btnChatClicked:) forControlEvents:UIControlEventTouchUpInside];

    [btnChat setImage:[[UIImage imageNamed:@"endedIcon@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btnChat setTintColor:[UIColor whiteColor]];
    btnChat.titleLabel.numberOfLines = 1;
    btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnChat setTitle:@" Banned" forState:UIControlStateNormal];
    
    [self.user setObject:@"YES" forKey:@"banned"];
    
}

- (void)Ban_Off {
    
    if([self.date isEarlierThanDate:[[NSDate dateWithDaysBeforeNow:5] dateAtStartOfDay]]) {
        
        if([[PFUser currentUser][PF_USER_UNLOCKED] containsObject:self.user.objectId])
        {
            
            [btnChat setImage:[[UIImage imageNamed:@"messageSendIcon@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [btnChat setTintColor:[UIColor whiteColor]];
            [btnChat addTarget:self action:@selector(btnChatClicked:) forControlEvents:UIControlEventTouchUpInside];
            btnChat.titleLabel.numberOfLines = 1;
            btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btnChat setTitle:@" Message" forState:UIControlStateNormal];
            
        } else {
            
            NSString *unlockStr = [NSString stringWithFormat:@"Unlock\n%d\nKrones",[GlobalPool sharedInstance].kUnlockLimit];
            btnChat.titleLabel.numberOfLines = 1;
            btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btnChat setTitle:unlockStr forState:UIControlStateNormal];
            [btnChat addTarget:self action:@selector(btnUnLockClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    } else {
        
        [btnChat setImage:[[UIImage imageNamed:@"messageSendIcon@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btnChat setTintColor:[UIColor whiteColor]];
        [btnChat addTarget:self action:@selector(btnChatClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnChat.titleLabel.numberOfLines = 1;
        btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btnChat setTitle:@" Message" forState:UIControlStateNormal];
        
    }

}

- (void)timerRefresh {

    NSDate *today = [NSDate date];
    NSDate* dateEnd = [today dateAtEndOfDay];
    int seconds = abs((int)[today secondsAfterDate:dateEnd]);
    
    if(self.type == -1) {
        [timerView setTimerDisplay:0];
    } else {
        [timerView setTimerDisplay:seconds];
    }

}
- (void)btnChatClicked:(id) sender {
    
    PFUser *user1 = [PFUser currentUser];
    PFUser *user2 = self.user;
    
    NSString *groupID = StartPrivateChat(user1, user2);
    
    ChatView *chatView = [[ChatView alloc] initWith:groupID];
    chatView.oppUser = self.user;
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerRefresh) name:Notification_Timer_Refresh object:nil];
    [self timerRefresh];

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Timer_Refresh object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadPhotoLibrary {
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_PHOTO_GALLERY_CLASS_NAME];
    [query whereKey:PF_PHOTO_USER equalTo:self.user];
    [query orderByAscending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(objects.count == 0) {
                UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width/4.0*3.0)];
                backImageView.clipsToBounds = YES;
                [backImageView setImageWithURL:[NSURL URLWithString:self.user[PF_USER_PICTURE]]];
                backImageView.contentMode = UIViewContentModeScaleAspectFill;
                backImageView.left = 0 * imageScrollView.width;
                backImageView.userInteractionEnabled = YES;
                backImageView.tag = 0+100;
                [imageScrollView addSubview:backImageView];

            } else {
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
                    
                    UITapGestureRecognizer *tap_ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesClicked:)];
                    tap_ges.numberOfTapsRequired = 1;
                    [backImageView addGestureRecognizer:tap_ges];
                    
                    skip++;
                    
                    [gallery_Array addObject:object];
                }
                [imageScrollView setContentSize:CGSizeMake(imageScrollView.width*objects.count, self.view.width/4.0*3.0)];
                
            }
            [backScrollView sendSubviewToBack:imageScrollView];
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
}
- (void)tapGesClicked:(UITapGestureRecognizer *) tapGes {
    
//    MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = YES;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    
    selected_index = tapGes.view.right/imageScrollView.width-1 ;
    
//    PFObject *obj_selected = [gallery_Array objectAtIndex:selected_index];
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for(PFObject *obj_item in gallery_Array) {
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:obj_item[PF_PHOTO_PICTURE]]];
        [photos addObject:photo];
    }
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
    browser.enableSwipeNextPrev = YES;
    browser.enableDeleteBtn = NO;
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

#pragma mark -
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        if([[GlobalPool sharedInstance] unLock:[GlobalPool sharedInstance].kUnlockLimit]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
            [self purchaseMade];
            
            [btnChat removeTarget:self action:@selector(btnUnLockClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btnChat setImage:[[UIImage imageNamed:@"messageSendIcon@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            [btnChat setTintColor:[UIColor whiteColor]];
            [btnChat addTarget:self action:@selector(btnChatClicked:) forControlEvents:UIControlEventTouchUpInside];
            btnChat.titleLabel.numberOfLines = 1;
            btnChat.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btnChat setTitle:@" Message" forState:UIControlStateNormal];
            
        }

    }
}

@end
