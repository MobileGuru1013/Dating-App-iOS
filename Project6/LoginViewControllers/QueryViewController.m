//
//  QueryViewController.m
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "QueryViewController.h"
#import "Public.h"
#import "BorderButton.h"
#import "SBPickerSelector.h"
#import "AppDelegate.h"
#import "GlobalPool.h"

@interface QueryViewController () <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
{
    BOOL isMale;
    int step;
    int mileIndex;
}
@property (nonatomic, strong) UIView *backCaseView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *distanceTableView;
@property (nonatomic, strong) UIImageView *genderMark;
@property (nonatomic, strong) UILabel *lblIam;
@property (nonatomic, strong) UITextField *zipCodeTextField;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UITextView *desTextView;

@end

@implementation QueryViewController
@synthesize backCaseView;

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    step = 0;
    
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backImageView.image = [UIImage imageNamed:@"loginBack.png"];
    
    [self.view addSubview:backImageView];

    self.backCaseView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 130, self.view.width-40, self.view.height-130-40)];
    backCaseView.userInteractionEnabled = YES;
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = backCaseView.bounds;
    [backCaseView addSubview:visualEffectView];
    backCaseView.layer.cornerRadius = 6;
    backCaseView.layer.masksToBounds = YES;
    [self.view addSubview:backCaseView];

    self.genderMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 128, 128)];
    [self.genderMark setImage:[UIImage imageNamed:@"genderMark.png"]];
    self.genderMark.centerX = backCaseView.width/2;
    self.genderMark.top = 20;
    [backCaseView addSubview:self.genderMark];
    
    self.lblIam = [[UILabel alloc] initWithFrame:CGRectMake(10, self.genderMark.bottom+10, backCaseView.width-20, 44)];
    self.lblIam.text = @"I am a:";
    self.lblIam.textColor = [UIColor whiteColor];
    self.lblIam.numberOfLines = 2;
    self.lblIam.textAlignment = NSTextAlignmentCenter;
    self.lblIam.font = [UIFont boldSystemFontOfSize:18];
    
    [backCaseView addSubview:self.lblIam];
    
    self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.lblIam.bottom, backCaseView.width-20, 44)];
    self.detailLabel.text = @"We recommend keeping the distance at 25 miles or more. Been to narrow can affect the number of matches you can get.";
    self.detailLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.detailLabel.numberOfLines = 3;
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.font = [UIFont boldSystemFontOfSize:12];

    self.zipCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, self.lblIam.bottom+40, backCaseView.width-40, 36)];
    self.zipCodeTextField.placeholder = @"Current City or Zipcode";
    self.zipCodeTextField.textAlignment = NSTextAlignmentCenter;
    self.zipCodeTextField.alpha = 0.0;
    self.zipCodeTextField.backgroundColor = [UIColor clearColor];
    self.zipCodeTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.zipCodeTextField.layer.borderWidth = 1.0;
    self.zipCodeTextField.layer.cornerRadius = 6.0;
    self.zipCodeTextField.layer.masksToBounds = YES;
    self.zipCodeTextField.textColor = [UIColor whiteColor];
    [self.zipCodeTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.zipCodeTextField addTarget:self action:@selector(textFieldBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self.zipCodeTextField addTarget:self action:@selector(textFieldEnded:) forControlEvents:UIControlEventEditingDidEndOnExit];

    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, self.lblIam.bottom+40, backCaseView.width-40, 36)];
    self.nameTextField.placeholder = @"Type Here";
    self.nameTextField.textAlignment = NSTextAlignmentCenter;
    self.nameTextField.alpha = 0.0;
    self.nameTextField.backgroundColor = [UIColor clearColor];
    self.nameTextField.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.nameTextField.layer.borderWidth = 1.0;
    self.nameTextField.layer.cornerRadius = 6.0;
    self.nameTextField.layer.masksToBounds = YES;
    self.nameTextField.textColor = [UIColor whiteColor];
    [self.nameTextField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.nameTextField addTarget:self action:@selector(textFieldBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self.nameTextField addTarget:self action:@selector(textFieldEnded:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    BorderButton *btnNext = [[BorderButton alloc] initWithFrame:CGRectMake(50, backCaseView.height-50, backCaseView.width-100, 36)];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(btnNextClicked) forControlEvents:UIControlEventTouchUpInside];
    [backCaseView addSubview:btnNext];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.lblIam.bottom+10,backCaseView.width,80) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.tag = 10;
        tableView.backgroundView = nil;
        tableView.bounces = NO;
        tableView;
    });
    [backCaseView addSubview:self.tableView];
    
    self.distanceTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.lblIam.bottom+10,backCaseView.width,90) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.backgroundView = nil;
        tableView.tag = 11;
        tableView.bounces = NO;
        
        tableView;
    });
    
    self.desTextView = ({
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, self.detailLabel.bottom, backCaseView.width-40, btnNext.top-self.detailLabel.bottom)];
        textView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        textView.opaque = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.bounces = NO;
        textView.layer.borderColor = [[UIColor whiteColor] CGColor];
        textView.layer.borderWidth = 1.0;
        textView.layer.cornerRadius = 6.0;
        textView.layer.masksToBounds = YES;
        textView.textColor = [UIColor whiteColor];
        textView.delegate = self;
        textView;
    });
    
    UITapGestureRecognizer *tap_ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackClicked:)];
    [self.view addGestureRecognizer:tap_ges];
    [tap_ges setCancelsTouchesInView:NO];
    
    if(self.fbData) {
        if([[self.fbData valueForKey:@"gender"] isEqualToString:@"male"])
            isMale = YES;
        else
            isMale = NO;
        [[PFUser currentUser] setValue:[NSNumber numberWithInt:150] forKey:PF_USER_CRONES];
        [[PFUser currentUser] setValue:[self.fbData valueForKey:@"pictureURL"] forKey:PF_USER_PICTURE];
        [[PFUser currentUser] setValue:[self.fbData valueForKey:@"email"] forKey:PF_USER_EMAIL];
        if([[self.fbData valueForKey:@"birthday"] isEqualToString:@"na"])
            [[PFUser currentUser] setValue:[NSDate dateWithDaysBeforeNow:365*24] forKey:PF_USER_BIRTHDAY];
        else
            [[PFUser currentUser] setValue:[NSDate getNSDateFromBirthday:[self.fbData valueForKey:@"birthday"]] forKey:PF_USER_BIRTHDAY];
        [[PFUser currentUser] setValue:[NSNumber numberWithInt:18] forKey:PF_USER_L_MINAGE];
        [[PFUser currentUser] setValue:[NSNumber numberWithInt:55] forKey:PF_USER_L_MAXAGE];
        [[PFUser currentUser] setValue:[NSArray array] forKey:PF_USER_ETHNICITY];
        [[PFUser currentUser] setValue:[NSArray array] forKey:PF_USER_BELIEF];
        
        [[PFUser currentUser] setObject:[PFGeoPoint geoPointWithLocation:[GlobalPool sharedInstance].location] forKey:PF_USER_GEOLOCATION];
        for(int i=0; i<15; i++) {
            NSString *stringKey = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
            [[PFUser currentUser] setValue:[NSNumber numberWithInt:50] forKey:stringKey];
        }
        
        mileIndex = 1;

    } else {
        if([[[PFUser currentUser] valueForKey:PF_USER_GENDER] isEqualToString:@"Male"])
            isMale = YES;
        else
            isMale = NO;
        NSArray *titles = @[@"10 miles",@"25 miles",@"50 miles"];
        mileIndex = (int)[titles indexOfObject:[[PFUser currentUser] valueForKey:PF_USER_L_DISTANCE]];
    }
    // Do any additional setup after loading the view.
}
- (void)tapBackClicked:(id) sender {
    [UIView animateWithDuration:0.4 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
    [self.view endEditing:YES];
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.4 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -160);
    }];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.4 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}
