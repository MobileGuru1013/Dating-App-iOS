//
//  EthicBeliefPickerViewController.h
//  Project6
//
//  Created by superman on 3/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"

@protocol EthicBeliefPickerViewControllerDelegate;

@interface EthicBeliefPickerViewController : UIViewController

@property (nonatomic, assign) BOOL isEthic;
@property (nonatomic, strong) NSString *contentStr;

@property (nonatomic, strong) id<EthicBeliefPickerViewControllerDelegate> delegate;

@end

@protocol EthicBeliefPickerViewControllerDelegate <NSObject>

- (void)ethicBeliefControllerSaveBtnClicked:(NSString *) resultStr isEthic:(BOOL) isEthic;

@end
