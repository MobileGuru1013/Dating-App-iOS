//
//  MJViewController.h
//  ParallaxImages
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EMJRootViewControllerDelegate;

@interface MJRootViewController : UIViewController

@property (nonatomic, strong) id<EMJRootViewControllerDelegate> delegate;

@end

@protocol EMJRootViewControllerDelegate <NSObject>

- (void)photoSelected:(NSString *) resultStr;

@end