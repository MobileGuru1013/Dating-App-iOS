//
//  RootProfileViewController.m
//  Project6
//
//  Created by superman on 2/21/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "RootProfileViewController.h"
#import "SHViewPager.h"
#import "ProfileViewController.h"
#import "ProfileQuestionsViewController.h"
#import "ProfilePersonalityViewController.h"
#import "CloudViewController.h"
#import "AppDelegate.h"

@interface RootProfileViewController () <SHViewPagerDataSource, SHViewPagerDelegate>
{
    SHViewPager *pager;
    NSArray *menuItems;
}
@end

@implementation RootProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[KIProgressViewManager manager] hideProgressView];

    self.navigationItem.title = @"Profile";
    
    pager = [[SHViewPager alloc] initWithFrame:self.view.bounds];
    
    pager.dataSource = self;
    pager.delegate = self;
    
    menuItems = [[NSArray alloc] initWithObjects:@"About",@"Cloud" ,@"Personality", nil];
    
    [pager reloadData];
    
    [self.view addSubview:pager];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ref.loginNavCtrl.navigationBarHidden = YES;
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
        ProfileViewController *matchesViewCtrl = [[ProfileViewController alloc] init];
        matchesViewCtrl.user = self.user;
        return matchesViewCtrl;
    } else if(index == 1) {
        CloudViewController *cloudViewCtrl = [[CloudViewController alloc] init];
        return cloudViewCtrl;
    } else {
        ProfilePersonalityViewController *rootCtrl = [[ProfilePersonalityViewController alloc] init];
        return rootCtrl;

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
    NSLog(@"content will move to page %d from page: %d", toIndex, fromIndex);
}

- (void)viewPager:(SHViewPager *)viewPager didMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"content moved to page %d from page: %d", toIndex, fromIndex);
}

@end