//
//  ProfileQuestionsViewController.m
//  Project6
//
//  Created by superman on 2/21/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ProfileQuestionsViewController.h"
#import "QuestionValueView.h"

@interface ProfileQuestionsViewController ()
{
    UIScrollView *backScrollView;
}
@end

@implementation ProfileQuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    BorderButton *answerMoreBtn = [[BorderButton alloc] initWithFrame:CGRectMake(0, 20, 160, 32)];
//    [answerMoreBtn setTitle:@"Answer More Questions" forState:UIControlStateNormal];
//    [answerMoreBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
//    [answerMoreBtn addTarget:self action:@selector(answerMoreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    answerMoreBtn.centerX = self.view.width/2;
//    [self.view addSubview:answerMoreBtn];

    backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, self.view.height-20-64-44)];
    [self.view addSubview:backScrollView];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_QUESTION_CLASS_NAME];
    [[KIProgressViewManager manager] showProgressOnView:self.view];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            float yContinious = -34;
            for( int i=0; i<objects.count; i++) {
                PFObject *obj = [objects objectAtIndex:i];
                yContinious += 34;
                if(i == 4 || i == 7 || i == 12 || i == 15)
                    yContinious+=10;
                QuestionValueView *qView1 = [[QuestionValueView alloc] initWithFrame:CGRectMake(0, yContinious, self.view.width, 34)];
                qView1.backgroundColor = COLOR_SECOND;
                NSString *stringKey = [NSString stringWithFormat:@"%@%d",PF_USER_Q_,i];
                qView1.lblCenter.text = [NSString stringWithFormat:@"%d",[self.user[stringKey] intValue]];
                qView1.lblLeft.text = obj[PF_QUESTION_POSITIVE];
                qView1.lblRight.text = obj[PF_QUESTION_NEGATIVE];
                qView1.tag = i+100;
                [backScrollView addSubview:qView1];
            }
            [backScrollView setContentSize:CGSizeMake(self.view.width, yContinious+34+20)];
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionValueChanged:) name:@"QuestionValueChanged" object:nil];

    // Do any additional setup after loading the view.
}
- (void)answerMoreBtnClicked {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)questionValueChanged:(NSNotification*) notification {
    NSLog(@"%@",notification.object);
    NSDictionary *dictSender = notification.object;
    int tag = [[dictSender valueForKey:@"tag"] intValue];
    int value = [[dictSender valueForKey:@"value"] intValue];
    QuestionValueView *qView = (QuestionValueView*)[backScrollView viewWithTag:tag+100];
    qView.lblCenter.text = [NSString stringWithFormat:@"%d",value];
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
