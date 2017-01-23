//
//  SBPickerSelector.h
//  SBPickerSelector
//
//  Created by Santiago Bustamante on 1/24/14.
//  Copyright (c) 2014 Busta117. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBPickerSelector;

typedef NS_ENUM(NSInteger, SBPickerSelectorType) {
    SBPickerSelectorTypeNumerical = 0,
    SBPickerSelectorTypeDate,
    SBPickerSelectorTypeText,
};

typedef NS_ENUM(NSInteger, SBPickerSelectorDateType) {
    SBPickerSelectorDateTypeDefault = 0,
    SBPickerSelectorDateTypeOnlyDay,
    SBPickerSelectorDateTypeOnlyHour,
};


@protocol SBPickerSelectorDelegate <NSObject>

@optional
-(void) SBPickerSelector:(SBPickerSelector *)selector dateSelected:(NSDate *)date DEPRECATED_MSG_ATTRIBUTE("use pickerSelector:dateSelected");
-(void) SBPickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx DEPRECATED_MSG_ATTRIBUTE("use pickerSelector:selectedValue:index:");
-(void) SBPickerSelector:(SBPickerSelector *)selector intermediatelySelectedValue:(id)value atIndex:(NSInteger)idx DEPRECATED_MSG_ATTRIBUTE("use pickerSelector:intermediatelySelectedValue:atIndex:");
-(void) SBPickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel DEPRECATED_MSG_ATTRIBUTE("use pickerSelector:cancelPicker");

-(void) pickerSelector:(SBPickerSelector *)selector dateSelected:(NSDate *)date;
-(void) pickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx;
-(void) pickerSelector:(SBPickerSelector *)selector intermediatelySelectedValue:(id)value atIndex:(NSInteger)idx;
-(void) pickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel;


@end


@interface SBPickerSelector : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    
    UIViewController *parent_;
    
    UIPopoverController *popOver_;
    CGPoint origin_;
    
}

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIToolbar *optionsToolBar;

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) NSMutableArray *pickerData;
@property (nonatomic, assign) SBPickerSelectorType pickerType;
@property (nonatomic, weak) id<SBPickerSelectorDelegate> delegate;
@property (nonatomic, assign) int numberOfComponents;
@property (nonatomic, weak) id pickerId;
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) BOOL onlyDayPicker;
@property (nonatomic, assign) SBPickerSelectorDateType datePickerType;
@property (nonatomic, strong) NSDate *defaultDate;
@property (nonatomic, strong) NSString *doneButtonTitle;
@property (nonatomic, strong) NSString *cancelButtonTitle;


+ (instancetype) picker;
+ (instancetype) pickerWithNibName:(NSString*)nibName;
- (void) showPickerIpadFromRect:(CGRect)rect inView:(UIView *)view;
- (void) showPickerOver:(UIViewController *)parent;


@end
