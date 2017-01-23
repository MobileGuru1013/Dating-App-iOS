//
//  QuestionValueView.m
//  Project6
//
//  Created by superman on 2/24/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "QuestionValueView.h"
#import "UIViewAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "Public.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight 34

@implementation QuestionValueView

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
    
    self.lblCenter = [[UILabel alloc] initWithFrame:CGRectMake(kWidth/2-15, 5, 30, kHeight-10)];
    self.lblCenter.font = [UIFont systemFontOfSize:14];
    self.lblCenter.textAlignment = NSTextAlignmentCenter;
    self.lblCenter.layer.cornerRadius = 5;
    self.lblCenter.layer.masksToBounds = YES;
    self.lblCenter.backgroundColor = COLOR_MENU;
    self.lblCenter.textColor = COLOR_Border;
    
    self.lblLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, kWidth/3, kHeight-10)];
    self.lblLeft.font = [UIFont systemFontOfSize:14];
    self.lblLeft.textAlignment = NSTextAlignmentRight;
    self.lblLeft.right = self.lblCenter.left - 5;
    self.lblLeft.textColor = [UIColor lightGrayColor];
    
    self.lblRight = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, kWidth/3, kHeight-10)];
    self.lblRight.font = [UIFont systemFontOfSize:14];
    self.lblRight.textAlignment = NSTextAlignmentLeft;
    self.lblRight.left = self.lblCenter.right + 5;
    self.lblRight.textColor = [UIColor lightGrayColor];
    
    [self addSubview:self.lblCenter];
    [self addSubview:self.lblLeft];
    [self addSubview:self.lblRight];
    
}

@end
