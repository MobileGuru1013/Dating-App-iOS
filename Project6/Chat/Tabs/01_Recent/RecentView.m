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

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "common.h"
#import "recent.h"

#import "RecentView.h"
#import "RecentCell.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "FacebookFriendsView.h"
#import "NavigationController.h"
#import "RESideMenu.h"
#import "Public.h"
#import "AppDelegate.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecentView()
{
	NSMutableArray *recents;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecentView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_recent"]];
		self.tabBarItem.title = @"Message";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Message";
	//---------------------------------------------------------------------------------------------------------------------------------------------
//	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self
//																						   action:@selector(actionCompose)];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(presentLeftMenuViewController:)];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerNib:[UINib nibWithNibName:@"RecentCell" bundle:nil] forCellReuseIdentifier:@"RecentCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadRecents) forControlEvents:UIControlEventValueChanged];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	recents = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadRecents];
        [self removeExpired];
	}
	else LoginUser(self);
}
- (void)removeExpired {
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query whereKey:PF_RECENT_LASTMESSAGE notEqualTo:@""];
    [query whereKey:@"expire_type" notEqualTo:@"1"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error) {
            for(PFObject *object in objects) {
            
                NSDate *date_update = object[@"updatedAction"];
                
                NSDate *tdate = [date_update dateByAddingHours:24];
                NSDate *today = [NSDate date];
                int seconds = (int)[tdate secondsAfterDate:today];
                if(seconds<0) {
                    
                    PFQuery *query_msg = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
                    [query_msg whereKey:PF_MESSAGE_GROUPID equalTo:object[PF_RECENT_GROUPID]];
                    [query_msg findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if(!error) {
                            [PFObject deleteAllInBackground:objects];
                        }
                    }];
                    
                    [object deleteInBackground];
                }
            }
            [self loadRecents];
        }
    }];
    
}
#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadRecents
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

	PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
	[query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query whereKey:PF_RECENT_LASTMESSAGE notEqualTo:@""];
    
	[query includeKey:PF_RECENT_LASTUSER];
    [query includeKey:PF_RECENT_USEROPP];
	[query orderByDescending:PF_RECENT_UPDATEDACTION];
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[recents removeAllObjects];
			[recents addObjectsFromArray:objects];
			[self.tableView reloadData];
			[self updateTabCounter];
		}
		else [ProgressHUD showError:@"Network error."];
		[self.refreshControl endRefreshing];
	}];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int total = 0;
	for (PFObject *recent in recents)
	{
		total += [recent[PF_RECENT_COUNTER] intValue];
	}
	UITabBarItem *item = self.tabBarController.tabBar.items[0];
	item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[recents removeAllObjects];
	[self.tableView reloadData];
	[self updateTabCounter];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCompose
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
			   otherButtonTitles:@"Single recipient", @"Multiple recipients", @"Address Book", @"Facebook Friends", nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (buttonIndex == 0)
		{
			SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
			selectSingleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 1)
		{
			SelectMultipleView *selectMultipleView = [[SelectMultipleView alloc] init];
			selectMultipleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectMultipleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 2)
		{
			AddressBookView *addressBookView = [[AddressBookView alloc] init];
			addressBookView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:addressBookView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 3)
		{
			FacebookFriendsView *facebookFriendsView = [[FacebookFriendsView alloc] init];
			facebookFriendsView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:facebookFriendsView];
			[self presentViewController:navController animated:YES completion:nil];
		}
	}
}

#pragma mark - SelectSingleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSingleUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

#pragma mark - SelectMultipleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMultipleUsers:(NSMutableArray *)users
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *groupId = StartMultipleChat(users);
	[self actionChat:groupId];
}

#pragma mark - AddressBookDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectAddressBookUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

#pragma mark - FacebookFriendsDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectFacebookUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [recents count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RecentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
	[cell bindData:recents[indexPath.row]];
	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFObject *recent = recents[indexPath.row];
	[recents removeObject:recent];
	[self updateTabCounter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[recent deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFObject *recent = recents[indexPath.row];
    
    ChatView *chatView = [[ChatView alloc] initWith:recent[PF_RECENT_GROUPID]];
    PFUser *user = recent[PF_RECENT_USEROPP];
    chatView.oppUser = user;
    if([user[PF_USER_BANS] containsObject:[PFUser currentUser].objectId]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You are banned! Cannot find the user!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        
        [recent deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded) {
                [self loadRecents];
            }
        }];

    } else {
        chatView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatView animated:YES];

    }
    
}

@end
