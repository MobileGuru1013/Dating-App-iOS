//
//  AppDelegate.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MatchesViewController.h"
#import "LeftMenuViewController.h"
#import "LoginViewController.h"
#import "RightMenuViewController.h"
#import "RootMatchViewController.h"
#import "KIProgressViewManager.h"
#import "KIProgressView.h"
#import "GlobalPool.h"
#import "RootFriendProfileViewController.h"

#define IAP25  @"com.kenneth.project6.iap25"
#define IAP250 @"com.kenneth.project6.iap250"
#define IAP500 @"com.kenneth.project6.iap500"
#define IAP50  @"com.kenneth.project6.iap25"

@interface AppDelegate ()

@property (assign, nonatomic) INTULocationAccuracy desiredAccuracy;
@property (assign, nonatomic) NSTimeInterval timeout;

@property (assign, nonatomic) INTULocationRequestID locationRequestID;

@end

@implementation AppDelegate
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.photoArray = [[NSMutableArray alloc] init];
    self.selectArry = [[NSMutableArray alloc] init];
//    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"qGIWLEgcKXJpZIwOkknlNiWEnr5s4M0kOEEaHFgW"
                  clientKey:@"oqA1wqM7ll5Tky4hieko3FdVcLzwsdqjVTkU2Uu7"];
    
    [PFFacebookUtils initializeFacebook];
    [PFImageView class];
//    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
//    {
//        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
//        [application registerUserNotificationSettings:settings];
//        [application registerForRemoteNotifications];
//    }
    application.applicationIconBadgeNumber = 0;

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [PFImageView class];
    
//    [[GlobalPool sharedInstance] loadStaticValues];
    
    [DataManager SharedDataManager].managedObjectContext = [self managedObjectContext];

    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [[KIProgressViewManager manager] setPosition:KIProgressViewPositionTop];
    // Set the color
    
    [[KIProgressViewManager manager] setColor:COLOR_Border];
    
    // Set the gradient
    [[KIProgressViewManager manager] setGradientStartColor:[UIColor blackColor]];
    [[KIProgressViewManager manager] setGradientEndColor:[UIColor whiteColor]];
    
    // Currently not supported
    [[KIProgressViewManager manager] setStyle:KIProgressViewStyleRepeated];
    
    [[MKStoreKit sharedKit] startProductRequest];
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                      NSString *identifier = [note object];
                                                      NSString *krones;
                                                      
                                                      if([identifier isEqualToString:IAP25]) {
                                                          krones = @"25";
                                                      }
                                                      if([identifier isEqualToString:IAP250]) {
                                                          krones = @"250";
                                                      }
                                                      if([identifier isEqualToString:IAP500]) {
                                                          krones = @"500";
                                                      }
                                                      if([identifier isEqualToString:IAP50]) {
                                                          krones = @"50";
                                                      }
                                                      
                                                      int currentVal = [[PFUser currentUser][PF_USER_CRONES] intValue];
                                                      currentVal = currentVal + krones.intValue;
                                                      if(currentVal>=0) {
                                                          [PFUser currentUser][PF_USER_CRONES] = [NSNumber numberWithInt:currentVal];
                                                          [[PFUser currentUser] saveInBackground];
                                                          
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Restored Purchases");
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                  }];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:COLOR_TINT];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setBarTintColor:COLOR_BACKGROUND];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    
    RootMatchViewController *matchesView = [[RootMatchViewController alloc] init];

    UINavigationController *matchNavCtrl = [[UINavigationController alloc] initWithRootViewController:matchesView];

    LeftMenuViewController *leftView = [[LeftMenuViewController alloc] init];
    
    self.sideMenuViewCtrl = [[RESideMenu alloc] initWithContentViewController:matchNavCtrl leftMenuViewController:leftView rightMenuViewController:nil];

    self.sideMenuViewCtrl.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
    self.sideMenuViewCtrl.contentViewShadowColor = [UIColor blackColor];
    self.sideMenuViewCtrl.contentViewShadowOffset = CGSizeMake(0, 0);
    self.sideMenuViewCtrl.contentViewShadowOpacity = 0.6;
    self.sideMenuViewCtrl.contentViewShadowRadius = 12;
    self.sideMenuViewCtrl.contentViewShadowEnabled = YES;
    
    self.timeDiffViewCtrl = [[TimeDiffViewController alloc] init];
    self.navTime = [[UINavigationController alloc] initWithRootViewController:self.timeDiffViewCtrl];
    
    LoginViewController *loginView = [[LoginViewController alloc] init];
    
    if([PFUser currentUser]) {

        ParsePushUserAssign();
        
        self.loginNavCtrl = [[UINavigationController alloc] init];
        [self.loginNavCtrl setViewControllers:@[loginView,self.sideMenuViewCtrl]];
        
    } else {
        self.loginNavCtrl = [[UINavigationController alloc] initWithRootViewController:loginView];

    }
    self.loginNavCtrl.navigationBarHidden = YES;
    self.window.rootViewController = self.loginNavCtrl;

    [self trackingLocation];
    [self scheduleNotification];
    
    self.window.backgroundColor = COLOR_MENU;
    [self.window makeKeyAndVisible];

    return YES;

}

