//
//  TimerView.h
//  Project6
//
//  Created by superman on 2/15/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerView : UIView

- (void)setTimerDisplay:(int) timeLeft;
- (void)setHeaderTitle:(NSString*) title;

- (void)setBorderEnable;

@end
