//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <MediaPlayer/MediaPlayer.h>

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "IDMPhotoBrowser.h"
#import "RNGridMenu.h"

#import "AppConstant.h"
#import "camera.h"
#import "common.h"
#import "image.h"
#import "push.h"
#import "recent.h"
#import "video.h"

#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"

#import "ChatView.h"

#import "Public.h"
#import "IQFeedbackView.h"
#import "RootFriendProfileViewController.h"

#define COLOR_CHAT_RED [UIColor colorWithRed:234.0/255.0 green:111.0/255.0 blue:112.0/255.0 alpha:1.0]

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSTimer *timer;
	BOOL isLoading;
	BOOL initialized;

	NSString *groupId;

	NSMutableArray *users;
	NSMutableArray *messages;
	NSMutableDictionary *avatars;

	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;
	JSQMessagesAvatarImage *avatarImageBlank;
    
    UIView *popupView;
    
    UIView* flagView;
    UITextView *comment_view;

    UIView* oppView;
    UILabel *opp_des_lbl;
    UIImageView *clock_markView;
    UILabel *timer_lbl;
    
    NSDate *date_elapsed;
    
    NSArray *recentArray;
    
    CGRect originRect;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
    groupId = groupId_;
	return self;
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
    
//    [self hidePopup];
//    NSArray *banArray = [PFUser currentUser][PF_USER_BANS];
//    if(!banArray)
//        banArray = [NSArray array];
//    NSMutableArray *newBanArray = [NSMutableArray arrayWithArray:banArray];
//    [newBanArray addObject:self.oppUser.objectId];
//    [PFUser currentUser][PF_USER_BANS] = newBanArray;
//    [[PFUser currentUser] saveInBackground];
//    
//    UIButton *btn_sender = (UIButton*)sender;
    
    UIButton *btn_sender = (UIButton*)sender;

    [self hidePopup];
    
    NSArray *banArray = [PFUser currentUser][PF_USER_BANS];
    
    NSLog(@"banArray ==== %@",banArray);
    NSLog(@"banArray ==== %lu",(unsigned long)banArray.count);
    
    if(!banArray)
        banArray = [NSArray array];
    NSMutableArray *newBanArray = [NSMutableArray arrayWithArray:banArray];
    
    if([newBanArray containsObject:self.oppUser.objectId]) {
        [newBanArray removeObject:self.oppUser.objectId];
        
        [btn_sender setTitle:@" Ban user from contacting you" forState:UIControlStateNormal];
        [btn_sender setImage:[[UIImage imageNamed:@"banIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Ban_Off object:nil];
        
    } else {
        [newBanArray addObject:self.oppUser.objectId];
        
        NSLog(@"oppUser === %@",self.oppUser.objectId);
        
        [btn_sender setTitle:@"  Unblock the user from contacting you" forState:UIControlStateNormal];
        [btn_sender setImage:[[UIImage imageNamed:@"unban_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_Ban_On object:nil];
    }
    
    NSLog(@"newBanArray === %@",newBanArray);
    
    [PFUser currentUser][PF_USER_BANS] = newBanArray;
    [[PFUser currentUser] saveInBackground];

}
- (void)btnFlagClicked:(id) sender {
    
    [self hidePopup];
    
    [self.view addSubview:flagView];
    [UIView animateWithDuration:0.3 animations:^{
        flagView.top = 60;
    }];

    
//    [self hidePopup];
//    
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
//            if(self.oppUser[PF_USER_EMAIL])
//                object[PF_FLAG_REPORTER] = self.oppUser[PF_USER_EMAIL];
//            object[PF_FLAG_TIME] = [NSDate date];
//            [object saveInBackground];
//            
//        }
//    }];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
    
    recentArray = nil;
    
    UIBarButtonItem *item_down = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"downArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(itemBanClicked:)];
    self.navigationItem.rightBarButtonItem = item_down;
    
    popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pubWidth, 80)];
    UIButton *btnBan = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, pubWidth, 40)];
    
    date_elapsed = nil;
    
    NSArray *banArray = [PFUser currentUser][PF_USER_BANS];
    
    if(!banArray)
        banArray = [NSArray array];
    
    if([banArray containsObject:self.oppUser.objectId]) {
        
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
    
    UIButton *btnFlag = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, pubWidth, 40)];
    [btnFlag setTitle:@" Flag user for inappropriate content" forState:UIControlStateNormal];
    [btnFlag setBackgroundColor:COLOR_MENU];
    [btnFlag.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnFlag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnFlag setTintColor:[UIColor whiteColor]];
    [btnFlag setImage:[[UIImage imageNamed:@"flagIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [btnFlag setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [btnFlag addTarget:self action:@selector(btnFlagClicked:) forControlEvents:UIControlEventTouchUpInside];
    [popupView addSubview:btnFlag];
    
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, pubWidth-60, 1)];
    lineImageView.backgroundColor = [UIColor darkGrayColor];
    lineImageView.centerY = 40;
    [popupView addSubview:lineImageView];
    
    popupView.bottom = 0;

    
	self.title = self.oppUser[PF_USER_FULLNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	self.senderId = user.objectId;
	self.senderDisplayName = user[PF_USER_FULLNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:COLOR_OUTGOING];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:COLOR_INCOMING];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	isLoading = NO;
	initialized = NO;
	[self loadMessages];
    
    //Flag View
    flagView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, pubWidth-40, 450)];
    flagView.backgroundColor = COLOR_MENU;
    
    UILabel *lbl_flag = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, flagView.width-20, 50)];
    lbl_flag.textAlignment = NSTextAlignmentLeft;
    lbl_flag.font = [UIFont systemFontOfSize:18];
    lbl_flag.textColor = [UIColor whiteColor];
    lbl_flag.text = [NSString stringWithFormat:@"Please let us know why you are flagging [%@]?",self.oppUser[PF_USER_FULLNAME]];
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
    comment_view.tag = 120;
    
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

    //Opponent Description View
    oppView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pubWidth, 80)];
    oppView.backgroundColor = COLOR_MENU;
    
    UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    photoView.clipsToBounds = YES;
    photoView.contentMode = UIViewContentModeScaleToFill;
    photoView.layer.masksToBounds = YES;
    photoView.layer.cornerRadius = 40;
    photoView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap_ges_photo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhotoClicked)];
    [photoView addGestureRecognizer:tap_ges_photo];
    
    if(self.oppUser[PF_USER_THUMBNAIL]) {
        PFFile *profileImage = self.oppUser[PF_USER_THUMBNAIL];
        [profileImage getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            UIImage *thumbnailImage = [UIImage imageWithData:imageData];
            photoView.image = thumbnailImage;
        }];
        
    } else {
        [photoView setImageWithURL:[NSURL URLWithString:self.oppUser[PF_USER_PICTURE]] placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    }

    [oppView addSubview:photoView];
    oppView.clipsToBounds = NO;

    opp_des_lbl = [[UILabel alloc] initWithFrame:CGRectMake(photoView.right+10, 10, pubWidth-photoView.width-30, 40)];
    opp_des_lbl.font = [UIFont systemFontOfSize:14];
    opp_des_lbl.textColor = [UIColor whiteColor];
    opp_des_lbl.text = @"";
    opp_des_lbl.numberOfLines = 2;
    [oppView addSubview:opp_des_lbl];
    
    originRect = opp_des_lbl.frame;
    
    clock_markView = [[UIImageView alloc] init];
    clock_markView.top = opp_des_lbl.bottom+3;
    clock_markView.left = photoView.right+10;
    clock_markView.width = 20;
    clock_markView.height = 20;
    [clock_markView setTintColor:[UIColor whiteColor]];
    [oppView addSubview:clock_markView];

    timer_lbl = [[UILabel alloc] initWithFrame:CGRectZero];
    timer_lbl.font = [UIFont boldSystemFontOfSize:14];
    timer_lbl.textColor = [UIColor whiteColor];
    timer_lbl.left = clock_markView.right+5;
    timer_lbl.top = clock_markView.top;
    timer_lbl.width = 200;
    timer_lbl.height = 20;
    timer_lbl.text = @"--:--:--";
    [oppView addSubview:timer_lbl];
    
    [self.view addSubview:oppView];
    
    oppView.transform = CGAffineTransformMakeTranslation(0, -90);
    
    //load recent query
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_GROUPID equalTo:groupId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            if(objects.count != 0)
                recentArray = objects;
            else
                recentArray = nil;
        }
    }];
}
- (void)tapPhotoClicked {
    
    RootFriendProfileViewController *rootFriendProfileViewCtrl = [[RootFriendProfileViewController alloc] init];
    rootFriendProfileViewCtrl.user = self.oppUser;
    rootFriendProfileViewCtrl.type = 9;
    [self.navigationController pushViewController:rootFriendProfileViewCtrl animated:YES];
    
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
        if(self.oppUser[PF_USER_EMAIL])
            object[PF_FLAG_REPORTER] = self.oppUser[PF_USER_EMAIL];
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
//------------------------------------

- (void)viewDidLayoutSubviews
{
    self.collectionView.top = 80;
    self.collectionView.height = self.view.height-80;
    
    [self.view layoutSubviews];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerRefresh) name:Notification_Timer_Refresh object:nil];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	ClearRecentCounter(groupId);
	[timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Timer_Refresh object:nil];

}