+ (AppDelegate*)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}



- (void)checkTimeDifference {
    //Time Difference
    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//
//    NSURL *url = [NSURL URLWithString:@"http://www.timeapi.org/utc/now"];
//    NSString *str = [[NSString alloc] initWithContentsOfURL:url usedEncoding:Nil error:Nil];
//    
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//    NSDate *date = [dateFormatter dateFromString:str];
//    
//    NSLog(@"%f",[[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970]);
//
//    float sDiff = [[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970];
//    
//    if(abs(sDiff)>30.0)
//        [window addSubview:self.navTime.view];
//    else
//        [self.navTime.view removeFromSuperview];
}

#pragma mark -
#pragma mark Location Manager Tracking

- (void)trackingLocation {
    self.desiredAccuracy = INTULocationAccuracyCity;
    self.timeout = 30.0;
    self.locationRequestID = NSNotFound;
    [self startSingleLocationRequest];
}
- (void)startSingleLocationRequest
{
    __weak __typeof(self) weakSelf = self;
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:self.desiredAccuracy
                                                                timeout:self.timeout
                                                   delayUntilAuthorized:YES
                                                                  block:
                              ^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                  __typeof(weakSelf) strongSelf = weakSelf;
                                  
                                  if (status == INTULocationStatusSuccess) {
                                      // achievedAccuracy is at least the desired accuracy (potentially better)
                                      [GlobalPool sharedInstance].location = currentLocation;
                                      [self getReverseGeocode];
                                  }
                                  else if (status == INTULocationStatusTimedOut) {

                                  }
                                  else {
                                  }
                                  
                                  strongSelf.locationRequestID = NSNotFound;
                              }];
}
- (void) getReverseGeocode
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    if([GlobalPool sharedInstance].location != nil)
    {
        CLLocationCoordinate2D myCoOrdinate;
        myCoOrdinate = [GlobalPool sharedInstance].location.coordinate;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:myCoOrdinate.latitude longitude:myCoOrdinate.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (error)
             {
                 NSLog(@"failed with error: %@", error);
                 [GlobalPool sharedInstance].cityName = @"City Not founded";
                 return;
             }
             if(placemarks.count > 0)
             {
                 NSString *MyAddress = @"";
                 NSString *city = @"";
                 CLPlacemark *placemark = [placemarks firstObject];
                 
                 if([placemark.addressDictionary objectForKey:@"FormattedAddressLines"] != NULL)
                     MyAddress = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                 else
                     MyAddress = @"Address Not founded";
                 
                 if([placemark.addressDictionary objectForKey:@"SubAdministrativeArea"] != NULL)
                     city = [placemark.addressDictionary objectForKey:@"SubAdministrativeArea"];
                 else if([placemark.addressDictionary objectForKey:@"City"] != NULL)
                     city = [placemark.addressDictionary objectForKey:@"City"];
                 else if([placemark.addressDictionary objectForKey:@"Country"] != NULL)
                     city = [placemark.addressDictionary objectForKey:@"Country"];
                 else
                     city = @"City Not founded";
                 [GlobalPool sharedInstance].cityName =  [NSString stringWithFormat:@"%@,%@",city,placemark.administrativeArea];
                 return;
             }
         }];
    } else {
        [GlobalPool sharedInstance].cityName = @"City Not founded";
    }
    
}

