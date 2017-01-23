//
//  MatchesViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "MatchesViewController.h"
#import "KRLCollectionViewGridLayout.h"
#import "TimerView.h"
#import "MatchCollectionViewCell.h"
#import "RootFriendProfileViewController.h"
#import "MBFaker.h"
#import "MatchCollectionHeaderView.h"
#import "GlobalPool.h"
#import "AppDelegate.h"

#define IAP25  @"com.kenneth.project6.iap25"
#define IAP250 @"com.kenneth.project6.iap250"
#define IAP500 @"com.kenneth.project6.iap500"
#define IAP50  @"com.kenneth.project6.iap25"

@interface MatchesViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>
{
    UICollectionView *streamView;
    NSMutableArray *todayArray;
    
    TimerView *timerToday;
    
    UIView *moreMatchView;
    UIButton *btnUnLockMatches;
    
    NSMutableArray *madeMatches;
}
@end

@implementation MatchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[KIProgressViewManager manager] hideProgressView];

    madeMatches = [NSMutableArray array];
    
    self.title = @"Matches";
        
    timerToday = [[TimerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    timerToday.centerX = self.view.width/2-10;
    timerToday.centerY = 50;
    [timerToday setHeaderTitle:@"Today's Matches"];
    
    KRLCollectionViewGridLayout *layout = [[KRLCollectionViewGridLayout alloc] init];
    layout.numberOfItemsPerLine = 2;
    layout.aspectRatio = 0.6;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.interitemSpacing = 10;
    layout.lineSpacing = 10;
    layout.headerReferenceSize = CGSizeMake(self.view.width, 80);
    layout.footerReferenceSize = CGSizeMake(self.view.width, 120);
    
    streamView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64-50) collectionViewLayout:layout];
    streamView.delegate = self;
    streamView.dataSource = self;
    streamView.backgroundColor = [UIColor clearColor];

    [streamView registerClass:[MatchCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [streamView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [streamView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];

    moreMatchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width-20, 120)];
    moreMatchView.backgroundColor = COLOR_IN_GRAY;
    moreMatchView.layer.cornerRadius = 4;
    moreMatchView.layer.borderWidth = 3;
    moreMatchView.layer.borderColor = [COLOR_Border CGColor];
    
    UIImageView *markCrownView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 50, 50)];
    markCrownView.image = [UIImage imageNamed:@"crown2.png"];
    markCrownView.centerX = self.view.width/2-10;
    [moreMatchView addSubview:markCrownView];
    
    UILabel *lblDesMoreMatch = [[UILabel alloc] initWithFrame:CGRectMake(0, markCrownView.bottom, self.view.width-20, 20)];
    lblDesMoreMatch.backgroundColor = [UIColor clearColor];
    lblDesMoreMatch.textColor = COLOR_IN_DARK_GRAY;
    lblDesMoreMatch.textAlignment = NSTextAlignmentCenter;
    lblDesMoreMatch.text = [NSString stringWithFormat:@"Unlock 2 additional matches with %d Krones",[GlobalPool sharedInstance].kMoreMatchLimit];
    lblDesMoreMatch.font = [UIFont systemFontOfSize:16];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString: lblDesMoreMatch.attributedText];
        
    [text addAttribute:NSForegroundColorAttributeName
                 value:COLOR_Border
                 range:NSMakeRange(7, 1)];
    
    [text addAttribute:NSFontAttributeName
     
                 value:[UIFont boldSystemFontOfSize:18]
                 range:NSMakeRange(7, 1)];
    
    [text addAttribute:NSFontAttributeName
                 value:[UIFont boldSystemFontOfSize:18]
                 range:NSMakeRange(lblDesMoreMatch.text.length-9, 2)];
    
    [text addAttribute:NSForegroundColorAttributeName
                 value:COLOR_Border
                 range:NSMakeRange(lblDesMoreMatch.text.length-9, 2)];

    
    [lblDesMoreMatch setAttributedText: text];
    
    [moreMatchView addSubview:lblDesMoreMatch];
    
    btnUnLockMatches = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width/2-10-60, lblDesMoreMatch.bottom+5,120,30)];
    
    [btnUnLockMatches.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [btnUnLockMatches setTitle:@"Unlock" forState:UIControlStateNormal];
    [btnUnLockMatches addTarget:self action:@selector(btnMoreMatches) forControlEvents:UIControlEventTouchUpInside];
    [btnUnLockMatches.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [btnUnLockMatches setBackgroundColor:COLOR_BUTTON];
    [btnUnLockMatches.layer setCornerRadius:6.0];
    btnUnLockMatches.layer.masksToBounds = YES;
    
    btnUnLockMatches.enabled = NO;
    
    
    [moreMatchView addSubview:btnUnLockMatches];
    
    [self.view addSubview:streamView];
    
    [self loadUsers];
    //[self promptEnoughKrones];
    //Create Test Users and Questions
    //[self createUsers];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerRefresh) name:Notification_Timer_Refresh object:nil];
    [self timerRefresh];
    
    [streamView reloadData];    //add by Michal 7-7 For Ban refresh

    
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
    
    
}

- (void)promptEnoughKrones {
    
    int currentKrones = [[PFUser currentUser][PF_USER_CRONES] intValue];
    
    if(currentKrones<[GlobalPool sharedInstance].kUnlockLimit) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Oh no! You do not have enough Krone. Buy more Krone to unlock!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy 50 Krones for $0.99!", nil];
        [alertView show];
    }
}

