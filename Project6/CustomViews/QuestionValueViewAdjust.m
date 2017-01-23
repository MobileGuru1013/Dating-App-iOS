//
//  QuestionValueView.m
//  Project6
//
//  Created by superman on 2/24/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "QuestionValueViewAdjust.h"
#import "UIViewAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "Public.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight 34
#define kLeft 110

@implementation QuestionValueViewAdjust

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
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(kLeft, 0, kWidth-2*kLeft, kHeight)];
    self.slider.maximumValue = 100;
    self.slider.minimumValue = 0;
    self.slider.userInteractionEnabled = NO;
    self.slider.continuous = YES;
    self.slider.tintColor = COLOR_BACKGROUND;
    self.slider.thumbTintColor = COLOR_BACKGROUND;

    self.lblLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, kLeft-5, kHeight-10)];
    self.lblLeft.font = [UIFont boldSystemFontOfSize:12];
    self.lblLeft.textAlignment = NSTextAlignmentRight;
    self.lblLeft.textColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    self.lblRight = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-kLeft+5, 5, kLeft, kHeight-10)];
    self.lblRight.font = [UIFont boldSystemFontOfSize:12];
    self.lblRight.textAlignment = NSTextAlignmentLeft;
    self.lblRight.textColor = [UIColor colorWithRed:166.0/255.0 green:166.0/255.0 blue:166.0/255.0 alpha:1.0];
    
    [self addSubview:self.slider];
    [self addSubview:self.lblLeft];
    [self addSubview:self.lblRight];
    self.clipsToBounds = YES;

}

@end
