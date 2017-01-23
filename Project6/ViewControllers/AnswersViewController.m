//
//  AnswersViewController.m
//  Project6
//
//  Created by superman on 3/27/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "AnswersViewController.h"
#import "BorderButton.h"

@interface AnswersViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *contentTableView;
    BOOL isMyYes;
    BOOL isYourYes;
    UILabel *lblAnswers;
    NSMutableArray *tempArray;
    UILabel *lblQuestion;
    
    PFObject *tempQuestion;
    
    int indexMyAnswer;
    int indexYourAnswer;
    NSMutableArray *indexYourAnswer_Array;
}
@end

@implementation AnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Questionnaire";
    self.view.backgroundColor = [UIColor whiteColor];
    
    lblAnswers = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 70)];
    lblAnswers.font = [UIFont boldSystemFontOfSize:18];
    lblAnswers.text = @"";
    lblAnswers.textAlignment = NSTextAlignmentCenter;
    lblAnswers.backgroundColor = [UIColor colorWithRed:171.0/255.0 green:108.0/255.0 blue:196.0/255.0 alpha:1.0];
    lblAnswers.textColor = [UIColor whiteColor];
    [self.view addSubview:lblAnswers];
    
    
    lblQuestion = [[UILabel alloc] initWithFrame:CGRectMake(0, lblAnswers.bottom, self.view.width, 100)];
    lblQuestion.font = [UIFont boldSystemFontOfSize:16];
    lblQuestion.text = @"";
    lblQuestion.numberOfLines = 5;
    lblQuestion.textAlignment = NSTextAlignmentCenter;
    lblQuestion.contentMode = UIViewContentModeCenter;
    lblQuestion.textColor = COLOR_IN_BLACK;
    lblQuestion.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lblQuestion];
    
    tempArray = [NSMutableArray array];
    
    contentTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, lblQuestion.bottom+40,self.view.width,self.view.height-lblQuestion.bottom-60-40-40) style:UITableViewStyleGrouped];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.tag = 10;
        tableView.backgroundView = nil;
        tableView;
    });
    [self.view addSubview:contentTableView];
    
    UIButton *btnAnswer = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width/2+15, self.view.height-64-60, self.view.width/2-30, 36)];
    [btnAnswer setTitle:@"Answer" forState:UIControlStateNormal];
    [btnAnswer setTintColor:[UIColor whiteColor]];
    [btnAnswer addTarget:self action:@selector(btnAnswerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnAnswer.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [btnAnswer setBackgroundColor:COLOR_BUTTON];
    btnAnswer.layer.cornerRadius = 6;
    btnAnswer.layer.masksToBounds = YES;
    
    [self.view addSubview:btnAnswer];
    
    UIButton *btnSkip = [[UIButton alloc] initWithFrame:CGRectMake(15, self.view.height-64-60, self.view.width/2-30, 36)];
    [btnSkip setTitle:@"Skip" forState:UIControlStateNormal];
    [btnSkip setTintColor:[UIColor whiteColor]];
    [btnSkip addTarget:self action:@selector(btnSkipClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnSkip.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    
    [btnSkip setBackgroundColor:COLOR_BUTTON];
    btnSkip.layer.cornerRadius = 6;
    btnSkip.layer.masksToBounds = YES;
    
    [self.view addSubview:btnSkip];
    
    indexMyAnswer = -1;
    indexYourAnswer = -1;
    
    indexYourAnswer_Array = [NSMutableArray array];
    
    [self loadQuestionnaire];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}
- (void)loadQuestionnaire {
    /*
     
     Question Tags List
     
     ARRAY : ["0gfgNSISkv","0nmVB7oPrR","259OKVS2qf","2FBNqGVqmw","2lYT17U3sl","3NiSUIlP7i","3RY72p8YvQ","3RY72p8YvQ","3RY72p8YvQ","46tOXcjgj5","5IZagiLVsu","6TAxCuR5nn","7R7gnMWPPB"]
     SCORES: {"0gfgNSISkv":false,"0nmVB7oPrR":true,"259OKVS2qf":false,"2FBNqGVqmw":true,"3RY72p8YvQ":false,"46tOXcjgj5":false,"5IZagiLVsu":false,"6TAxCuR5nn":false,"7R7gnMWPPB":false}
     
     Answers: ["A","B","C"]
     SCORES:  {"A":{"Q1":"5","Q2":"-5"},"B":{"Q1":"2","Q2":"-3"},"C":{"Q1":"-5","Q2":"-4"}}
     
     Answers: ["A","B"]
     SCORES:  {"A":{"Q4":"-4","Q5":"-5"},"B":{"Q4":"2","Q5":"-3"}}
     
     Answers: ["A","B","C","D"]
     SCORES:  {"A":{"Q3":"5","Q4":"-5"},"B":{"Q2":"2","Q4":"-3"},"C":{"Q1":"-5","Q2":"-4"},"D":{"Q4":"-7","Q6":"2","Q8":"-10"}}
     
     Answers: ["A","B","C"]
     SCORES:  {"A":{"Q1":"5","Q2":"-5"},"B":{"Q1":"2","Q2":"-3"},"C":{"Q1":"-5","Q2":"-4"}}
     
     Answers: ["A","B"]
     SCORES:  {"A":{"Q4":"-3","Q5":"5"},"B":{"Q4":"-2","Q5":"3"}}
     
     Answers: ["A","B","C"]
     SCORES:  {"A":{"Q1":"-4","Q2":"-3"},"B":{"Q1":"-6","Q2":"-6"},"C":{"Q3":"-3","Q6":"-5"}}
     
     Answers: ["A","B","C","D","E"]
     SCORES:  {"A":{"Q1":"5","Q2":"-5"},"B":{"Q1":"2","Q2":"-3"},"C":{"Q1":"-5","Q2":"-4"},"D":{"Q4":"-9","Q8":"-3"},"E":{"Q3":"-4","Q4":"8"}}
     
     */
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    NSArray *array = [PFUser currentUser][PF_USER_QUESTIONNAIRE];
    if(!array || array.count == 0) {
        lblAnswers.text = @"You never answered any questions";
        array = [NSArray array];
    } else {
        lblAnswers.text = [NSString stringWithFormat:@"%d Questions Answered",(int)array.count];
    }
    [tempArray addObjectsFromArray:array];

    PFQuery *query = [PFQuery queryWithClassName:PF_QUESTIONNAIRE_CLASS_NAME];
    [query whereKey:@"objectId" notContainedIn:tempArray];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            
            if(objects.count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You have answered all the questions. Check back later!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];

            } else {
                PFObject *object = [objects firstObject];
                lblQuestion.text = object[PF_QUESTIONNAIRE_CONTENT];
                tempQuestion = object;
                [contentTableView reloadData];
            }
            
            
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnAnswerClicked:(id)sender {
    if(indexMyAnswer ==-1 || indexYourAnswer_Array.count == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Please click Skip if you dislike this question." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        
        return;
    }
    
    {
        NSString *q_key = [tempQuestion[PF_QUESTIONNAIRE_ANSWERS] objectAtIndex:indexMyAnswer];
        NSDictionary *score_dict = [tempQuestion[PF_QUESTIONNAIRE_SCORES] objectForKey:q_key];
        
        NSArray *keys = [score_dict allKeys];
        for(NSString *key in keys) {
            NSString *score = [score_dict objectForKey:key];
            NSString* keyIndex = [key stringByReplacingOccurrencesOfString:@"Q" withString:@""];
            
            NSString *user_question_key = [NSString stringWithFormat:@"question_%@",keyIndex];
            
            int newValue = [[PFUser currentUser][user_question_key] intValue] + score.intValue;
            if(newValue>99)
                newValue = 100;
            [PFUser currentUser][user_question_key] = [NSNumber numberWithInt:newValue];
        }
        
        NSMutableDictionary *my_question_dict = [PFUser currentUser][PF_USER_QUESTIONNAIRE_MY_ANSWER];
        if(!my_question_dict)
            my_question_dict = [NSMutableDictionary dictionary];
    
        [my_question_dict setObject:q_key forKey:tempQuestion.objectId];
        [PFUser currentUser][PF_USER_QUESTIONNAIRE_MY_ANSWER] = my_question_dict;

    }
    {

        NSMutableDictionary *your_question_dict = [PFUser currentUser][PF_USER_QUESTIONNAIRE_YOUR_ANSWER];
        if(!your_question_dict)
            your_question_dict = [NSMutableDictionary dictionary];
        NSMutableArray *array_answers = [NSMutableArray array];
        for(NSString *str_index in indexYourAnswer_Array) {
            NSString *key = [tempQuestion[PF_QUESTIONNAIRE_ANSWERS] objectAtIndex:str_index.intValue];
            [array_answers addObject:key];
        }
        [your_question_dict setObject:array_answers forKey:tempQuestion.objectId];
        [PFUser currentUser][PF_USER_QUESTIONNAIRE_YOUR_ANSWER] = your_question_dict;
    }
    
    NSMutableArray *array = [PFUser currentUser][PF_USER_QUESTIONNAIRE];
    if(!array)
        array = [NSMutableArray array];
    [array addObject:tempQuestion.objectId];

    [[PFUser currentUser] setObject:array forKey:PF_USER_QUESTIONNAIRE];
    
    [[PFUser currentUser] saveInBackground];
    [self loadQuestionnaire];
    
    indexYourAnswer = -1;
    indexMyAnswer = -1;
    
    [indexYourAnswer_Array removeAllObjects];
    
    [contentTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QuestionValueChanged" object:nil];

}

- (void)btnSkipClicked:(id)sender {
    
    if(tempQuestion.objectId) {
        [tempArray addObject:tempQuestion.objectId];
        [self loadQuestionnaire];
        
        indexYourAnswer = -1;
        indexMyAnswer = -1;
        [contentTableView reloadData];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"You have skipped all the questions. Check back later!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
    
}

#pragma mark -
#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Your Answer:";
    } else {
        return @"Answers acceptable to you:";
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 5,300, 35);
    label.font = [UIFont boldSystemFontOfSize:18];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = COLOR_IN_DARK_GRAY;
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    headerView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [tempQuestion[PF_QUESTIONNAIRE_ANSWERS] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [COLOR_IN_GRAY colorWithAlphaComponent:0.8];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.textLabel.textColor = COLOR_IN_DARK_GRAY;
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.indentationLevel = 2;
        cell.indentationWidth = 10;
        
    }
    cell.textLabel.text = [tempQuestion[PF_QUESTIONNAIRE_ANSWERS] objectAtIndex:indexPath.row];
    
    if(indexPath.section == 0) {
        
        if(indexPath.row == indexMyAnswer)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
    } else {
        
        if([indexYourAnswer_Array containsObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;

        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;

        }
        
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        indexMyAnswer = (int)indexPath.row;
    } else {
        indexYourAnswer = (int)indexPath.row;
        if([indexYourAnswer_Array containsObject:[NSString stringWithFormat:@"%d",indexYourAnswer]]) {
            [indexYourAnswer_Array removeObject:[NSString stringWithFormat:@"%d",indexYourAnswer]];
        } else {
            [indexYourAnswer_Array addObject:[NSString stringWithFormat:@"%d",indexYourAnswer]];
        }
        
    }
    [tableView reloadData];
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerRetroToRoot];
}

@end
