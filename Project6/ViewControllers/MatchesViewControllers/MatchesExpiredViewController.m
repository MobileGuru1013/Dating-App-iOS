//
//  MatchesViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "MatchesExpiredViewController.h"
#import "KRLCollectionViewGridLayout.h"
#import "TimerView.h"
#import "MatchCollectionViewCell.h"
#import "RootFriendProfileViewController.h"
#import "MBFaker.h"
#import "MatchCollectionHeaderView.h"
#import "GlobalPool.h"
#import "AppDelegate.h"

@interface MatchesExpiredViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIAlertViewDelegate>
{
    UICollectionView *streamView;
    NSMutableArray *todayArray;
    
    PFObject *temp_object;
    MatchCollectionViewCell *temp_cell;
}
@end

@implementation MatchesExpiredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Matches";
    
    KRLCollectionViewGridLayout *layout = [[KRLCollectionViewGridLayout alloc] init];
    layout.numberOfItemsPerLine = 2;
    layout.aspectRatio = 0.6;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.interitemSpacing = 10;
    layout.lineSpacing = 10;

    streamView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64-50) collectionViewLayout:layout];
    streamView.delegate = self;
    streamView.dataSource = self;
    streamView.backgroundColor = [UIColor clearColor];
    
    [streamView registerClass:[MatchCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [streamView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    
    [self.view addSubview:streamView];

    [self loadUsers];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
    
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
}

-(int) generateRandomNumberWithlowerBound:(int)lowerBound
                               upperBound:(int)upperBound
{
    int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    return rndValue;
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

        [cell.lockButton addTarget:self action:@selector(lockBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([[PFUser currentUser][PF_USER_UNLOCKED] containsObject:objectUser.objectId])
        {
            [cell setLock:NO];
        } else {
            [cell setLock:YES];
        }
        
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
    rootFriendProfileViewCtrl.type = -1;
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
    PFObject *objectUser = [todayArray objectAtIndex:indexPath.row];
    
    temp_object = objectUser;
    temp_cell = cellTouched;
    
    NSString *str_alert = [NSString stringWithFormat:@"Unlock [%@] with 20 Krone",objectUser[PF_USER_FULLNAME]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:str_alert delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [alertView show];
    
}

#pragma mark -
#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        
        if([[GlobalPool sharedInstance] unLock:[GlobalPool sharedInstance].kUnlockLimit]) {
            
            NSMutableArray *array = [PFUser currentUser][PF_USER_UNLOCKED];
            if(!array)
                array = [NSMutableArray array];
            [array addObject:temp_object.objectId];
            
            [PFUser currentUser][PF_USER_UNLOCKED] = array;
            
            [[PFUser currentUser] saveInBackground];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_InitialSetting_Refresh object:nil];
            [temp_cell setLock:NO];
            
        } else {
            
        }
    }
}

@end