- (void)textFieldBegin:(UITextField*) sender{
    [UIView animateWithDuration:0.4 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, -160);
    }];
}
- (void)textFieldEnded:(UITextField*) sender{
    [UIView animateWithDuration:0.4 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnNextClicked {
    step++;
    if(step == 1) {
        [UIView animateWithDuration:0.4 animations:^{
            self.genderMark.alpha = 0.0;
            self.lblIam.alpha = 0.0;
            self.tableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            if(isMale) {
                [[PFUser currentUser] setValue:@"Male" forKey:PF_USER_GENDER];
            } else {
                [[PFUser currentUser] setValue:@"Female" forKey:PF_USER_GENDER];
            }
            
            isMale = !isMale;
            
            [self.tableView reloadData];
            
            [self.genderMark setImage:[[UIImage imageNamed:@"magnificantIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.genderMark setTintColor:[UIColor colorWithRed:142.0/255.0 green:152.0/255.0 blue:204.0/255.0 alpha:1.0]];
            self.lblIam.text = @"I am looking for:";
            if(finished) {
                [UIView animateWithDuration:0.4 animations:^{
                    self.genderMark.alpha = 1.0;
                    self.lblIam.alpha = 1.0;
                    self.tableView.alpha = 1.0;

                } completion:^(BOOL finished) {
                    if(finished) {
                        
                    }
                }];

            }
        }];
    } else if(step == 2) {
        
        if(isMale) {
            [[PFUser currentUser] setValue:@"Male" forKey:PF_USER_L_GENDER];
        } else {
            [[PFUser currentUser] setValue:@"Female" forKey:PF_USER_L_GENDER];
        }
        
        [UIView animateWithDuration:0.4 animations:^{
            self.genderMark.alpha = 0.0;
            self.lblIam.alpha = 0.0;
            self.tableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.tableView.hidden = YES;
            [self.genderMark setImage:[[UIImage imageNamed:@"worldIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.genderMark setTintColor:[UIColor colorWithRed:142.0/255.0 green:152.0/255.0 blue:204.0/255.0 alpha:1.0]];
            self.lblIam.text = @"Where are you?";
            [self.backCaseView addSubview:self.zipCodeTextField];
            if(finished) {
                
                if(self.fbData)
                    self.zipCodeTextField.text = [self.fbData valueForKey:@"location"];
                else
                    self.zipCodeTextField.text = [[PFUser currentUser] valueForKey:PF_USER_ZIPCODE];

                
                [UIView animateWithDuration:0.4 animations:^{
                    self.genderMark.alpha = 1.0;
                    self.lblIam.alpha = 1.0;
                    self.zipCodeTextField.alpha = 1.0;
                    

                } completion:^(BOOL finished) {
                    if(finished) {
                    }
                }];
                
            }
        }];
    } else if(step == 3) {
        
        [[PFUser currentUser] setValue:self.zipCodeTextField.text forKey:PF_USER_ZIPCODE];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.genderMark.alpha = 0.0;
            self.lblIam.alpha = 0.0;
            self.zipCodeTextField.alpha = 0.0;
            self.distanceTableView.alpha = 0.0;
            isMale = YES;
            [self.tableView reloadData];
        } completion:^(BOOL finished) {
            self.zipCodeTextField.hidden = YES;
            [self.genderMark setImage:[[UIImage imageNamed:@"worldIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.genderMark setTintColor:[UIColor colorWithRed:142.0/255.0 green:152.0/255.0 blue:204.0/255.0 alpha:1.0]];
            self.lblIam.text = @"How close do you expect your\nmatch to be?";
            [self.backCaseView addSubview:self.detailLabel];
            
            [backCaseView addSubview:self.distanceTableView];
            self.distanceTableView.top = self.detailLabel.bottom;
            
            if(finished) {
                [UIView animateWithDuration:0.4 animations:^{
                    self.genderMark.alpha = 1.0;
                    self.lblIam.alpha = 1.0;
                    self.distanceTableView.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    if(finished) {
                        self.distanceTableView.delegate = self;
                        [self.distanceTableView reloadData];
                    }
                }];
                
            }
        }];
    } else if(step == 4) {
        
        NSArray *titles = @[@"10 miles",@"25 miles",@"50 miles"];
        [[PFUser currentUser] setValue:[titles objectAtIndex:mileIndex] forKey:PF_USER_L_DISTANCE];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.genderMark.alpha = 0.0;
            self.lblIam.alpha = 0.0;
            self.distanceTableView.alpha = 0.0;
            self.detailLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.distanceTableView.hidden = YES;
            self.detailLabel.hidden = YES;
            [self.genderMark setImage:[[UIImage imageNamed:@"profileNameIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.genderMark setTintColor:[UIColor colorWithRed:142.0/255.0 green:152.0/255.0 blue:204.0/255.0 alpha:1.0]];
            self.lblIam.text = @"Pick a display name:";
            self.lblIam.numberOfLines = 1;
            self.nameTextField.alpha = 0.0;
            [self.backCaseView addSubview:self.nameTextField];
            if(finished) {
                
                if(self.fbData)
                    self.nameTextField.text = [self.fbData valueForKey:@"name"];
                else
                    self.nameTextField.text = [[PFUser currentUser] valueForKey:PF_USER_FULLNAME];
                
                [UIView animateWithDuration:0.4 animations:^{
                    self.genderMark.alpha = 1.0;
                    self.lblIam.alpha = 1.0;
                    self.nameTextField.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    if(finished) {
                    }
                }];
                
            }
        }];
    } else if(step == 5) {
        
        [[PFUser currentUser] setValue:self.nameTextField.text forKey:PF_USER_FULLNAME];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.genderMark.alpha = 0.0;
            self.lblIam.alpha = 0.0;
            self.detailLabel.alpha = 0.0;
            self.nameTextField.alpha = 0.9;
        } completion:^(BOOL finished) {
            self.nameTextField.hidden = YES;
            self.distanceTableView.hidden = YES;
            self.detailLabel.hidden = NO;
            self.detailLabel.text = @"(Be creative!!)";
            self.detailLabel.numberOfLines = 1;
            self.detailLabel.alpha = 0.0;
            self.detailLabel.top = self.lblIam.bottom-10;
            [self.genderMark setImage:[[UIImage imageNamed:@"resumeProfileIcon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self.genderMark setTintColor:[UIColor colorWithRed:142.0/255.0 green:152.0/255.0 blue:204.0/255.0 alpha:1.0]];
            self.lblIam.text = [GlobalPool sharedInstance].about_me;
            self.lblIam.numberOfLines = 2;
            self.desTextView.alpha = 0.0;
            self.desTextView.top = self.detailLabel.bottom;
            [self.backCaseView addSubview:self.desTextView];
            if(finished) {
                
                if(!self.fbData)
                    self.desTextView.text = [[PFUser currentUser] valueForKey:PF_USER_ABOUT_ME];
                
                [UIView animateWithDuration:0.4 animations:^{
                    self.genderMark.alpha = 1.0;
                    self.lblIam.alpha = 1.0;
                    self.detailLabel.alpha = 1.0;
                    self.desTextView.alpha = 1.0;
                } completion:^(BOOL finished) {
                    if(finished) {
                        
                    }
                }];
                
            }
        }];
    } else if(step ==6) {
        [[PFUser currentUser] setValue:self.desTextView.text forKey:PF_USER_ABOUT_ME];
        [[PFUser currentUser] saveInBackground];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.lblIam.alpha = 0.0;
            self.detailLabel.alpha = 0.0;
            self.nameTextField.alpha = 0.0;
            self.desTextView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            if(finished) {
                self.lblIam.text = [GlobalPool sharedInstance].about_life;
                self.desTextView.text = @"";
                [UIView animateWithDuration:0.4 animations:^{
                    self.lblIam.alpha = 1.0;
                    self.detailLabel.alpha = 1.0;
                    self.nameTextField.alpha = 1.0;
                    self.desTextView.alpha = 1.0;
                }];
            }
        }];
        
    } else if(step ==7) {
        [[PFUser currentUser] setValue:self.desTextView.text forKey:PF_USER_ABOUT_LIFE];
        [[PFUser currentUser] saveInBackground];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.lblIam.alpha = 0.0;
            self.detailLabel.alpha = 0.0;
            self.nameTextField.alpha = 0.0;
            self.desTextView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            if(finished) {
                self.lblIam.text = [GlobalPool sharedInstance].about_you;
                self.desTextView.text = @"";
                [UIView animateWithDuration:0.4 animations:^{
                    self.lblIam.alpha = 1.0;
                    self.detailLabel.alpha = 1.0;
                    self.nameTextField.alpha = 1.0;
                    self.desTextView.alpha = 1.0;
                }];
            }
        }];
    } else if(step == 8) {
        
        [[PFUser currentUser] setValue:self.desTextView.text forKey:PF_USER_ABOUT_YOU];
        [[PFUser currentUser] saveInBackground];
        
        if(!self.fbData) {
            [self.navigationController popViewControllerRetro];
        } else {
            [self.navigationController pushViewControllerRetro:[(AppDelegate*)[UIApplication sharedApplication].delegate sideMenuViewCtrl]];
        }

    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == 10)
        return 40;
    else
        return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if(tableView.tag == 10)
        return 2;
    else
        return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
        
    }
    if(tableView.tag == 10) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if(isMale) {
            if(indexPath.row == 0)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;

        } else {
            if(indexPath.row == 1)
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
            
        NSArray *titles = @[@"Male", @"Female"];
        cell.textLabel.text = titles[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        
    } else {
        NSArray *titles = @[@"10 miles",@"25 miles",@"50 miles"];
        cell.textLabel.text = titles[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if(mileIndex == indexPath.row)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
     }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.tag == 10) {
        if(indexPath.row == 0) {
            isMale = YES;
        } else {
            isMale = NO;
        }
    } else {
        mileIndex = (int)indexPath.row;
    }
    [tableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
