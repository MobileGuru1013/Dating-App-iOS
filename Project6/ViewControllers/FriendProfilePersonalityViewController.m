//
//  FriendProfilePersonalityViewController.m
//  Project6
//
//  Created by superman on 2/21/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "FriendProfilePersonalityViewController.h"
#import "QuestionValueViewAdjust.h"
#import "AnswersViewController.h"

@interface FriendProfilePersonalityViewController ()<UIAlertViewDelegate>
{
    UIScrollView *backScrollView;
}
@end

@implementation FriendProfilePersonalityViewController
- (int)calcComfortablePercent:(PFObject*) object {
    float sum = 0;
    float tsum = 0;
    for(int i=0; i<15; i++) {
        NSString *key = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
        float number_p = [object[key] floatValue];
        float number_m = [[PFUser currentUser][key] floatValue];
        sum+=ABS(number_m-number_p);
        if(i==3) {
            tsum += sum*2;
            sum = 0;
        }
        if(i == 6) {
            tsum += sum*0.6;
            sum = 0;
        }
        if(i == 14) {
            tsum += sum*0.3;
            sum = 0;
        }
    }
    return (1.0-tsum/1500.0)*100.0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[KIProgressViewManager manager] hideProgressView];

    // Do any additional setup after loading the view.
    
    UIImageView *matchBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 64, 64)];
    matchBackImageView.image = [UIImage imageNamed:@"matchMark.png"];
    
    UILabel* matchLbl = [[UILabel alloc] initWithFrame:matchBackImageView.bounds];
    matchLbl.font = [UIFont boldSystemFontOfSize:32];
    matchLbl.textColor = [UIColor whiteColor];
    matchLbl.textAlignment = NSTextAlignmentCenter;
    matchLbl.text = [NSString stringWithFormat:@"%d",[self calcComfortablePercent:self.user]];
    matchLbl.shadowColor = COLOR_IN_DARK_GRAY;
    matchLbl.shadowOffset = CGSizeMake(1, 1);

    matchBackImageView.centerX = self.view.width/2;
    
    [self.view addSubview:matchBackImageView];
    [matchBackImageView addSubview:matchLbl];
    
    UILabel *lblIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(10, matchBackImageView.bottom, self.view.width-20, 90)];
    lblIntroduction.textAlignment = NSTextAlignmentLeft;
    lblIntroduction.textColor = [UIColor lightGrayColor];
    lblIntroduction.font = [UIFont systemFontOfSize:12];
    lblIntroduction.numberOfLines = 10;
    
    if([self.user[PF_USER_GENDER] isEqualToString:@"Male"])
        lblIntroduction.text = @"The personality chart and the match score are calculated based on the questions he has answered. For an example, he may be more Artsy than most men around him ago. To increase accuracy on the match score between you and him, you can always answer more questions.";
    else
        lblIntroduction.text = @"The personality chart and the match score are calculated based on the questions she has answered. For an example, she may be more Artsy than most women around her ago. To increase accuracy on the match score between you and her, you can always answer more questions.";
    
    [self.view addSubview:lblIntroduction];
    
    UIButton *answerMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, lblIntroduction.bottom+10, 160, 32)];
    [answerMoreBtn setTitle:@"Answer More Questions" forState:UIControlStateNormal];
    [answerMoreBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [answerMoreBtn addTarget:self action:@selector(answerMoreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    answerMoreBtn.centerX = self.view.width/2;
    answerMoreBtn.backgroundColor = COLOR_BUTTON;
    answerMoreBtn.layer.cornerRadius = 6;
    answerMoreBtn.layer.masksToBounds = YES;
    [answerMoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.view addSubview:answerMoreBtn];
    
    backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, answerMoreBtn.bottom+20, self.view.width, self.view.height-answerMoreBtn.bottom-20-64-44)];
    [self.view addSubview:backScrollView];
    backScrollView.exclusiveTouch = NO;
    backScrollView.userInteractionEnabled = YES;

    PFQuery *query = [PFQuery queryWithClassName:PF_QUESTION_CLASS_NAME];
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            float yContinious = -34;
            for( int i=0; i<objects.count; i++) {
                PFObject *obj = [objects objectAtIndex:i];
                yContinious = yContinious + 34;
                if(i == 4 || i == 7 || i == 12 || i == 15)
                    yContinious+=10;
                QuestionValueViewAdjust *qView1 = [[QuestionValueViewAdjust alloc] initWithFrame:CGRectMake(0, yContinious, self.view.width, 34)];
                qView1.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
                NSString *stringKey = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
                qView1.slider.value = [self.user[stringKey] intValue];
                qView1.lblLeft.text = obj[PF_QUESTION_POSITIVE];
                qView1.lblRight.text = obj[PF_QUESTION_NEGATIVE];
                [backScrollView addSubview:qView1];
                qView1.tag = i;
//                [qView1.slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
            }
            [backScrollView setContentSize:CGSizeMake(self.view.width, yContinious+34+20)];
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
    
}
- (void)sliderMoved:(UISlider*)sender {
    NSString *stringKey = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,(int)sender.tag];
    [[PFUser currentUser] setValue:[NSNumber numberWithInt:sender.value] forKey:stringKey];
    [[PFUser currentUser] saveInBackground];
}
- (void)answerMoreBtnClicked {
    AnswersViewController *answerViewCtrl = [[AnswersViewController alloc] init];
    [self.navigationController pushViewController:answerViewCtrl animated:YES];
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)answerClearBtnClicked {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You can not recover previous answers. Want to proceed?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok" , nil];
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(buttonIndex == 1) {

        for(int i=0; i<15; i++) {
            NSString *key = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
            [[PFUser currentUser] setValue:[NSNumber numberWithInt:50] forKey:key];
        }
        [[PFUser currentUser] removeObjectForKey:PF_USER_QUESTIONNAIRE];
        [[PFUser currentUser] removeObjectForKey:PF_USER_QUESTIONNAIRE_MY_ANSWER];
        [[PFUser currentUser] removeObjectForKey:PF_USER_QUESTIONNAIRE_YOUR_ANSWER];
        
        
        [[PFUser currentUser] saveInBackground];
    }
}

@end
