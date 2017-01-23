//
//  ResultViewController.m
//  Project6
//
//  Created by superman on 2/22/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ResultViewController.h"
#import "Public.h"
#import "ResultTableViewCell.h"
#import "ResultDetailViewController.h"

@interface ResultViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *resultTableView;
    NSMutableArray *results_array;
}
@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    results_array = [NSMutableArray array];
    
    resultTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.width,self.view.height-64) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.alpha = 1.0;
        tableView.tag = 10;
        [tableView registerClass:[ResultTableViewCell class] forCellReuseIdentifier:@"resultTableViewCellIdentifier"];
        tableView;
    });
    
    resultTableView.tableFooterView = [UIView new];
    
    [self.view addSubview:resultTableView];

    [[KIProgressViewManager manager] showProgressOnView:self.view];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_CONTEST_CLASS];
    [query whereKey:PF_CONTEST_USER equalTo:[PFUser currentUser]];
    [query whereKey:@"createdAt" greaterThan:[[NSDate dateYesterday] dateAtEndOfDay]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            if(objects.count == 0) {
                [self loadPrevious];
            } else {
                [results_array addObject:objects];
                [resultTableView reloadData];
                [self loadPrevious];
            }
        }
        [[KIProgressViewManager manager] hideProgressView];
    }];
    
    // Do any additional setup after loading the view.
}
- (void)loadPrevious {

    PFQuery *query = [PFQuery queryWithClassName:PF_CONTEST_CLASS];
    [query whereKey:PF_CONTEST_USER equalTo:[PFUser currentUser]];
    [query whereKey:@"createdAt" lessThan:[[NSDate dateYesterday] dateAtEndOfDay]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(objects.count != 0) {
                for(int i=0; i<objects.count; i++) {
                    NSDate *date =[[NSDate dateYesterday] dateBySubtractingDays:i];
                    NSMutableArray *array = [NSMutableArray array];
                    
                    for(PFObject *object in objects) {
                        NSDate *createdDate = object.createdAt;
                        if([createdDate isSameDayAsDate:date]) {
                            [array addObject:object];
                        }
                    }
                    if(array.count !=0) {
                        [results_array addObject:array];
                        [resultTableView reloadData];

                    }
                }
            }
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return results_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"resultTableViewCellIdentifier";
    
    ResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    NSArray *array = [results_array objectAtIndex:indexPath.row];
    PFObject *object = [array firstObject];
    
    cell.lblDate.text = [NSDate getFormattedBirthday:object.createdAt];
    [cell.photoView setImageWithURL:[NSURL URLWithString:object[PF_CONTEST_THUMB]] placeholderImage:[UIImage imageNamed:@"placeholder_gb.png"]];
    
    cell.photoView.contentMode = UIViewContentModeScaleAspectFit;               //added by Michal 7/7

    cell.lblPhotos.text = [NSString stringWithFormat:@"%d Photos",(int)array.count];
    
    if([object.createdAt isToday]) {
        
        NSDate *date1 = [object.createdAt dateByAddingDays:1];
        
        int hours = (int)[date1 hoursAfterDate:[NSDate date]];
        cell.lblReady.text = [NSString stringWithFormat:@"(Ready in %d hours)",hours];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        int flagCount = 0;
        for(PFObject *obj_photo in array) {
            flagCount+= [obj_photo[PF_CONTEST_FLAGGING] count];
        }
        if(flagCount>=10) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.lblReady.text = @"The test was removed because too many users flagged your picture(s) as inappropriate";
            cell.lblReady.font = [UIFont systemFontOfSize:10];
            cell.lblReady.numberOfLines = 5;
        } else {
            
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *array = [results_array objectAtIndex:indexPath.row];
    
    int flagCount = 0;
    for(PFObject *obj_photo in array) {
        flagCount+= [obj_photo[PF_CONTEST_FLAGGING] count];
    }
    if(flagCount>=10) {

    } else {
        ResultDetailViewController *resultDetailCtrl = [[ResultDetailViewController alloc] init];
        resultDetailCtrl.array = array;
        [self.navigationController pushViewController:resultDetailCtrl animated:YES];
    }
}

@end
