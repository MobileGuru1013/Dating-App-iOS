//
//  TimeDiffViewController.m
//  Project6
//
//  Created by Louis Laurent on 12/05/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "TimeDiffViewController.h"
#import "AppDelegate.h"

@interface TimeDiffViewController ()

@end

@implementation TimeDiffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Confirm your identity";
    
    self.navigationItem.leftBarButtonItem = nil;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.view.width, 30)];
    lblTitle.textColor = COLOR_IN_BLACK;
    lblTitle.font = [UIFont boldSystemFontOfSize:16];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"Your device's time is set incorrectly.";
    
    [self.view addSubview:lblTitle];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(0, lblTitle.bottom, self.view.width, 80)];
    lblDescription.textColor = COLOR_IN_DARK_GRAY;
    lblDescription.font = [UIFont systemFontOfSize:14];
    lblDescription.numberOfLines = 2;
    lblDescription.textAlignment = NSTextAlignmentCenter;
    lblDescription.text = @"Please go to Settings app and update the Date & Time setting. This can be found under General.";
    
    [self.view addSubview:lblDescription];
    
    UIButton *btnOk = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width/2-60, lblDescription.bottom+20, 120, 34)];
    [btnOk setTintColor:[UIColor whiteColor]];
    [btnOk setTitle:@"OK" forState:UIControlStateNormal];
    
    [btnOk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    [btnOk addTarget:self action:@selector(btnOKClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnOk.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnOk setBackgroundColor:COLOR_BUTTON];
    [btnOk.layer setCornerRadius:6.0];
    btnOk.layer.masksToBounds = YES;

    [self.view addSubview:btnOk];
    // Do any additional setup after loading the view.
}
- (BOOL)checkTimeDifference {
    //Time Difference
    
    NSURL *url = [NSURL URLWithString:@"http://www.timeapi.org/utc/now"];
    NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:Nil error:Nil];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormatter dateFromString:str];
    
    NSLog(@"%f",[[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970]);
    
    float sDiff = [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970];
    
    if(abs(sDiff)>30.0)
        return YES;
    else
        return NO;
}

- (void)btnOKClicked:(id) sender {
    if([self checkTimeDifference])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    else {
        AppDelegate *ref = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [ref.navTime.view removeFromSuperview];
    }

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
