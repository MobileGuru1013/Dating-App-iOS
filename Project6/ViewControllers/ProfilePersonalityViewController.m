//
//  ProfilePersonalityViewController.m
//  Project6
//
//  Created by superman on 2/21/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ProfilePersonalityViewController.h"
#import "QuestionValueViewAdjust.h"
#import "AnswersViewController.h"

@interface ProfilePersonalityViewController ()<UIAlertViewDelegate>
{
    UIScrollView *backScrollView;
    int QuestionCount;
}
@end

@implementation ProfilePersonalityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lblIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.width-20, 90)];
    lblIntroduction.textAlignment = NSTextAlignmentLeft;
    lblIntroduction.textColor = [UIColor lightGrayColor];
    lblIntroduction.font = [UIFont systemFontOfSize:12];
    lblIntroduction.numberOfLines = 10;
    lblIntroduction.text = @"The personality chart is calculated based on the questions you have answered. The following chart reflect how you may fall on each spectrum. For an example, you are more extroverted than introverted.To make the assessment more accurate, you can answer more questions.";
    
    [self.view addSubview:lblIntroduction];
    
    UIButton *answerMoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 105, 160, 32)];
    [answerMoreBtn setTitle:@"Answer More Questions" forState:UIControlStateNormal];
    [answerMoreBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [answerMoreBtn addTarget:self action:@selector(answerMoreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    answerMoreBtn.right = self.view.width/2 - 10;
    answerMoreBtn.backgroundColor = COLOR_BUTTON;
    answerMoreBtn.layer.cornerRadius = 6;
    answerMoreBtn.layer.masksToBounds = YES;
    [answerMoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:answerMoreBtn];
    
    UIButton *answerClearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 105, 160, 32)];
    [answerClearBtn setTitle:@"Forget All Answers" forState:UIControlStateNormal];
    [answerClearBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [answerClearBtn addTarget:self action:@selector(answerClearBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    answerClearBtn.left = self.view.width/2 + 10;
    answerClearBtn.backgroundColor = COLOR_BUTTON;
    answerClearBtn.layer.cornerRadius = 6;
    answerClearBtn.layer.masksToBounds = YES;
    [answerClearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:answerClearBtn];
    
    backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, answerMoreBtn.bottom+20, self.view.width, self.view.height-answerMoreBtn.bottom-20-64-44)];
    [self.view addSubview:backScrollView];
    backScrollView.exclusiveTouch = NO;
    backScrollView.userInteractionEnabled = YES;

    PFQuery *query = [PFQuery queryWithClassName:PF_QUESTION_CLASS_NAME];
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            float yContinious = -34;
            QuestionCount = (int)objects.count;
            for( int i=0; i<objects.count; i++) {
                PFObject *obj = [objects objectAtIndex:i];
                yContinious = yContinious + 34;
                if(i == 4 || i == 7 || i == 12 || i == 15)
                    yContinious+=10;
                QuestionValueViewAdjust *qView1 = [[QuestionValueViewAdjust alloc] initWithFrame:CGRectMake(0, yContinious, self.view.width, 34)];
                qView1.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
                NSString *stringKey = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
                qView1.slider.value = [[PFUser currentUser][stringKey] intValue];
                qView1.lblLeft.text = obj[PF_QUESTION_POSITIVE];
                qView1.lblRight.text = obj[PF_QUESTION_NEGATIVE];
                qView1.tag = i+100;

                [backScrollView addSubview:qView1];
            }
            [backScrollView setContentSize:CGSizeMake(self.view.width, yContinious+34+20)];
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshValues) name:@"QuestionValueChanged" object:nil];

}
- (void)refreshValues {
    for(int i=0; i<QuestionCount; i++) {
        QuestionValueViewAdjust *qView = (QuestionValueViewAdjust*)[backScrollView viewWithTag:i+100];
        NSString *stringKey = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];

        [qView.slider setValue:[[PFUser currentUser][stringKey] intValue] animated:YES];
    }
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
        
        for(int i=0; i<QuestionCount; i++) {
            QuestionValueViewAdjust *qView = (QuestionValueViewAdjust*)[backScrollView viewWithTag:i+100];
            [qView.slider setValue:50.0 animated:YES];
        }

    }
}

@end
