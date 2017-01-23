//
//  ResultTableViewCell.m
//  Project6
//
//  Created by Louis Laurent on 04/06/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ResultTableViewCell.h"
#import "Public.h"

#define kCellHeight 90

@implementation ResultTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        
        self.photoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, kCellHeight-20, kCellHeight-20)];
        self.photoView.clipsToBounds = YES;
        [self addSubview:self.photoView];
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(self.photoView.right+10, 24, 100, 20)];
        self.lblDate.font = [UIFont boldSystemFontOfSize:16];
        self.lblDate.textColor = COLOR_IN_BLACK;
        
        [self addSubview:self.lblDate];
        
        self.lblPhotos = [[UILabel alloc] initWithFrame:CGRectMake(self.photoView.right+10, self.lblDate.bottom, 100, 30)];
        self.lblPhotos.font = [UIFont systemFontOfSize:13];
        self.lblPhotos.textColor = COLOR_IN_DARK_GRAY;
        
        [self addSubview:self.lblPhotos];
        
        self.lblReady = [[UILabel alloc] initWithFrame:CGRectMake(self.lblDate.right, 0, pubWidth-self.lblDate.right, kCellHeight)];
        self.lblReady.font = [UIFont boldSystemFontOfSize:16];
        self.lblReady.textColor = [UIColor colorWithRed:179.0/255.0 green:59.0/255.0 blue:63.0/255.0 alpha:1.0];
        
        [self addSubview:self.lblReady];
        
    }
    return self;
}

@end
