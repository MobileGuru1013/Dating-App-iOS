//
//  LocationPickerViewController.h
//  Project6
//
//  Created by superman on 3/12/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"

@protocol LocationPickerViewControllerDelegate;

@interface LocationPickerViewController : UIViewController
@property (nonatomic, strong) id<LocationPickerViewControllerDelegate> delegate;

@end

@protocol LocationPickerViewControllerDelegate <NSObject>

- (void)saveBtnClicked:(NSString *) city location:(CLLocation*) location;

@end