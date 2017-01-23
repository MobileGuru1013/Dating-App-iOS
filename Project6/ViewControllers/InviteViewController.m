//
//  InviteViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "InviteViewController.h"
#import <AddressBook/AddressBook.h>
#import "THContact.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "AppConstant.h"
#import "AppDelegate.h"

UIBarButtonItem *barButton;

@interface InviteViewController ()<MFMessageComposeViewControllerDelegate>
{
    int todayMaxInvite;
    int duplicateInvite;
    NSArray *sentsArray;
    
    UILabel *lblInviteDes;
}
@property (nonatomic, assign) ABAddressBookRef addressBookRef;

@end

#define kKeyboardHeight 0.0

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Invite";
    CFErrorRef error;
    _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);

    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    barButton.enabled = FALSE;

    duplicateInvite = 0;
    sentsArray = [NSArray array];
    
    self.navigationItem.rightBarButtonItem = barButton;
    
    DataManager *dm = [DataManager SharedDataManager];
    if([dm defaultUserObjectForKey:@"inviteSent"]) {
        
        NSDate *date = [dm defaultUserObjectForKey:@"inviteSent"];
        int days = (int)[[NSDate date] daysAfterDate:date];
        if(abs(days) > 0) {
            todayMaxInvite = 5;
        }
        else {
            todayMaxInvite = 5 - [[dm defaultUserObjectForKey:@"inviteSentCount"] intValue];
        }
        
    } else {
        todayMaxInvite = 5;

    }
    
    PFQuery *query = [PFQuery queryWithClassName:PF_FREEKRONE_CLASS];
    [query whereKey:@"createdAt" greaterThan:[[NSDate date] dateAtStartOfDay]];
    [query whereKey:@"createdAt" lessThan:[[NSDate date] dateAtEndOfDay]];
    [query whereKey:PF_FREEKRONE_OWNER equalTo:[PFUser currentUser]];
    [query whereKey:PF_FREEKRONE_TYPE equalTo:@"invite"];
    
    lblInviteDes = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
    lblInviteDes.textAlignment = NSTextAlignmentCenter;
    lblInviteDes.font = [UIFont systemFontOfSize:16];
    
    lblInviteDes.backgroundColor = COLOR_MENU;
    lblInviteDes.textColor = [UIColor whiteColor];
    
    [self.view addSubview:lblInviteDes];

    [[KIProgressViewManager manager] showProgressOnView:self.view];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(!error) {
            todayMaxInvite = 5 - number;
            if(todayMaxInvite == 0) {
                lblInviteDes.text = [NSString stringWithFormat:@"You are able to send invites tomorrow"];
            } else {
                lblInviteDes.text = [NSString stringWithFormat:@"You can still send %d invites today",todayMaxInvite];
            }
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
    
    
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, 100)];
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderString:@"Type contact name"];
    self.contactPickerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.contactPickerView.bottom, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight-40) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"THContactPickerTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
    
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
        }
    });

    // Do any additional setup after loading the view.
}



-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            contact.phone = [self getMobilePhoneProperty:phonesRef];
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            // Get Email
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
                // NSLog(@"All emails are:%@", contactEmails);
                
            }
            if(contactEmails.count == 0)
                contact.email = @"";
            else
                contact.email = [contactEmails firstObject];
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
            }
            
            [mutableContacts addObject:contact];
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        self.contacts = [NSArray arrayWithArray:mutableContacts];
        self.selectedContacts = [NSMutableArray array];
        self.filteredContacts = self.contacts;
        
        [self.tableView reloadData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}

- (void) refreshContacts
{
    for (THContact* contact in self.contacts)
    {
        [self refreshContact: contact];
    }
    [self.tableView reloadData];
}

