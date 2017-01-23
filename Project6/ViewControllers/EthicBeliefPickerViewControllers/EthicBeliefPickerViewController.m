//
//  EthicBeliefPickerViewController.m
//  Project6
//
//  Created by superman on 3/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "EthicBeliefPickerViewController.h"
#import "Public.h"

@interface EthicBeliefPickerViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *contentTableView;
    NSArray *contentsArray;
    
    NSMutableArray *tempArray;
}
@end

@implementation EthicBeliefPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if(self.isEthic) {
        self.title = @"Ethnicity";
    } else {
        self.title = @"Belief";
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveBtnClicked)];
    
    contentTableView = ({
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView;
    });
    
    [self.view addSubview:contentTableView];
    
    if(self.isEthic) {
        
        PFQuery *query = [PFQuery queryWithClassName:PF_ETHIC_CLASS];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error)
                contentsArray = objects;
            else
                contentsArray = [NSArray array];
            
            [contentTableView reloadData];
        }];
        
    } else {
        
        PFQuery *query = [PFQuery queryWithClassName:PF_BELIEF_CLASS];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error)
                contentsArray = objects;
            else
                contentsArray = [NSArray array];
            
            [contentTableView reloadData];
        }];
    }
    
    tempArray = [self convertTextToArray:self.contentStr];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveBtnClicked {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(ethicBeliefControllerSaveBtnClicked:isEthic:)]) {
        [self.delegate ethicBeliefControllerSaveBtnClicked:[self convertArrayToText:tempArray] isEthic:self.isEthic];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (NSMutableArray *)convertTextToArray:(NSString *)text {
    if([text isEqualToString:@"Ethnicity - ALL"] || [text isEqualToString:@"Belief - ALL"]) {
        return [NSMutableArray array];
    } else {
        return [NSMutableArray arrayWithArray:[text componentsSeparatedByString:@","]];
    }
}

- (NSString *)convertArrayToText:(NSMutableArray *)array {
    NSString *str = @"";
    if(array.count == 0) {
        if(self.isEthic)
            str = @"Ethnicity - ALL";
        else
            str=  @"Belief - ALL";
    } else {
        for(NSString *string in array) {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%@,",string]];
        }
        str = [str substringToIndex:[str length]-1];
        
    }

    return str;
}

#pragma mark -
#pragma mark UITableViewDelegate and DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contentsArray.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PFObject *object = [contentsArray objectAtIndex:indexPath.row];
    NSString *content_item = object[PF_ETHIC_CONTENT];
    cell.textLabel.text = content_item;
    cell.textLabel.textColor = COLOR_IN_DARK_GRAY;

    if(tempArray.count == 0) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = COLOR_IN_BLACK;

    } else {
        if([tempArray containsObject:content_item]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor = COLOR_IN_BLACK;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = COLOR_IN_DARK_GRAY;
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *object = [contentsArray objectAtIndex:indexPath.row];
    NSString *content_item = object[PF_ETHIC_CONTENT];
    if([tempArray containsObject:content_item]) {
        [tempArray removeObject:content_item];
    } else {
        [tempArray addObject:content_item];
    }
    [contentTableView reloadData];
}

@end
