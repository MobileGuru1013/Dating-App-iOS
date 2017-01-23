//
//  RootMatchViewController.m
//  Project6
//
//  Created by superman on 2/21/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "RootMatchViewController.h"
#import "MatchesExpiredViewController.h"
#import "MatchesExpiringViewController.h"

#import "AppDelegate.h"

@interface RootMatchViewController () <SHViewPagerDataSource, SHViewPagerDelegate>
{
    SHViewPager *pager;
    NSArray *menuItems;
    NSArray *menuDates;
}
@end

@implementation RootMatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[KIProgressViewManager manager] hideProgressView];
    
    self.navigationItem.title = @"Matches";

    pager = [[SHViewPager alloc] initWithFrame:self.view.bounds];
    
    pager.dataSource = self;
    pager.delegate = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/dd"];
    
    menuItems = [[NSArray alloc] initWithObjects:@"Today",@"Yesterday", [formatter stringFromDate:[NSDate dateWithDaysBeforeNow:2]],[formatter stringFromDate:[NSDate dateWithDaysBeforeNow:3]],[formatter stringFromDate:[NSDate dateWithDaysBeforeNow:4]],[formatter stringFromDate:[NSDate dateWithDaysBeforeNow:5]] ,@"Expired", nil];
    menuDates = [NSArray arrayWithObjects:[NSDate date],[NSDate dateYesterday],[NSDate dateWithDaysBeforeNow:2],[NSDate dateWithDaysBeforeNow:3],[NSDate dateWithDaysBeforeNow:4],[NSDate dateWithDaysBeforeNow:5],[NSDate dateWithDaysBeforeNow:6], nil];
    
    [pager reloadData];
    
    [self.view addSubview:pager];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SHViewPagerDataSource stack
- (UIColor *)colorForMenuInViewPager:(SHViewPager *)viewPager {
    return [UIColor whiteColor];
}

// font for the menu
// if not implemented, the system font will be used
- (UIFont *)fontForMenu:(SHViewPager *)viewPager {
    return [UIFont boldSystemFontOfSize:12.0];
}
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
    NSDate *date = [menuDates objectAtIndex:index];
    
    if(index == 0) {
        MatchesViewController *matchesViewCtrl = [[MatchesViewController alloc] init];
        matchesViewCtrl.date = date;
        return matchesViewCtrl;
        
    } else if(index == menuDates.count-1) {
        MatchesExpiredViewController *matchExpiredViewCtrl = [[MatchesExpiredViewController alloc] init];
        matchExpiredViewCtrl.date = date;
        return matchExpiredViewCtrl;
        
    } else {
        MatchesExpiringViewController *matchesExpiringViewCtrl = [[MatchesExpiringViewController alloc] init];
        matchesExpiringViewCtrl.date = date;
        return matchesExpiringViewCtrl;

    }
    
    return nil;
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
    return SHViewPagerMenuWidthTypeNarrow;
}

#pragma mark - SHViewPagerDelegate stack
- (void)firstContentPageLoadedForViewPager:(SHViewPager *)viewPager
{
    NSLog(@"first viewcontroller content loaded");
}

- (void)viewPager:(SHViewPager *)viewPager willMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"content will move to page %d from page: %d", toIndex, fromIndex);
}

- (void)viewPager:(SHViewPager *)viewPager didMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"content moved to page %d from page: %d", toIndex, fromIndex);
}


@end