- (void) refreshContact:(THContact*)contact
{
    
    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
    contact.recordId = ABRecordGetRecordID(contactPerson);
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    // Set Contact properties
    contact.firstName = firstName;
    contact.lastName = lastName;
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    contact.phone = [self getMobilePhoneProperty:phonesRef];
    if(phonesRef) {
        CFRelease(phonesRef);
    }
    
    // Get image if it exists
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
    contact.image = [UIImage imageWithData:imgData];
    if (!contact.image) {
        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
    }
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContacts];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 40;
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        topOffset = 40;
    }
    CGRect frame = self.contactPickerView.frame;
    frame.origin.y = topOffset;
    self.contactPickerView.frame = frame;
    [self adjustTableViewFrame:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adjustTableViewFrame:(BOOL)animated {
    CGRect frame = self.tableView.frame;
    // This places the table view right under the text field
    frame.origin.y = self.contactPickerView.bottom;
    // Calculate the remaining distance
    frame.size.height = self.view.frame.size.height - self.contactPickerView.frame.size.height - kKeyboardHeight;
    
    if(animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.tableView.frame = frame;
        
        [UIView commitAnimations];
    }
    else{
        self.tableView.frame = frame;
    }
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the desired contact from the filteredContacts array
    THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
    
    // Initialize the table view cell
    NSString *cellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

    // Get the UI elements in the cell;
    UILabel *contactNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *mobilePhoneNumberLabel = (UILabel *)[cell viewWithTag:102];
    UIImageView *contactImage = (UIImageView *)[cell viewWithTag:103];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    
    // Assign values to to US elements
    contactNameLabel.text = [contact fullName];
    mobilePhoneNumberLabel.text = contact.phone;
    if(contact.image) {
        contactImage.image = contact.image;
    }
    contactImage.layer.masksToBounds = YES;
    contactImage.layer.cornerRadius = 20;
    
    // Set the checked state for the contact selection checkbox
    UIImage *image;
    if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    } else {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    }
    checkboxImageView.image = image;
    
    // Assign a UIButton to the accessoryView cell property
//    cell.accessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    // Set a target and selector for the accessoryView UIControlEventTouchUpInside
//    [(UIButton *)cell.accessoryView addTarget:self action:@selector(viewContactDetail:) forControlEvents:UIControlEventTouchUpInside];
//    cell.accessoryView.tag = contact.recordId; //so we know which ABRecord in the IBAction method
    
    // // For custom accessory view button use this.
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    //    button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
    //
    //    [button setTitle:@"Expand"
    //            forState:UIControlStateNormal];
    //
    //    [button addTarget:self
    //               action:@selector(viewContactDetail:)
    //     forControlEvents:UIControlEventTouchUpInside];
    //
    //    cell.accessoryView = button;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide Keyboard
    
    [self.contactPickerView resignKeyboard];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // This uses the custom cellView
    // Set the custom imageView
    THContact *user = [self.filteredContacts objectAtIndex:indexPath.row];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        [self.contactPickerView removeContact:user];
        // Set checkbox to "unselected"
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
        checkboxImageView.image = image;

    } else {
        // Contact has not been selected, add it to THContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        if(self.selectedContacts.count > (todayMaxInvite-1)) {
            
            
            
        } else {
            
            if(user.phone) {
                [self.selectedContacts addObject:user];
                [self.contactPickerView addContact:user withName:user.fullName];
                // Set checkbox to "selected"
                image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
                checkboxImageView.image = image;
                
            }
            

        }
    }
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Update window title
    self.title = [NSString stringWithFormat:@"Invite (%lu)", (unsigned long)self.selectedContacts.count];
    
    
    // Set checkbox image
    // Reset the filtered contacts
    self.filteredContacts = self.contacts;
    // Refresh the tableview
    [self.tableView reloadData];
}
#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", @"firstName", textViewText, @"lastName", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewFrame:YES];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    
    NSUInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Set unchecked image
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    checkboxImageView.image = image;
    
    // Update window title
    self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
}

- (void)removeAllContacts:(id)sender
{
    [self.contactPickerView removeAllContacts];
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}
#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

// This opens the apple contact details view: ABPersonViewController
//TODO: make a THContactPickerDetailViewController

- (IBAction)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);
    
    [self.navigationController pushViewController:view animated:YES];
}