- (void)btnMoreMatches {
    if([[GlobalPool sharedInstance] unLock:[GlobalPool sharedInstance].kMoreMatchLimit]) {
        
        [[KIProgressViewManager manager] showProgressOnView:self.view];
        
        PFUser *user = [PFUser currentUser];
        
        PFQuery *query = [PFUser query];
        [query whereKey:PF_USER_GENDER equalTo:user[PF_USER_L_GENDER]];
        [query whereKey:PF_USER_ACTIVATE notEqualTo:[NSNumber numberWithBool:NO]];
        
        NSDate *bottomDate = [[NSDate date] dateBySubtractingYears:[user[PF_USER_L_MAXAGE] intValue]];
        NSDate *topDate = [[NSDate date] dateBySubtractingYears:[user[PF_USER_L_MINAGE] intValue]];
        [query whereKey:PF_USER_BIRTHDAY  greaterThanOrEqualTo:bottomDate];
        [query whereKey:PF_USER_BIRTHDAY lessThan:topDate];
        [query whereKey:@"objectId" notContainedIn:madeMatches];
        
        NSString *userDistance = user[PF_USER_L_DISTANCE];
        userDistance = [userDistance stringByReplacingOccurrencesOfString:@" miles" withString:@""];
        [query whereKey:PF_USER_GEOLOCATION nearGeoPoint:user[PF_USER_GEOLOCATION] withinMiles:userDistance.intValue];
        
        NSArray *ethic_arr = user[PF_USER_ETHNICITY];
        NSArray *belief_arr = user[PF_USER_BELIEF];
        if(ethic_arr.count>0)
            [query whereKey:PF_USER_MY_ETHNICITY containedIn:ethic_arr];
        if(belief_arr.count>0)
            [query whereKey:PF_USER_MY_BELIEF containedIn:belief_arr];
        
        query.limit = 2;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                if(objects.count == 2) {
                    [todayArray addObjectsFromArray:objects];
                    [streamView reloadData];
                    [self saveDatas:objects];
                    
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You cannot unlock more matches today. Please come back tomorrow! :)" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                }
                
            }
            [[KIProgressViewManager manager] hideProgressView];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Oh no! You do not have enough Krone. Buy more Krone to unlock!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy 50 Krones for $0.99!", nil];
        [alertView show];

    }
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Timer_Refresh object:nil];
}
- (void)timerRefresh {
    NSDate *today = [NSDate date];
    NSDate* dateEnd = [today dateAtEndOfDay];
    NSDate* dateStart = [[NSDate dateTomorrow] dateAtStartOfDay];
    
    int seconds = abs((int)[today secondsAfterDate:dateEnd]);
    [timerToday setTimerDisplay:seconds];
    int seconds_next = abs((int)[today minutesAfterDate:dateStart]);
    if(seconds_next == 0) {
        
        [self loadUsers];
        //[self promptEnoughKrones];
        
    }    
}
-(int) generateRandomNumberWithlowerBound:(int)lowerBound
                               upperBound:(int)upperBound
{
    int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    return rndValue;
}
- (void)createUsers {
    
//    Test Users Creation Module
    NSArray *genders = [NSArray arrayWithObjects:@"Male",@"Female", nil];
    NSArray *belief = [NSArray arrayWithObjects:@"Protestantism",@"Eastern Orthodox",@"Catholicism",@"Buddhism",@"Hinduism" ,nil];
    NSArray *ethnicity = [NSArray arrayWithObjects:@"Native American",@"South East Asian",@"Hispanic",@"Other", nil];
    
    for(int i=0; i<1000; i++) {
        PFUser *user = [PFUser new];
        user[PF_USER_USERNAME] = [MBFakerInternet userName];
        user.password =        user[PF_USER_USERNAME];
        user[PF_USER_EMAIL] = [MBFakerInternet freeEmail];
        user[PF_USER_FULLNAME] = [MBFakerName name];
        user[PF_USER_ABOUT_LIFE] = [MBFakerLorem sentences:[self generateRandomNumberWithlowerBound:2 upperBound:5]];
        user[PF_USER_ABOUT_ME] = [MBFakerLorem sentences:[self generateRandomNumberWithlowerBound:2 upperBound:5]];
        user[PF_USER_ABOUT_YOU] = [MBFakerLorem sentences:[self generateRandomNumberWithlowerBound:2 upperBound:5]];
        user[PF_USER_BIRTHDAY] = [[NSDate date] dateBySubtractingYears:[self generateRandomNumberWithlowerBound:18 upperBound:50]];
        user[PF_USER_GENDER] = genders[1];
        user[PF_USER_GEOLOCATION] = [PFGeoPoint geoPointWithLatitude:37.7873589 longitude:-122.408227];
        user[PF_USER_L_GENDER] = genders[1];
        user[PF_USER_L_MAXAGE] = [NSNumber numberWithInt:[self generateRandomNumberWithlowerBound:18 upperBound:55]];
        user[PF_USER_L_MINAGE] = [NSNumber numberWithInt:[self generateRandomNumberWithlowerBound:18 upperBound:55]];
        user[PF_USER_L_DISTANCE] = @"10 miles";
        user[PF_USER_PICTURE] = [NSString stringWithFormat:@"http:robohash.org/%@.png?size=100x100",user[PF_USER_USERNAME]];
        user[PF_USER_ZIPCODE] = [MBFakerAddress city];
        user[PF_USER_MY_ETHNICITY] = [ethnicity objectAtIndex:[self generateRandomNumberWithlowerBound:0 upperBound:3]];
        user[PF_USER_MY_BELIEF] = [ belief objectAtIndex:[self generateRandomNumberWithlowerBound:0 upperBound:3]];
        for(int i=0; i<15; i++) {
            NSString *key = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
            user[key] = [NSNumber numberWithInt:[self generateRandomNumberWithlowerBound:0 upperBound:100]];
        }
        [user signUpInBackground];
        
    }
    
}
- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random_uniform(max - min + 1);
}
- (void)loadUsers {
    
    NSArray *today_array = [self arrayTodayMatchInBackend];
    if(today_array.count != 0) {
        
        [[KIProgressViewManager manager] showProgressOnView:self.view];

        PFQuery *query = [PFUser query];
        [query whereKey:PF_USER_ACTIVATE notEqualTo:[NSNumber numberWithBool:NO]];
        [query whereKey:@"objectId" containedIn:today_array];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                todayArray = [NSMutableArray arrayWithArray:objects];
                [streamView reloadData];
                if(objects.count>0)
                    btnUnLockMatches.enabled = YES;
                
            }
            [[KIProgressViewManager manager] hideProgressView];
        }];

    } else {
        [[KIProgressViewManager manager] showProgressOnView:self.view];
        
        PFUser *user = [PFUser currentUser];
        
        PFQuery *query = [PFUser query];
        [query whereKey:PF_USER_GENDER equalTo:user[PF_USER_L_GENDER]];
        [query whereKey:PF_USER_ACTIVATE notEqualTo:[NSNumber numberWithBool:NO]];
        
        NSDate *bottomDate = [[NSDate date] dateBySubtractingYears:[user[PF_USER_L_MAXAGE] intValue]];
        NSDate *topDate = [[NSDate date] dateBySubtractingYears:[user[PF_USER_L_MINAGE] intValue]];
        [query whereKey:PF_USER_BIRTHDAY  greaterThanOrEqualTo:bottomDate];
        [query whereKey:PF_USER_BIRTHDAY lessThan:topDate];
        [query whereKey:@"objectId" notContainedIn:madeMatches];
        
        NSString *userDistance = user[PF_USER_L_DISTANCE];
        userDistance = [userDistance stringByReplacingOccurrencesOfString:@" miles" withString:@""];
        [query whereKey:PF_USER_GEOLOCATION nearGeoPoint:user[PF_USER_GEOLOCATION] withinMiles:userDistance.intValue];
        
        NSArray *ethic_arr = user[PF_USER_ETHNICITY];
        NSArray *belief_arr = user[PF_USER_BELIEF];
        if(ethic_arr.count>0)
            [query whereKey:PF_USER_MY_ETHNICITY containedIn:ethic_arr];
        if(belief_arr.count>0)
            [query whereKey:PF_USER_MY_BELIEF containedIn:belief_arr];
        
        query.limit = 6;
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error) {
                todayArray = [NSMutableArray arrayWithArray:objects];
                [streamView reloadData];
                [self saveDatas:objects];
                if(objects.count>0)
                    btnUnLockMatches.enabled = YES;
                
            }
            [[KIProgressViewManager manager] hideProgressView];
        }];
    }
    
} //
- (NSArray*)arrayTodayMatchInBackend {
    
    NSMutableArray *today_array = [NSMutableArray array];
    
    [madeMatches removeAllObjects];
    
    NSMutableArray *matches_array = [PFUser currentUser][PF_USER_MATCHES];
    if(!matches_array)
        matches_array = [NSMutableArray array];
    
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 0;
    
    for(NSDictionary *dict_match in matches_array) {
        NSDate *date = [dict_match objectForKey:@"date"];
        if([date isToday]) {
            [today_array addObject:[dict_match objectForKey:@"pfObjectID"]];
        } else if([date isEarlierThanDate:[[NSDate dateWithDaysBeforeNow:6] dateAtStartOfDay]]) {
            [discardedItems addIndex:index];
        }
        [madeMatches addObject:[dict_match objectForKey:@"pfObjectID"]];
        index++;
    }
    
    [matches_array removeObjectsAtIndexes:discardedItems];
    
    [PFUser currentUser][PF_USER_MATCHES] = matches_array;
    [[PFUser currentUser] saveInBackground];
    
    return today_array;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveDatas:(NSArray*) array {
    
    NSMutableArray *matches_array = [PFUser currentUser][PF_USER_MATCHES];
    if(!matches_array)
        matches_array = [NSMutableArray array];
    
    for(int i=0; i<array.count; i++) {
        PFObject *object = array[i];
        NSDictionary *dict_match = [NSDictionary dictionaryWithObjectsAndKeys:object.objectId,@"pfObjectID",[NSDate date],@"date", nil];
        [matches_array addObject:dict_match];
    }
    
    [PFUser currentUser][PF_USER_MATCHES] = matches_array;
    [[PFUser currentUser] saveInBackground];
}

#pragma mark -
#pragma mark Feed Collection View Delegate

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        if(indexPath.section == 0) {
            
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            
            if (headerView==nil) {
                headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
                [headerView addSubview:timerToday];
            }
            
            [[headerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            [headerView addSubview:timerToday];
            return headerView;
            
        }
    }
    if(kind == UICollectionElementKindSectionFooter) {
        if(indexPath.section == 0) {
            UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
            
            if (footerView==nil) {
                footerView = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
                [footerView addSubview:moreMatchView];
            }
            
            [[footerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            [footerView addSubview:moreMatchView];
            return footerView;

        } else {
            UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
            return footerView;
        }
    }

    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if(section == 0) {
        return CGSizeMake(self.view.width, 100);
    } else {
        return CGSizeMake(self.view.width, 1);
    }

}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section == 0) {
        return todayArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if(indexPath.section == 0) {
        
        PFObject *objectUser = [todayArray objectAtIndex:indexPath.row];
        [cell.photoView setImageWithURL:[NSURL URLWithString:objectUser[PF_USER_PICTURE]] placeholderImage:[UIImage imageNamed:@"placeholder_gb.png"]];
        cell.nameLbl.text = objectUser[PF_USER_FULLNAME];
        cell.ageAddressLbl.text = [NSString stringWithFormat:@"%d | %@",(int)[NSDate age:objectUser[PF_USER_BIRTHDAY]],objectUser[PF_USER_ZIPCODE]];
        PFGeoPoint *pointOfMe = [PFUser currentUser][PF_USER_GEOLOCATION];
        cell.distanceLbl.text = [NSString stringWithFormat:@"%.1f Miles",[pointOfMe distanceInMilesTo:objectUser[PF_USER_GEOLOCATION]]];
        cell.matchLbl.text = [NSString stringWithFormat:@"%d",[self calcComfortablePercent:objectUser]];
        
        NSArray *banArray = [PFUser currentUser][PF_USER_BANS];
        
        if(!banArray)
            banArray = [NSArray array];
        
        if([banArray containsObject:objectUser.objectId]) {
            [cell setBan:YES];
        } else {
            [cell setBan:NO];
        }

    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // If you need to use the touched cell, you can retrieve it like so
//    MatchCollectionViewCell *cellTouched = (MatchCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    PFObject *objectUser;
    
    NSArray *banArray = objectUser[PF_USER_BANS];
    
    if(!banArray)
        banArray = [NSArray array];
    
    if([banArray containsObject:[PFUser currentUser].objectId]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You are banned! Cannot find the user!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        
    } else {
        
        RootFriendProfileViewController *rootFriendProfileViewCtrl = [[RootFriendProfileViewController alloc] init];
        if(indexPath.section == 0) {
            objectUser = [todayArray objectAtIndex:indexPath.row];
        }
        rootFriendProfileViewCtrl.user = (PFUser*)objectUser;
        rootFriendProfileViewCtrl.type = (int)indexPath.section+1;
        rootFriendProfileViewCtrl.date = self.date;
        [self.navigationController pushViewController:rootFriendProfileViewCtrl animated:YES];
    }
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)lockBtnClicked:(id)sender {
    
    MatchCollectionViewCell *cellTouched = (MatchCollectionViewCell*)[[sender superview] superview];
    NSIndexPath *indexPath = [streamView indexPathForCell:cellTouched];
    
    DataManager *dm = [DataManager SharedDataManager];
    
    if([[GlobalPool sharedInstance] unLock:[GlobalPool sharedInstance].kUnlockLimit]) {
        if(indexPath.section==0) {
            
            PFObject *objectUser = [todayArray objectAtIndex:indexPath.row];
            NSManagedObject *purchase = [dm newObjectForEntityForName:@"Purchases"];
            [purchase setValue:objectUser.objectId forKey:@"pfObjectID"];
            [purchase setValue:[NSDate date] forKey:@"date"];
            [purchase didSave];
            
        }
        [dm update];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
        [cellTouched setLock:NO];

    } else {

    }
    
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) {
        NSLog(@"Cancel");
    } else {
        [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:IAP50];
    }
}

@end
