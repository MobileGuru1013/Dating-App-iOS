//
//  RightMenuViewController.m
//  Project6
//
//  Created by superman on 2/11/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "RightMenuViewController.h"
#import "Public.h"

#define kWidth 240
#define kButtonWidth 60

@interface RightMenuViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation RightMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(130, (self.view.frame.size.height - 60 * 3) / 2.0f, self.view.width-140, 60*3) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];

    
    // Do any additional setup after loading the view.
}
#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            //            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[DEMOFirstViewController alloc] init]]
            //                                                         animated:YES];
            //            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            //            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[DEMOSecondViewController alloc] init]]
            //                                                         animated:YES];
            //            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    cell.textLabel.textAlignment = NSTextAlignmentRight;

    NSArray *titles = @[@"Newest", @"About to End", @"Ended"];
    NSArray *images = @[@"loveIcon", @"expiredIcon", @"endedIcon"];
    cell.textLabel.text = titles[indexPath.row];
    cell.detailTextLabel.text = @"00:00:43";
    if(indexPath.row == 2)
        cell.detailTextLabel.text = @"";
    cell.imageView.image = [[UIImage imageNamed:images[indexPath.row]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.imageView setTintColor:COLOR_Border];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
