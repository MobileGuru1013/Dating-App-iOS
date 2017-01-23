//
//  AppDelegate.h
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TimeDiffViewController.h"
#import "push.h"

#import "Public.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, RESideMenuDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RESideMenu *sideMenuViewCtrl;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) TimeDiffViewController *timeDiffViewCtrl;
@property (nonatomic, strong) UINavigationController *navTime;

@property (nonatomic, strong) UINavigationController *loginNavCtrl;
@property (nonatomic, strong) NSMutableArray         *photoArray;
@property (nonatomic, strong) NSMutableArray         *selectArry;
+(AppDelegate *)sharedAppDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

