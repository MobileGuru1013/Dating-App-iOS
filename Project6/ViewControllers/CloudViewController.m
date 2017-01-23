//
//  CloudViewController.m
//  Project6
//
//  Created by Louis Laurent on 31/05/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "CloudViewController.h"
#import "AMTagListView.h"
#import "AMTagView.h"
#import "NHMainHeader.h"

#define kCellIdentifier @"cellIdentifier"

@interface CloudViewController ()<AMTagListDelegate,UIAlertViewDelegate,NHAutoCompleteTextFieldDataSourceDelegate, NHAutoCompleteTextFieldDataFilterDelegate>
{
    AMTagListView *tagListView;
    
    NHAutoCompleteTextField *tagTextField;
    
    PFObject *cloudObject;
    
    NSMutableArray *tagCloudArray;
    NSArray *inUseDataSource;
}
@property (nonatomic, strong) AMTagView             *selection;

@end

@implementation CloudViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    inUseDataSource = [NSArray array];
    
    tagCloudArray = [NSMutableArray array];
    
    UILabel *lblIntroduction = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.width-20, 90)];
    lblIntroduction.textAlignment = NSTextAlignmentLeft;
    lblIntroduction.textColor = [UIColor lightGrayColor];
    lblIntroduction.font = [UIFont systemFontOfSize:12];
    lblIntroduction.numberOfLines = 10;
    lblIntroduction.text = @"The 6 of Heart Cloud is designed to help find you your best match using state of the art machine learning algorthim. Type any phrase,noun, or verb that you think describes you or things you are passionate about and we will do the rest!\n\nExample: Hiking, Nerd, Camping, Sushi, House of Cards";
    
    [self.view addSubview:lblIntroduction];
    
    tagTextField = [[NHAutoCompleteTextField alloc] initWithFrame:CGRectMake(0, lblIntroduction.bottom+10, pubWidth-80, 36)];
    tagTextField.backgroundColor = COLOR_IN_GRAY;
    [tagTextField setDropDownDirection:NHDropDownDirectionDown];
    [tagTextField setDataSourceDelegate:self];
    [tagTextField setDataFilterDelegate:self];

    tagTextField.suggestionTextField.font = [UIFont systemFontOfSize:16];
    tagTextField.suggestionTextField.placeholder = @"Tag";
    tagTextField.suggestionTextField.returnKeyType = UIReturnKeyDone;
    [tagTextField.suggestionTextField addTarget:self action:@selector(tagTextFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 36)];
    tagTextField.suggestionTextField.leftViewMode = UITextFieldViewModeAlways;
    tagTextField.suggestionTextField.leftView = leftView;
    
    [self.view addSubview:tagTextField];
    
    UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(tagTextField.right, tagTextField.top, 80, 36)];
    [btnAdd setTitle:@"Add" forState:UIControlStateNormal];
    [btnAdd.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnAdd setBackgroundColor:COLOR_TINT_SECOND];
    [btnAdd addTarget:self action:@selector(btnAddClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnAdd];

    
    tagListView = [[AMTagListView alloc] initWithFrame:CGRectMake(8, tagTextField.bottom+10, pubWidth-16, self.view.height-64-tagTextField.bottom-64)];
    [self.view addSubview:tagListView];
    
    [[AMTagView appearance] setTagLength:10];
    [[AMTagView appearance] setTextPadding:10];
    [[AMTagView appearance] setTextFont:[UIFont systemFontOfSize:14]];
    [[AMTagView appearance] setTagColor:[UIColor colorWithRed:27.0/255.0 green:154.0/255.0 blue:247.0/255.0 alpha:1.0]];
    
    tagListView.tagListDelegate = self;
    
    __weak CloudViewController* weakSelf = self;
    [tagListView setTapHandler:^(AMTagView *view) {
        weakSelf.selection = view;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Project6 Notice"
                                                        message:[NSString stringWithFormat:@"Delete %@ from cloud?", [view tagText]]
                                                       delegate:weakSelf
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Sure", nil];
        [alert show];
    }];
    
    [[KIProgressViewManager manager] showProgressOnView:self.view];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_CLOUD_CLASS];
    [query whereKey:PF_CLOUD_USER equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            
            if(objects.count == 0) {
                cloudObject = [PFObject objectWithClassName:PF_CLOUD_CLASS];
                cloudObject[PF_CLOUD_USER] = [PFUser currentUser];
            } else {
                cloudObject = [objects firstObject];
                [tagListView addTags:cloudObject[PF_CLOUD_TAGS]];
            }
            
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
    
    PFQuery *query_cloud = [PFQuery queryWithClassName:PF_CLOUD_CLASS];
    [query_cloud findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            for(PFObject *object in objects) {
                if(object[PF_CLOUD_TAGS])
                    [tagCloudArray addObjectsFromArray:object[PF_CLOUD_TAGS]];
            }
        }
    }];
    
}
- (void)btnAddClicked {
    
    NSMutableArray *array = cloudObject[PF_CLOUD_TAGS];
    if(!array)
        array = [NSMutableArray array];
    
    if(tagTextField.filterString.length>0 && tagTextField.filterString.length<35) {
        
        if([array containsObject:tagTextField.filterString]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Duplicate Tag, Already Exist!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
            
            
        } else {

            [tagListView addTag:tagTextField.filterString];
            
            [array addObject:tagTextField.filterString];
            if(cloudObject) {
                cloudObject[PF_CLOUD_TAGS] = array;
                [cloudObject saveInBackground];
            }
        
        }
    } else {
        
        [tagListView addTag:tagTextField.filterString];

        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Project6 Notice" message:@"Characters should be less 35 length, not empty" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
    }

    tagTextField.filterString = @"";
    tagTextField.suggestionTextField.text = @"";
    [tagTextField resignFirstResponder];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tagList:(AMTagListView *)tagListView shouldAddTagWithText:(NSString *)text resultingContentSize:(CGSize)size
{
    // Don't add a 'bad' tag
    return ![text isEqualToString:@"bad"];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        NSString *str_delete = self.selection.tagText;
        [tagListView removeTag:self.selection];
        
        NSMutableArray *array = cloudObject[PF_CLOUD_TAGS];
        [array removeObject:str_delete];
        
        cloudObject[PF_CLOUD_TAGS] = array;
        [cloudObject saveInBackground];
    }
}
- (void)tagTextFieldDone:(UITextField*) sender {
    [sender resignFirstResponder];
}

