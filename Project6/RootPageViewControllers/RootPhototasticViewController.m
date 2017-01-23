//
//  RootPhototasticViewController.m
//  Project6
//
//  Created by superman on 2/22/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "RootPhototasticViewController.h"
#import "PhototasticViewController.h"
#import "CreateTestViewController.h"
#import "ResultViewController.h"
#import "AppDelegate.h"

@interface RootPhototasticViewController ()<SHViewPagerDataSource, SHViewPagerDelegate>
{
    SHViewPager *pager;
    NSArray *menuItems;
}
@end

@implementation RootPhototasticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Phototastic";
    
    pager = [[SHViewPager alloc] initWithFrame:self.view.bounds];
    
    pager.dataSource = self;
    pager.delegate = self;
    
    menuItems = [[NSArray alloc] initWithObjects:@"Rate", @"Create Test", @"Result", nil];
    
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
        PhototasticViewController *matchesViewCtrl = [[PhototasticViewController alloc] init];
        return matchesViewCtrl;
    } else if(index == 1) {
        CreateTestViewController *questionsCtrl = [[CreateTestViewController alloc] init];
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:questionsCtrl];
        navCtrl.navigationBarHidden = YES;
        return navCtrl;
    } else
    {
        ResultViewController *rootCtrl = [[ResultViewController alloc] init];
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:rootCtrl];
        navCtrl.navigationBarHidden = YES;
        return navCtrl;
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


@end
