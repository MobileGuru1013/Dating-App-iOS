//
//  MatchCollectionHeaderView.m
//  Project6
//
//  Created by superman on 3/20/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "MatchCollectionHeaderView.h"
#import "Public.h"

#define kWidth [UIScreen mainScreen].bounds.size.width

@implementation MatchCollectionHeaderView

- (id) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.timerView = [[TimerView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 100)];
        self.timerView.centerX = kWidth/2;
        self.timerView.centerY = 50;
        [self addSubview:self.timerView];
    }
    return self;
}

@end
