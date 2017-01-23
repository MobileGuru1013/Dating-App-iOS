//
//  ResultDetailViewController.m
//  Project6
//
//  Created by Louis Laurent on 04/06/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ResultDetailViewController.h"
#import "Public.h"
#import "ResultViewTableViewCell.h"

@interface ResultDetailViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *resultTableView;
}
@end

@implementation ResultDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Test Result";
    self.view.backgroundColor = [UIColor whiteColor];
    
    resultTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.width,self.view.height-64-64-20-6) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.tag = 10;
        [tableView registerClass:[ResultViewTableViewCell class] forCellReuseIdentifier:@"resultTableViewCellIdentifier"];
        tableView;
    });
    
    resultTableView.tableFooterView = [UIView new];
    
    [self.view addSubview:resultTableView];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"resultTableViewCellIdentifier";
    
    ResultViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ResultViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    PFObject *object = [self.array objectAtIndex:indexPath.row];
    
    [cell.photoView setImageWithURL:[NSURL URLWithString:object[PF_CONTEST_THUMB]] placeholderImage:[UIImage imageNamed:@"placeholder_gb.png"]];
    
    cell.photoView.contentMode = UIViewContentModeScaleAspectFit;               //added by Michal 7/7

    int likes = (int)[object[PF_CONTEST_LIKES] count];
    int dislikes = (int)[object[PF_CONTEST_DISLIKES] count];
    if(likes+dislikes == 0)
        cell.lblYES.text = @"0% YES";
    else
        cell.lblYES.text = [NSString stringWithFormat:@"%d%% Yes",(int)((likes/(likes+dislikes))*100.0)];
    cell.lblDes.text = [NSString stringWithFormat:@"Yes:%d No:%d Total:%d",likes,dislikes,likes+dislikes];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
