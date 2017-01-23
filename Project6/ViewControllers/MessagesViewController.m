//
//  MessagesViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "MessagesViewController.h"
#import "AppDelegate.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"aaa";

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
