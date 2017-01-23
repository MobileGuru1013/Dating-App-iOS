//
//  Public.h
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#ifndef Project6_Public_h
#define Project6_Public_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "APAvatarImageView.h"
#import "UIViewAdditions.h"
#import "UINavigationBar+Addition.h"
#import "NSDate+Escort.h"
#import "RESideMenu.h"
#import "UIView+Blur.h"
#import "UIView+RNActivityView.h"
#import "UINavigationController+Retro.h"
#import "KRLCollectionViewGridLayout.h"
#import <QuartzCore/QuartzCore.h>
#import "BorderButton.h"
#import "KIProgressView.h"
#import "KIProgressViewManager.h"
#import "UILabel+dynamicSizeMe.h"
#import "INTULocationManager.h"
#import "INTULocationManager+Internal.h"
#import "TimerView.h"
#import "DataManager.h"
#import "Matches.h"
#import "MKStoreKit.h"
#import "RecentView.h"
#import "ChatView.h"
#import "PFUser+Util.h"
#import "GlobalPool.h"
#import "recent.h"

#import "AFNetworkReachabilityManager.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "PFDatabase.h"

#define COLOR_MENU [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:79.0/255.0 alpha:1.0]
#define COLOR_TINT [UIColor whiteColor]
#define COLOR_BACKGROUND [UIColor colorWithRed:151.0/255.0 green:79.0/255.0 blue:181.0/255.0 alpha:1.0]
#define COLOR_Border [UIColor colorWithRed:251.0/255.0 green:168.0/255.0 blue:86.0/255.0 alpha:1.0]
#define COLOR_SECOND [UIColor colorWithRed:105.0/255.0 green:70.0/255.0 blue:93.0/255.0 alpha:1.0]
#define COLOR_IN_GRAY [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]
#define COLOR_IN_DARK_GRAY [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0]
#define COLOR_MENU_NEW  [UIColor colorWithRed:113.0/255.0 green:86.0/255.0 blue:150.0/255.0 alpha:1.0]
#define COLOR_IN_BLACK [UIColor colorWithRed:56.0/255.0 green:56.0/255.0 blue:56.0/255.0 alpha:1.0]
#define COLOR_BUTTON [UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]
#define COLOR_TINT_SECOND [UIColor colorWithRed:171.0/255.0 green:108.0/255.0 blue:196.0/255.0 alpha:1.0]

#define Notification_Timer_Refresh @"Notification_Timer_Refresh"
#define Notification_InitialSetting_Refresh @"Notification_InitialSetting_Refresh"

#define kRemindMeNotificationDataKey @"kRemindMeNotificationDataKey"
#define Notification_Ban_On @"Notification_Ban_On"
#define Notification_Ban_Off @"Notification_Ban_Off"

//#define [GlobalPool sharedInstance].kMatchLimit      80
//
//#define [GlobalPool sharedInstance].kUnlockLimit              20
//#define kPurchaseMoreMatch          50

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

#define pubWidth [UIScreen mainScreen].bounds.size.width


#endif
