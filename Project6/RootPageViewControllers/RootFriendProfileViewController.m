//
//  RootFriendProfileViewController.m
//  Project6
//
//  Created by superman on 3/15/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "RootFriendProfileViewController.h"
#import "FriendProfileViewController.h"
#import "ProfileQuestionsViewController.h"
#import "FriendProfilePersonalityViewController.h"
#import "DALinedTextView.h"
#import "IQFeedbackView.h"
#import "AppDelegate.h"

@interface RootFriendProfileViewController ()<SHViewPagerDataSource, SHViewPagerDelegate,UITextViewDelegate>
{
    SHViewPager *pager;
    NSArray *menuItems;
    UIView* popupView;
    
    UIView* flagView;
    UITextView *comment_view;
}
@end

@implementation RootFriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.user[PF_USER_FULLNAME];
    self.view.backgroundColor = [UIColor whiteColor];
    
    pager = [[SHViewPager alloc] initWithFrame:self.view.bounds];
    
    pager.dataSource = self;
    pager.delegate = self;
    
    menuItems = [[NSArray alloc] initWithObjects:@"About", @"Personality", nil];
    
    [pager reloadData];
    
    [self.view addSubview:pager];

    UIBarButtonItem *item_down = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"downArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(itemBanClicked:)];
    self.navigationItem.rightBarButtonItem = item_down;
    
    popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
    UIButton *btnBan = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    
    NSArray *banArray = [PFUser currentUser][PF_USER_BANS];
    
    if(!banArray)
        banArray = [NSArray array];
    
    if([banArray containsObject:self.user.objectId]) {
        
        [btnBan setTitle:@"  Unblock the user from contacting you" forState:UIControlStateNormal];
        [btnBan setImage:[[UIImage imageNamed:@"unban_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
        
    } else {
        
        [btnBan setTitle:@" Ban user from contacting you" forState:UIControlStateNormal];
        [btnBan setImage:[[UIImage imageNamed:@"banIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    }
    
    [btnBan setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnBan setTintColor:[UIColor whiteColor]];
    [btnBan.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnBan setBackgroundColor:COLOR_MENU];
    [btnBan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBan addTarget:self action:@selector(btnBanClicked:) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:btnBan];
    
    UIButton *btnFlag = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, self.view.width, 40)];
    [btnFlag setTitle:@" Flag user for inappropriate content" forState:UIControlStateNormal];
    [btnFlag setBackgroundColor:COLOR_MENU];
    [btnFlag.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnFlag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnFlag setTintColor:[UIColor whiteColor]];
    [btnFlag setImage:[[UIImage imageNamed:@"flagIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btnFlag setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnFlag addTarget:self action:@selector(btnFlagClicked:) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:btnFlag];
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, self.view.width-60, 1)];
    lineImageView.backgroundColor = [UIColor darkGrayColor];
    lineImageView.centerY = 40;
    [popupView addSubview:lineImageView];
    
    popupView.bottom = 0;
    
    //Flag View
    flagView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, pubWidth-40, 450)];
    flagView.backgroundColor = COLOR_MENU;
    
    UILabel *lbl_flag = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, flagView.width-20, 50)];
    lbl_flag.textAlignment = NSTextAlignmentLeft;
    lbl_flag.font = [UIFont systemFontOfSize:18];
    lbl_flag.textColor = [UIColor whiteColor];
    lbl_flag.text = [NSString stringWithFormat:@"Please let us know why you are flagging [%@]?",self.user[PF_USER_FULLNAME]];
    lbl_flag.numberOfLines = 2;
    lbl_flag.centerX = flagView.width/2;
    [flagView addSubview:lbl_flag];
    
    UIButton *btn_opt1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, flagView.width-20, 30)];
    [btn_opt1 setImage:[[UIImage imageNamed:@"option_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_opt1 setImage:[[UIImage imageNamed:@"option_select_ok.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [btn_opt1 setTitle:@"The profile contains inappropriate content." forState:UIControlStateNormal];
    [btn_opt1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn_opt1 setTintColor:[UIColor whiteColor]];
    btn_opt1.centerX = flagView.width/2;
    btn_opt1.top = lbl_flag.bottom + 20;
    btn_opt1.titleLabel.numberOfLines = 2;
    btn_opt1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn_opt1.tag = 1;
    [btn_opt1 addTarget:self action:@selector(btn_opt_clicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [flagView addSubview:btn_opt1];
    
    UIButton *btn_opt2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, flagView.width-20, 30)];
    [btn_opt2 setImage:[[UIImage imageNamed:@"option_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_opt2 setImage:[[UIImage imageNamed:@"option_select_ok.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [btn_opt2 setTitle:@"The person sent me inappropriate stuff in a message." forState:UIControlStateNormal];
    [btn_opt2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn_opt2 setTintColor:[UIColor whiteColor]];
    btn_opt2.centerX = flagView.width/2;
    btn_opt2.top = btn_opt1.bottom + 20;
    btn_opt2.titleLabel.numberOfLines = 2;
    btn_opt2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn_opt2.tag = 2;
    [btn_opt2 addTarget:self action:@selector(btn_opt_clicked:) forControlEvents:UIControlEventTouchUpInside];

    [flagView addSubview:btn_opt2];
    
    UIButton *btn_opt3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, flagView.width-20, 30)];
    [btn_opt3 setImage:[[UIImage imageNamed:@"option_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_opt3 setImage:[[UIImage imageNamed:@"option_select_ok.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [btn_opt3 setTitle:@"The profile inpersonates me or someone I know." forState:UIControlStateNormal];
    [btn_opt3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn_opt3 setTintColor:[UIColor whiteColor]];
    btn_opt3.centerX = flagView.width/2;
    btn_opt3.top = btn_opt2.bottom + 20;
    btn_opt3.titleLabel.numberOfLines = 2;
    btn_opt3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn_opt3.tag = 3;
    [btn_opt3 addTarget:self action:@selector(btn_opt_clicked:) forControlEvents:UIControlEventTouchUpInside];

    [flagView addSubview:btn_opt3];
    
    UIButton *btn_opt4 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, flagView.width-20, 30)];
    [btn_opt4 setImage:[[UIImage imageNamed:@"option_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_opt4 setImage:[[UIImage imageNamed:@"option_select_ok.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [btn_opt4 setTitle:@"The profile is fake" forState:UIControlStateNormal];
    [btn_opt4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn_opt4 setTintColor:[UIColor whiteColor]];
    btn_opt4.centerX = flagView.width/2;
    btn_opt4.top = btn_opt3.bottom + 20;
    btn_opt4.titleLabel.numberOfLines = 2;
    btn_opt4.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn_opt4.tag = 4;
    [btn_opt4 addTarget:self action:@selector(btn_opt_clicked:) forControlEvents:UIControlEventTouchUpInside];

    [flagView addSubview:btn_opt4];
    
    UIButton *btn_opt5 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, flagView.width-20, 30)];
    [btn_opt5 setImage:[[UIImage imageNamed:@"option_select.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btn_opt5 setImage:[[UIImage imageNamed:@"option_select_ok.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [btn_opt5 setTitle:@"Other & Additional Comment" forState:UIControlStateNormal];
    [btn_opt5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn_opt5 setTintColor:[UIColor whiteColor]];
    btn_opt5.centerX = flagView.width/2;
    btn_opt5.top = btn_opt4.bottom + 10;
    btn_opt5.titleLabel.numberOfLines = 2;
    btn_opt5.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn_opt5.tag = 5;
    [btn_opt5 addTarget:self action:@selector(btn_opt_clicked:) forControlEvents:UIControlEventTouchUpInside];

    [flagView addSubview:btn_opt5];
    
    comment_view = [[UITextView alloc] initWithFrame:CGRectMake(20, btn_opt5.bottom+10, flagView.width-40, 70)];
    comment_view.backgroundColor = [UIColor whiteColor];
    comment_view.textColor = [UIColor blackColor];
    comment_view.font = [UIFont systemFontOfSize:14];
    comment_view.layer.cornerRadius = 5;
    comment_view.layer.masksToBounds = YES;
    comment_view.delegate = self;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, pubWidth, 44)];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.translucent = YES;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWriting)];

    [toolBar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
    
    comment_view.inputAccessoryView = toolBar;
    
    [flagView addSubview:comment_view];
    
    UIButton *flag_cancel = [[UIButton alloc] initWithFrame:CGRectMake(10, comment_view.bottom+10, flagView.width/2-20, 40)];
    flag_cancel.layer.cornerRadius = 4;
    flag_cancel.layer.masksToBounds = YES;
    flag_cancel.backgroundColor = [UIColor colorWithRed:103.0/255.0 green:42.0/255.0 blue:75.0/255.0 alpha:1.0];
    [flag_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [flag_cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flag_cancel addTarget:self action:@selector(flag_cancel_clicked) forControlEvents:UIControlEventTouchUpInside];
    [flag_cancel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [flagView addSubview:flag_cancel];
    
    flag_cancel.right = flagView.width/2-10;
    
    UIButton *flag_flag = [[UIButton alloc] initWithFrame:CGRectMake(10, comment_view.bottom+10, flagView.width/2-20, 40)];
    flag_flag.layer.cornerRadius = 4;
    flag_flag.layer.masksToBounds = YES;
    flag_flag.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:54.0/255.0 blue:70.0/255.0 alpha:1.0];
    [flag_flag setTitle:@"Flag" forState:UIControlStateNormal];
    [flag_flag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [flag_flag addTarget:self action:@selector(flag_flagClicked) forControlEvents:UIControlEventTouchUpInside];
    flag_flag.left = flagView.width/2+10;
    [flag_flag setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [flagView addSubview:flag_flag];
    
    flagView.top = self.view.height;
    flagView.centerX = pubWidth/2;
    
    UITapGestureRecognizer *tap_ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFlagViewClicked)];
    [flagView addGestureRecognizer:tap_ges];
    
    
    
    // Do any additional setup after loading the view.
}
/*- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.isDeepLink) {
        
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    }
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.isDeepLink) {
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        self.loginNavCtrl.navigationBarHidden = NO;

    }
    else
    {
      AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
      ref.loginNavCtrl.navigationBarHidden = YES;
    }
}


- (void)doneWriting {
    
    [UIView animateWithDuration:0.3 animations:^{
        flagView.top = 60;
    }];

    [comment_view resignFirstResponder];

}

- (void)tapFlagViewClicked {
    [comment_view resignFirstResponder];
}

- (void)flag_flagClicked {
    
    [comment_view resignFirstResponder];
    
    int temp_index = -1;
    
    for(int i=0; i<5; i++) {
        UIButton *btnTemp = (UIButton*)[flagView viewWithTag:i+1];
        if(btnTemp.selected == YES) {
            temp_index = i;
        }
    }

    NSArray *array_flag = [NSArray arrayWithObjects:@"The profile contains inappropriate content.",
                           @"The person sent me inappropriate stuff in a message",
                           @"The profile inpersonates me or someone I know",
                           @"The profile is fake",
                           comment_view.text, nil];
    
    if(temp_index == -1) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Please choose appropriate reason." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        
    } else {
        
        PFObject *object = [PFObject objectWithClassName:PF_FLAG_CLASS];
        object[PF_FLAG_REASON] = [array_flag objectAtIndex:temp_index];
        if([PFUser currentUser][PF_USER_EMAIL])
            object[PF_FLAG_USER] = [PFUser currentUser][PF_USER_EMAIL];
        if(self.user[PF_USER_EMAIL])
            object[PF_FLAG_REPORTER] = self.user[PF_USER_EMAIL];
        object[PF_FLAG_TIME] = [NSDate date];
        [object saveInBackground];
        
        [self flag_cancel_clicked];
    
    }
    
}

- (void)flag_cancel_clicked {
    
    for(int i=0; i<5; i++) {
        UIButton *btnTemp = (UIButton*)[flagView viewWithTag:i+1];
        btnTemp.selected = NO;
    }
    [UIView animateWithDuration:0.3 animations:^{
        flagView.top = self.view.height;
        
    } completion:^(BOOL finished) {
        if(finished) {
            [flagView removeFromSuperview];
            comment_view.text = @"";
        }
    }];

}

- (void)btn_opt_clicked:(UIButton*) sender {
    
    for(int i=0; i<5; i++) {
        UIButton *btnTemp = (UIButton*)[flagView viewWithTag:i+1];
        btnTemp.selected = NO;
    }
    
    UIButton *btnTemp = (UIButton*)sender;
    btnTemp.selected = YES;
    
    if(btnTemp.tag == 5) {
        [UIView animateWithDuration:0.3 animations:^{
            flagView.centerY = self.view.centerY-250;
        }];
         [comment_view becomeFirstResponder];
    } else {
        [comment_view resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            flagView.top = 60;
        }];
    }
    
}

- (void)showPopup {
    [self.view addSubview:popupView];
    [UIView animateWithDuration:0.3 animations:^{
        popupView.transform= CGAffineTransformMakeTranslation(0, 80);
    }];
}
- (void)hidePopup {
    [self.view addSubview:popupView];
    [UIView animateWithDuration:0.3 animations:^{
        popupView.transform= CGAffineTransformIdentity;
    }];
}
- (void)itemBanClicked:(id) sender {
    if(popupView.bottom > 0) {
        [self hidePopup];
    } else {
        [self showPopup];
    }
}
- (void)btnBanClicked:(id) sender {
    
    UIButton *btn_sender = (UIButton*)sender;
    
    [self hidePopup];
    NSArray *banArray = [PFUser currentUser][PF_USER_BANS];
    if(!banArray)
        banArray = [NSArray array];
    NSMutableArray *newBanArray = [NSMutableArray arrayWithArray:banArray];
    
    if([newBanArray containsObject:self.user.objectId]) {
       
        [newBanArray removeObject:self.user.objectId];
        [btn_sender setTitle:@" Ban user from contacting you" forState:UIControlStateNormal];
        [btn_sender setImage:[[UIImage imageNamed:@"banIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Ban_Off object:nil];

    } else {
        
        [newBanArray addObject:self.user.objectId];
        [btn_sender setTitle:@"  Unblock the user from contacting you" forState:UIControlStateNormal];
        [btn_sender setImage:[[UIImage imageNamed:@"unban_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Ban_On object:nil];

    }
    
    [PFUser currentUser][PF_USER_BANS] = newBanArray;
    [[PFUser currentUser] saveInBackground];
    
}
- (void)btnFlagClicked:(id) sender {
    [self hidePopup];

    [self.view addSubview:flagView];
    [UIView animateWithDuration:0.3 animations:^{
        flagView.top = 60;
    }];
    
//    IQFeedbackView *feedback = [[IQFeedbackView alloc] initWithTitle:@"Report" message:nil image:nil cancelButtonTitle:@"Cancel" doneButtonTitle:@"Send"];
//    [feedback setCanAddImage:NO];
//    [feedback setCanEditText:YES];
//    
//    [feedback showInViewController:self completionHandler:^(BOOL isCancel, NSString *message, UIImage *image) {
//        [feedback dismiss];
//        if(!isCancel && ![message isEqualToString:@""]) {
//            
//            PFObject *object = [PFObject objectWithClassName:PF_FLAG_CLASS];
//            object[PF_FLAG_REASON] = message;
//            if([PFUser currentUser][PF_USER_EMAIL])
//                object[PF_FLAG_USER] = [PFUser currentUser][PF_USER_EMAIL];
//            if(self.user[PF_USER_EMAIL])
//                object[PF_FLAG_REPORTER] = self.user[PF_USER_EMAIL];
//            object[PF_FLAG_TIME] = [NSDate date];
//            [object saveInBackground];
//
//        }
//    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SHViewPagerDataSource stack

- (NSInteger)numberOfPagesInViewPager:(SHViewPager *)viewPager
{
    return menuItems.count;
}

- (UIViewController *)containerControllerForViewPager:(SHViewPager *)viewPager
{
    return self;
}

- (UIViewController *)viewPager:(SHViewPager *)viewPager controllerForPageAtIndex:(NSInteger)index
{
    if(index == 0) {
        
        FriendProfileViewController *friendProfileViewCtrl = [[FriendProfileViewController alloc] init];
        friendProfileViewCtrl.user = self.user;
        friendProfileViewCtrl.type = self.type;
        friendProfileViewCtrl.date = self.date;
        
        return friendProfileViewCtrl;
        
    } else {
        FriendProfilePersonalityViewController *friendPersonalViewCtrl = [[FriendProfilePersonalityViewController alloc] init];
        friendPersonalViewCtrl.user = self.user;
        return friendPersonalViewCtrl;
    }
}

- (UIImage *)indexIndicatorImageForViewPager:(SHViewPager *)viewPager
{
    return [UIImage imageNamed:@"horizontal_line.png"];
}

- (UIImage *)indexIndicatorImageDuringScrollAnimationForViewPager:(SHViewPager *)viewPager
{
    return [UIImage imageNamed:@"horizontal_line_moving.png"];
}

- (NSString *)viewPager:(SHViewPager *)viewPager titleForPageMenuAtIndex:(NSInteger)index
{
    return [menuItems objectAtIndex:index];
}

- (SHViewPagerMenuWidthType)menuWidthTypeInViewPager:(SHViewPager *)viewPager
{
    return SHViewPagerMenuWidthTypeDefault;
}

#pragma mark - SHViewPagerDelegate stack
- (void)firstContentPageLoadedForViewPager:(SHViewPager *)viewPager
{
    NSLog(@"first viewcontroller content loaded");
}

- (void)viewPager:(SHViewPager *)viewPager willMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"content will move to page %ld from page: %ld", (long)toIndex, (long)fromIndex);
}

- (void)viewPager:(SHViewPager *)viewPager didMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"content moved to page %ld from page: %ld", (long)toIndex, (long)fromIndex);
}

#pragma mark -
#pragma mark UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.3 animations:^{
        flagView.centerY = self.view.centerY-250;
    }];
}

@end