- (void)scheduleNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    Class cls = NSClassFromString(@"UILocalNotification");
    if (cls != nil) {
        
        UILocalNotification *notif = [[cls alloc] init];
        notif.fireDate = [[NSDate date] dateAtEndOfDay];
        notif.timeZone = [NSTimeZone defaultTimeZone];
        
        notif.alertBody = @"Today's New Matches are available. Please open the app to keep matches.";
        notif.alertAction = @"Show me";
        notif.soundName = UILocalNotificationDefaultSoundName;
        notif.applicationIconBadgeNumber = 1;
        
        notif.repeatInterval = NSCalendarUnitDay;
        
        NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"Today's New Matches are available. Please open the app to keep matches."
                                                             forKey:kRemindMeNotificationDataKey];
        notif.userInfo = userDict;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }

}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;

}
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
    // UIApplicationState state = [application applicationState];
    // if (state == UIApplicationStateInactive) {
    
    // Application was in the background when notification
    // was delivered.
    // }
    
    application.applicationIconBadgeNumber = 0;
    NSString *reminderText = [notification.userInfo
                              objectForKey:kRemindMeNotificationDataKey];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Today's New Matches are available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alertView show];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveInBackground];
    }
    [self trackingLocation];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];

    [self performSelector:@selector(checkTimeDifference) withObject:nil afterDelay:3.0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[PFFacebookUtils session] close];

}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSString *str_url = [url absoluteString];
    if([str_url containsString:@"project6://"] && [str_url containsString:@"@"]) {
        
        NSString *email_addres = [str_url stringByReplacingOccurrencesOfString:@"project6://" withString:@""];
        NSLog(@"%@",email_addres);
        
        if([PFUser currentUser]) {
            PFQuery *query = [PFUser query];
            [query whereKey:PF_USER_EMAIL equalTo:email_addres];
            [query whereKey:PF_USER_ACTIVATE notEqualTo:[NSNumber numberWithBool:NO]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error) {

                    PFObject *objectUser;
                    objectUser = [objects objectAtIndex:0];
                    NSString *string = [objectUser objectId];
                    
                    NSArray *banArray = objectUser[PF_USER_BANS];
                    
                    if([banArray containsObject:[PFUser currentUser].objectId]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You are banned! Cannot find the user!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [alertView show];
                        
                    }
                    else if ([[PFUser currentUser][PF_USER_BANS] containsObject:string]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You are banned! Cannot find the user!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [alertView show];
                    }
                    else
                    {
                        
                        PFUser *user = [objects firstObject];
                        
                        RootFriendProfileViewController *rootFriendViewCtrl = [[RootFriendProfileViewController alloc] init];
                        
                        rootFriendViewCtrl.user = user;
                        
                        rootFriendViewCtrl.isDeepLink = YES;
                        
                        rootFriendViewCtrl.type = 3;
                        
                        LoginViewController *loginView = [[LoginViewController alloc] init];
                        
                        [self.loginNavCtrl setViewControllers:@[loginView,self.sideMenuViewCtrl,rootFriendViewCtrl]];
                        
                        self.loginNavCtrl.navigationBarHidden = NO;
                    
                    }
                   
                }
            }];
            
            
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Please login Project6 with Facebook" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
        }
        
        return YES;
    } else {
        return [FBAppCall handleOpenURL:url
                      sourceApplication:sourceApplication
                            withSession:[PFFacebookUtils session]];
    }
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //[PFPush handlePush:userInfo];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if ([PFUser currentUser] != nil)
    {
        //[self performSelector:@selector(refreshMessagesView) withObject:nil afterDelay:4.0];
    }
    
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.glenn.Project6" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Project6" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Project6.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
