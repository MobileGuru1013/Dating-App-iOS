//
//  UINavigationController+Retro.h
//  IdeaBox
//
//  Created by Superman on 12/18/14.
//  Copyright (c) 2014 IdeaBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Retro)

- (void)pushViewControllerRetro:(UIViewController *)viewController;
- (void)popViewControllerRetro;
- (void)popViewControllerRetroToRoot;

@end