#pragma mark - Backend methods

- (void)timerRefresh {
    
    if([self checkMatched] ==0) {
        NSLog(@"No Chats At All");
        
    } else if([self checkMatched] == 1) {
        NSLog(@"Matched");
        for(PFObject *object in recentArray) {
            if(object[@"expire_type"]) {
                if(![object[@"expire_type"] isEqualToString:@"1"]) {
                    object[@"expire_type"] = @"1";
                    [object saveInBackground];
                }
            } else {
                object[@"expire_type"] = @"1";
                [object saveInBackground];
            }
        }
        
    } else if([self checkMatched] == 2) {
        NSLog(@"I am only chat");
        
        for(PFObject *object in recentArray) {
            if(object[@"expire_type"]) {
                if(![object[@"expire_type"] isEqualToString:@"2"]) {
                    object[@"expire_type"] = @"2";
                    [object saveInBackground];
                }
            } else {
                object[@"expire_type"] = @"2";
                [object saveInBackground];
            }
        }

        if(date_elapsed) {
            NSDate *tdate = [date_elapsed dateByAddingHours:24];
            NSDate *today = [NSDate date];
            int seconds = (int)[tdate secondsAfterDate:today];
            
            if(seconds>0) {
                timer_lbl.text = [NSString stringWithFormat:@"%02d:%02d:%02d",seconds/(3600),(seconds%3600)/60,seconds%60];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
                timer_lbl.text = @"--:--:--";
            }
        }
        
    } else if([self checkMatched] == 3) {
        NSLog(@"opp only chat");
        
        for(PFObject *object in recentArray) {
            if(object[@"expire_type"]) {
                if(![object[@"expire_type"] isEqualToString:@"3"]) {
                    object[@"expire_type"] = @"3";
                    [object saveInBackground];
                }
            } else {
                object[@"expire_type"] = @"3";
                [object saveInBackground];
            }
        }
        
        if(date_elapsed) {
            NSDate *tdate = [date_elapsed dateByAddingHours:24];
            NSDate *today = [NSDate date];
            int seconds = (int)[tdate secondsAfterDate:today];
            
            if(seconds>0) {
                timer_lbl.text = [NSString stringWithFormat:@"%02d:%02d:%02d",seconds/(3600),(seconds%3600)/60,seconds%60];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
                timer_lbl.text = @"--:--:--";
            }
        }
    }
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (isLoading == NO)
	{
		isLoading = YES;
		JSQMessage *message_last = [messages lastObject];

		PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
		[query whereKey:PF_MESSAGE_GROUPID equalTo:groupId];
		if (message_last != nil) [query whereKey:PF_MESSAGE_CREATEDAT greaterThan:message_last.date];
		[query includeKey:PF_MESSAGE_USER];
		[query orderByDescending:PF_MESSAGE_CREATEDAT];
		[query setLimit:50];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				BOOL incoming = NO;
				self.automaticallyScrollsToMostRecentMessage = NO;
				for (PFObject *object in [objects reverseObjectEnumerator])
				{
					JSQMessage *message = [self addMessage:object];
                    date_elapsed = message.date;
					if ([self incoming:message]) incoming = YES;
				}
				if ([objects count] != 0)
				{
					if (initialized && incoming)
						[JSQSystemSoundPlayer jsq_playMessageReceivedSound];
					[self finishReceivingMessage];
					[self scrollToBottomAnimated:NO];
				}
				self.automaticallyScrollsToMostRecentMessage = YES;
				initialized = YES;
			}
			else [ProgressHUD showError:@"Network error."];
			isLoading = NO;

            /*
             
             UILabel *opp_des_lbl;
             UIImageView *clock_markView;
             UILabel *timer_lbl;
             
             */
            //added by Michal 7/7
            
            if([self checkMatched] == 0)
            {
                CGRect rect = originRect;
                
                rect.size.height += 25;
                opp_des_lbl.frame = rect;
                opp_des_lbl.numberOfLines = 3;
                
            }
            else
            {
                opp_des_lbl.frame = originRect;
                opp_des_lbl.numberOfLines = 2;
            }
            
            //

            
            if([self checkMatched] ==0) {
                NSLog(@"No Chats At All");

                [UIView animateWithDuration:0.2 animations:^{
                    oppView.transform = CGAffineTransformIdentity;
                }];
                
                clock_markView.image = nil;
                timer_lbl.text = @"";
                opp_des_lbl.text = [NSString stringWithFormat:@"Once you send the message,%@ will have 24 hours to respond to you or the message will self-destruct",self.oppUser[PF_USER_FULLNAME]];
                if(message_last)
                    date_elapsed = message_last.date;
                
            } else if([self checkMatched] == 1) {
                [UIView animateWithDuration:0.2 animations:^{
                    oppView.transform = CGAffineTransformIdentity;
                }];
                NSLog(@"Matched");
                clock_markView.image = [[UIImage imageNamed:@"love_like.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [clock_markView setTintColor:COLOR_CHAT_RED];
                timer_lbl.textColor = COLOR_CHAT_RED;
                timer_lbl.text = @"Matched";
                
                opp_des_lbl.text = [NSString stringWithFormat:@"%@\n%d | %@ | %@",self.oppUser[PF_USER_FULLNAME],(int)[NSDate age:self.oppUser[PF_USER_BIRTHDAY]],[[self.oppUser[PF_USER_GENDER] substringToIndex:1] uppercaseString],self.oppUser[PF_USER_ZIPCODE]];
                if(message_last)
                    date_elapsed = message_last.date;
                
            } else if([self checkMatched] == 2) {
                NSLog(@"I am only chat");
                [UIView animateWithDuration:0.2 animations:^{
                    oppView.transform = CGAffineTransformIdentity;
                }];
                opp_des_lbl.text = [NSString stringWithFormat:@"This message thread will self-destruct if %@ does not respond in:",self.oppUser[PF_USER_FULLNAME]];
                clock_markView.image = [[UIImage imageNamed:@"clock_mark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [clock_markView setTintColor:[UIColor whiteColor]];
//                timer_lbl.text = message_last.date;
                NSLog(@"%@",message_last.date);
                if(message_last)
                    date_elapsed = message_last.date;
                
            } else if([self checkMatched] == 3) {
                NSLog(@"opp only chat");
                [UIView animateWithDuration:0.2 animations:^{
                    oppView.transform = CGAffineTransformIdentity;
                }];
                opp_des_lbl.text = [NSString stringWithFormat:@"This message thread will self-destruct if you do not respond in:"];
                clock_markView.image = [[UIImage imageNamed:@"clock_mark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [clock_markView setTintColor:[UIColor whiteColor]];
//                timer_lbl.text = message_last.date;
                if(message_last)
                    date_elapsed = message_last.date;
                NSLog(@"%@",message_last.date);
            }
            
		}];
	}
}

- (int) checkMatched {
    if(users.count == 0) {
    
        return 0;
    
    } else {
        BOOL isMe = NO;
        BOOL isYou = NO;
        for(int i=0; i<users.count; i++) {
            PFObject *object = [users objectAtIndex:i];
            if([object.objectId isEqualToString:[PFUser currentUser].objectId])
            {
                isMe = YES;
            } else {
                isYou = YES;
            }
        }
        if(isMe && isYou) {
            return 1;
        } else if(isMe) {
            return 2;
        } else if(isYou) {
            return 3;
        }
    }
    
    return 0;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)addMessage:(PFObject *)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = object[PF_MESSAGE_USER];
	NSString *name = user[PF_USER_FULLNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *fileVideo = object[PF_MESSAGE_VIDEO];
	PFFile *filePicture = object[PF_MESSAGE_PICTURE];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((filePicture == nil) && (fileVideo == nil))
	{
		message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_MESSAGE_TEXT]];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (fileVideo != nil)
	{
		JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
		mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
		message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (filePicture != nil)
	{
		JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
		mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
		message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
		{
			if (error == nil)
			{
				mediaItem.image = [UIImage imageWithData:imageData];
				[self.collectionView reloadData];
			}
		}];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[users addObject:user];
	[messages addObject:message];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAvatar:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFFile *file = user[PF_USER_THUMBNAIL];
	[file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
	{
		if (error == nil)
		{
			avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
			[self.collectionView reloadData];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFFile *fileVideo = nil;
	PFFile *filePicture = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (video != nil)
	{
		text = @"[Video message]";
		fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
		[fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) [ProgressHUD showError:@"Network error."];
		}];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (picture != nil)
	{
		text = @"[Picture message]";
		filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
		[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error != nil) [ProgressHUD showError:@"Picture save error."];
		}];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFObject *object = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
	object[PF_MESSAGE_USER] = [PFUser currentUser];
	object[PF_MESSAGE_GROUPID] = groupId;
	object[PF_MESSAGE_TEXT] = text;
	if (fileVideo != nil) object[PF_MESSAGE_VIDEO] = fileVideo;
	if (filePicture != nil) object[PF_MESSAGE_PICTURE] = filePicture;
	[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			[JSQSystemSoundPlayer jsq_playMessageSentSound];
			[self loadMessages];
		}
		else [ProgressHUD showError:@"Network error."];;
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SendPushNotification(groupId, text);
	UpdateRecentCounter(groupId, 1, text);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self finishSendingMessage];

}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    NSArray *banArray = self.oppUser[PF_USER_BANS];
    if(!banArray)
        banArray = [NSArray array];
    
    if([banArray containsObject:[PFUser currentUser].objectId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You are banned! Cannot find the user!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    } else {
        [self sendMessage:text Video:nil Picture:nil];
    }
    
    self.collectionView.top = 80;
    self.collectionView.height = self.view.height-80;
    
    [self.view layoutSubviews];

    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
	NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_camera"] title:@"Camera"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_audio"] title:@"Audio"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_pictures"] title:@"Pictures"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_videos"] title:@"Videos"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_location"] title:@"Location"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_stickers"] title:@"Stickers"]];
	RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
	gridMenu.delegate = self;
	[gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return messages[indexPath.item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		return bubbleImageOutgoing;
	}
	else return bubbleImageIncoming;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = users[indexPath.item];
	if (avatars[user.objectId] == nil)
	{
		[self loadAvatar:user];
		return avatarImageBlank;
	}
	else return avatars[user.objectId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = messages[indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return nil;
			}
		}
		return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

	if ([self outgoing:messages[indexPath.item]])
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	else
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return 0;
			}
		}
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
        
        RootFriendProfileViewController *rootFriendProfileViewCtrl = [[RootFriendProfileViewController alloc] init];
        rootFriendProfileViewCtrl.user = self.oppUser;
        rootFriendProfileViewCtrl.type = 9;
        [self.navigationController pushViewController:rootFriendProfileViewCtrl animated:YES];

	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if (message.isMediaMessage)
	{
		if ([message.media isKindOfClass:[JSQPhotoMediaItem class]])
		{
			JSQPhotoMediaItem *mediaItem = (JSQPhotoMediaItem *)message.media;
			NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
			IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
			[self presentViewController:browser animated:YES completion:nil];
		}
		if ([message.media isKindOfClass:[JSQVideoMediaItem class]])
		{
			JSQVideoMediaItem *mediaItem = (JSQVideoMediaItem *)message.media;
			MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
			[self presentMoviePlayerViewControllerAnimated:moviePlayer];
			[moviePlayer.moviePlayer play];
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - RNGridMenuDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[gridMenu dismissAnimated:NO];
	if ([item.title isEqualToString:@"Camera"])		PresentMultiCamera(self, YES);
	if ([item.title isEqualToString:@"Audio"])		PresentPremium(self);
	if ([item.title isEqualToString:@"Pictures"])	PresentPhotoLibrary(self, YES);
	if ([item.title isEqualToString:@"Videos"])		PresentVideoLibrary(self, YES);
	if ([item.title isEqualToString:@"Location"])	PresentPremium(self);
	if ([item.title isEqualToString:@"Stickers"])	PresentPremium(self);
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSURL *video = info[UIImagePickerControllerMediaURL];
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self sendMessage:nil Video:video Picture:picture];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)incoming:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == NO);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)outgoing:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == YES);
}
#pragma mark -
#pragma mark UITextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if(textView.tag == 120) {
        [UIView animateWithDuration:0.3 animations:^{
            flagView.centerY = self.view.centerY-250;
        }];
        
    }
}

- (void)updateMessageType {
    
}

@end
