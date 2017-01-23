//
//  InviteViewController.h
//  Project6
//
//  Created by superman on 2/10/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "THContactPickerView.h"
#import "THContactPickerTableViewCell.h"

@interface InviteViewController : ViewController<UITableViewDataSource, UITableViewDelegate, THContactPickerDelegate, ABPersonViewControllerDelegate>

@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

@end