#pragma mark - NHAutoComplete DataSource delegate functions

- (NSInteger)autoCompleteTextBox:(NHAutoCompleteTextField *)autoCompleteTextBox numberOfRowsInSection:(NSInteger)section
{
    return [inUseDataSource count];
}

- (UITableViewCell *)autoCompleteTextBox:(NHAutoCompleteTextField *)autoCompleteTextBox cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [autoCompleteTextBox.suggestionListView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    // Create cell, you can use the most recent way to create a cell.
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        [cell.textLabel setFont:[UIFont fontWithName:cell.textLabel.font.fontName size:13.5f]];
        
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell setBackgroundColor:[UIColor textBoxColor]];
    }
    
    [cell.textLabel setText:inUseDataSource[indexPath.row]];
    
    [cell.textLabel normalizeSubstring:cell.textLabel.text];
    
    if(autoCompleteTextBox.filterString)
    {
        [cell.textLabel boldSubstring:autoCompleteTextBox.filterString];
    }
    return cell;
}

#pragma mark - NHAutoComplete Filter data source delegate functions

-(BOOL)shouldFilterDataSource:(NHAutoCompleteTextField *)autoCompleteTextBox
{
    return YES;
}

-(void)autoCompleteTextBox:(NHAutoCompleteTextField *)autoCompleteTextBox didFilterSourceUsingText:(NSString *)text
{
    if ([text length] == 0)
    {
        inUseDataSource = [NSArray array];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(SELF BEGINSWITH[c] %@) OR (SELF CONTAINS[c] %@)", text, [NSString stringWithFormat:@" %@", text]];

    NSArray *filteredArr = [tagCloudArray filteredArrayUsingPredicate:predicate];
    inUseDataSource = filteredArr;
}
- (void)didSelectSuggestedWord:(NSString *) suggestedWord {
    tagTextField.filterString = suggestedWord;
    tagTextField.suggestionTextField.text = suggestedWord;
}

@end