// TODO: send contact object
- (void)done:(id)sender
{
    NSMutableArray *emailList = [NSMutableArray array];
    for(THContact *contact in self.selectedContacts) {
        if(![contact.phone isEqualToString:@""])
            [emailList addObject:contact.phone];
    }
    if(emailList.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Phone was not found in selected contacts" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];

    } else {
        [self sendMail:emailList];
    }
    
}
- (void)sendMail:(NSArray *)users
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    duplicateInvite = 0;
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *messageCompose = [[MFMessageComposeViewController alloc] init];
        
        PFQuery *query = [PFQuery queryWithClassName:PF_FREEKRONE_CLASS];
        [query whereKey:@"createdAt" greaterThan:[[NSDate date] dateAtStartOfDay]];
        [query whereKey:@"createdAt" lessThan:[[NSDate date] dateAtEndOfDay]];
        [query whereKey:PF_FREEKRONE_OWNER equalTo:[PFUser currentUser]];
        [query whereKey:PF_FREEKRONE_TYPE equalTo:@"invite"];
        
        [[KIProgressViewManager manager] showProgressOnView:self.view];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                NSMutableArray *invites = [NSMutableArray array];
                for(PFObject *object in objects) {
                    NSString *phoneNumber = [object objectForKey:PF_FREEKRONE_CONTENT];
                    [invites addObject:phoneNumber];
                }
                
                NSMutableArray *realUsers = [NSMutableArray array];
                for(NSString *phone in users) {
                    if(![invites containsObject:phone]) {
                        [realUsers addObject:phone];
                    } else {
                        duplicateInvite++;
                    }
                }
                
                messageCompose.recipients = realUsers;
                sentsArray = realUsers;
                messageCompose.body = MESSAGE_INVITE;
                messageCompose.messageComposeDelegate = self;
                [self presentViewController:messageCompose animated:YES completion:nil];

            }
            [[KIProgressViewManager manager] hideProgressView];
        }];
        
//        DataManager *dm = [DataManager SharedDataManager];
//        NSArray *invites = [dm getResultsWithEntity:@"InviteSents" sortDescriptor:@"phone" batchSize:300];
//        NSMutableArray *realUsers = [NSMutableArray array];
//        for(NSString *phone in users) {
//            if(![invites containsObject:phone]) {
//                [realUsers addObject:phone];
//            } else {
//                duplicateInvite++;
//            }
//        }
//
//        messageCompose.recipients = realUsers;
//        sentsArray = realUsers;
//        messageCompose.body = MESSAGE_INVITE;
//        messageCompose.messageComposeDelegate = self;
//        [self presentViewController:messageCompose animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Please configure your iMessage first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

    if (result == MFMailComposeResultSent)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Mail sent successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
    
    int currentVal = [[PFUser currentUser][PF_USER_CRONES] intValue];
    currentVal = currentVal + 5*(int)(sentsArray.count);
    if(currentVal>=0) {
        [PFUser currentUser][PF_USER_CRONES] = [NSNumber numberWithInt:currentVal];
        [[PFUser currentUser] saveInBackground];
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

//-------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (result == MessageComposeResultSent)
    {
        NSString *alertContent;
        if(duplicateInvite == 0)
        {
            alertContent = @"SMS sent successfully.";
        } else {
            alertContent = [NSString stringWithFormat:@"Some contacts have already received invites from you before.%d invites were not sent.",duplicateInvite];
        }

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:alertContent delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        int currentVal = [[PFUser currentUser][PF_USER_CRONES] intValue];
        currentVal = currentVal + 5*((int)sentsArray.count);
        if(currentVal>=0) {
            [PFUser currentUser][PF_USER_CRONES] = [NSNumber numberWithInt:currentVal];
            [[PFUser currentUser] saveInBackground];
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
        }
        
        DataManager *dm = [DataManager SharedDataManager];
        for(NSString *sent in sentsArray) {
            NSManagedObject *obj = [dm newObjectForEntityForName:@"InviteSents"];
            [obj setValue:sent forKey:@"phone"];
            [obj didSave];
            
            PFObject *object = [PFObject objectWithClassName:PF_FREEKRONE_CLASS];
            object[PF_FREEKRONE_OWNER] = [PFUser currentUser];
            object[PF_FREEKRONE_TYPE] = @"invite";
            object[PF_FREEKRONE_CONTENT] = sent;
            [object saveInBackground];
        }
        
        [dm setDefaultUserObject:[NSDate date] forKey:@"inviteSent"];
        [dm setDefaultUserObject:[NSNumber numberWithInteger:(sentsArray.count)] forKey:@"inviteSentCount"];
        [dm update];

        todayMaxInvite = todayMaxInvite - (int)sentsArray.count;
        if(todayMaxInvite == 0) {
            lblInviteDes.text = [NSString stringWithFormat:@"You are able to send invites tomorrow"];
        } else {
            lblInviteDes.text = [NSString stringWithFormat:@"You can still send %d invites today",todayMaxInvite];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
