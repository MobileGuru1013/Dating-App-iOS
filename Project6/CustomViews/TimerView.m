//
//  TimerView.m
//  Project6
//
//  Created by superman on 2/15/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "TimerView.h"
#import "UIViewAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "Public.h"

#define kWidth 200
#define kHeight 100

@interface TimerView()
{
    UILabel *headerTitleLbl;
    UILabel *bottomTitleLbl;
    UILabel *dayLbl;
    UILabel *hrLbl;
    UILabel *minLbl;
}
@end

@implementation TimerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, kWidth, kHeight)];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (void)sharedSetup {
    headerTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, kWidth, 20)];
    headerTitleLbl.textAlignment = NSTextAlignmentCenter;
    headerTitleLbl.font = [UIFont boldSystemFontOfSize:18];
    headerTitleLbl.textColor = [UIColor grayColor];
    
    dayLbl = [[UILabel alloc] initWithFrame:CGRectMake(28, headerTitleLbl.bottom+4, 40, 40)];
    dayLbl.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];
    dayLbl.font = [UIFont boldSystemFontOfSize:22];
    dayLbl.textColor = [UIColor whiteColor];
    dayLbl.textAlignment = NSTextAlignmentCenter;
    dayLbl.text = @"--";
    dayLbl.layer.cornerRadius = 20;
    dayLbl.layer.masksToBounds = YES;
    
    hrLbl = [[UILabel alloc] initWithFrame:CGRectMake(dayLbl.right+10, headerTitleLbl.bottom+4, 40, 40)];
    hrLbl.font = [UIFont boldSystemFontOfSize:22];
    hrLbl.textColor = [UIColor whiteColor];
    hrLbl.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];
    hrLbl.textAlignment = NSTextAlignmentCenter;
    hrLbl.text = @"--";
    hrLbl.layer.cornerRadius = 20;
    hrLbl.layer.masksToBounds = YES;
    
    minLbl = [[UILabel alloc] initWithFrame:CGRectMake(hrLbl.right+10, headerTitleLbl.bottom+4, 40, 40)];
    minLbl.font = [UIFont boldSystemFontOfSize:22];
    minLbl.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];
    minLbl.textAlignment = NSTextAlignmentCenter;
    minLbl.textColor = [UIColor whiteColor];
    minLbl.text = @"--";
    minLbl.layer.cornerRadius = 20;
    minLbl.layer.masksToBounds = YES;
    
    UILabel *lblDot1 = [[UILabel alloc] initWithFrame:CGRectMake(dayLbl.right, dayLbl.top, 10, 40)];
    lblDot1.font = [UIFont boldSystemFontOfSize:30];
    lblDot1.textAlignment = NSTextAlignmentCenter;
    lblDot1.text = @":";
    lblDot1.textColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];
    
    [self addSubview:lblDot1];
    
    UILabel *lblDot2 = [[UILabel alloc] initWithFrame:CGRectMake(hrLbl.right, hrLbl.top, 10, 40)];
    lblDot2.font = [UIFont boldSystemFontOfSize:30];
    lblDot2.textAlignment = NSTextAlignmentCenter;
    lblDot2.text = @":";
    lblDot2.textColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];
    
    [self addSubview:lblDot2];
    
    [self addSubview:headerTitleLbl];
    [self addSubview:dayLbl];
    [self addSubview:hrLbl];
    [self addSubview:minLbl];

}

- (void)setTimerDisplay:(int) timeLeft {
    dayLbl.text = [NSString stringWithFormat:@"%02d",timeLeft/(3600)];
    hrLbl.text = [NSString stringWithFormat:@"%02d",(timeLeft%3600)/60];
    minLbl.text = [NSString stringWithFormat:@"%02d",timeLeft%60];
}
- (void)setHeaderTitle:(NSString*) title{
    headerTitleLbl.text = title;
}

- (void)setBorderEnable {
    
    dayLbl.layer.borderColor = [COLOR_Border CGColor];
    dayLbl.layer.borderWidth = 1;
    hrLbl.layer.borderColor = [COLOR_Border CGColor];
    hrLbl.layer.borderWidth = 1;
    minLbl.layer.borderColor = [COLOR_Border CGColor];
    minLbl.layer.borderWidth = 1;

}

@end
