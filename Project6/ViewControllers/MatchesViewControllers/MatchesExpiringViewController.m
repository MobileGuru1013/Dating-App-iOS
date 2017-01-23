//
//  MatchesViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "MatchesExpiringViewController.h"
#import "KRLCollectionViewGridLayout.h"
#import "TimerView.h"
#import "MatchCollectionViewCell.h"
#import "RootFriendProfileViewController.h"
#import "MBFaker.h"
#import "MatchCollectionHeaderView.h"
#import "GlobalPool.h"
#import "AppDelegate.h"

@interface MatchesExpiringViewController () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView *streamView;
    NSMutableArray *todayArray;
    
    TimerView *timerToday;
}
@end

@implementation MatchesExpiringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Matches";
    
    timerToday = [[TimerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    timerToday.centerX = self.view.width/2-10;
    timerToday.centerY = 50;
    
    if([self.date isYesterday])
        [timerToday setHeaderTitle:@"Yesterday's Matches"];
    else
        [timerToday setHeaderTitle:[NSDate getFormattedBirthday:self.date]];
    
    KRLCollectionViewGridLayout *layout = [[KRLCollectionViewGridLayout alloc] init];
    layout.numberOfItemsPerLine = 2;
    layout.aspectRatio = 0.6;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.interitemSpacing = 10;
    layout.lineSpacing = 10;
    layout.headerReferenceSize = CGSizeMake(self.view.width, 80);
    
    streamView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64-50) collectionViewLayout:layout];
    streamView.delegate = self;
    streamView.dataSource = self;
    streamView.backgroundColor = [UIColor clearColor];

    [streamView registerClass:[MatchCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [streamView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];

    [self.view addSubview:streamView];
    
    [self loadUsers];


}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerRefresh) name:Notification_Timer_Refresh object:nil];
    [self timerRefresh];
    
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;


}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notification_Timer_Refresh object:nil];
}
- (void)timerRefresh {
    NSDate *today = [NSDate date];
    NSDate* dateEnd = [today dateAtEndOfDay];
    int seconds = abs((int)[today secondsAfterDate:dateEnd]);

    [timerToday setTimerDisplay:0*24*60+seconds];
    
}
-(int) generateRandomNumberWithlowerBound:(int)lowerBound
                               upperBound:(int)upperBound
{
    int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    return rndValue;
}
- (void)createUsers {
    
    NSArray *genders = [NSArray arrayWithObjects:@"Male",@"Female", nil];
    NSArray *belief = [NSArray arrayWithObjects:@"Belief-A",@"Belief-B",@"Belief-C",@"Belief-D", nil];
    NSArray *ethnicity = [NSArray arrayWithObjects:@"Ethic-A",@"Ethic-B",@"Ethic-C",@"Ethic-D", nil];
    
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
        user[PF_USER_PICTURE] = [NSString stringWithFormat:@"http://robohash.org/%@.png?size=100x100",user[PF_USER_USERNAME]];
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
- (NSArray*)arrayTodayMatchInBackend {
    
    NSMutableArray *today_array = [NSMutableArray array];
    
    NSMutableArray *matches_array = [PFUser currentUser][PF_USER_MATCHES];
    if(!matches_array)
        matches_array = [NSMutableArray array];
    
    for(NSDictionary *dict_match in matches_array) {
        NSDate *date = [dict_match objectForKey:@"date"];
        
        if([date isSameDayAsDate:self.date] ) {
            [today_array addObject:[dict_match objectForKey:@"pfObjectID"]];
        }
    }
    
    return today_array;
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
            }
            [[KIProgressViewManager manager] hideProgressView];
        }];
        
    }
} //

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

- (BOOL)isMatchMade:(PFObject*) obj {
    DataManager *dm = [DataManager SharedDataManager];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pfObjectID = %@", obj.objectId];
    int count = (int)[dm getCountWithEntry:@"Matches" sortDescriptor:@"date" sortPredicate:predicate batchSize:300];
    if(count>0)
        return YES;
    else
        return NO;
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

    return nil;
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
    RootFriendProfileViewController *rootFriendProfileViewCtrl = [[RootFriendProfileViewController alloc] init];
    PFObject *objectUser;
    
    if(indexPath.section == 0) {
        objectUser = [todayArray objectAtIndex:indexPath.row];
    }
    
    rootFriendProfileViewCtrl.user = (PFUser*)objectUser;
    rootFriendProfileViewCtrl.type = (int)indexPath.section+4;
    rootFriendProfileViewCtrl.date = self.date;
    
    [self.navigationController pushViewController:rootFriendProfileViewCtrl animated:YES];
    
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
            [purchase setValue:[NSDate dateWithDaysBeforeNow:5] forKey:@"date"];
            [purchase didSave];
            
        }

        [dm update];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
        [cellTouched setLock:NO];
        
    } else {
        
    }
    
    
}

@end
