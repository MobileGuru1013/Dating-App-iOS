//
//  ResultViewTableViewCell.m
//  Project6
//
//  Created by Louis Laurent on 04/06/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "ResultViewTableViewCell.h"
#import "Public.h"

#define kCellHeight 150

@implementation ResultViewTableViewCell

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
        
        self.photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight, kCellHeight)];
        self.photoView.clipsToBounds = YES;
        
        [self addSubview:self.photoView];
        
        self.lblYES = [[UILabel alloc] initWithFrame:CGRectMake(self.photoView.right, 0, pubWidth-kCellHeight-15, 30)];
        self.lblYES.textAlignment = NSTextAlignmentRight;
        self.lblYES.font = [UIFont boldSystemFontOfSize:20];
        self.lblYES.textColor = [UIColor colorWithRed:51.0/255.0 green:157.0/255.0 blue:62.0/255.0 alpha:1.0];
        
        self.lblYES.centerY = kCellHeight/2-15;
        
        [self addSubview:self.lblYES];
        
        self.lblDes = [[UILabel alloc] initWithFrame:CGRectMake(self.photoView.right, 0, pubWidth-kCellHeight-15, 20)];
        self.lblDes.textAlignment = NSTextAlignmentRight;
        self.lblDes.font = [UIFont systemFontOfSize:14];
        self.lblDes.textColor = COLOR_IN_DARK_GRAY;
        self.lblDes.centerY = kCellHeight/2+10;
        
        [self addSubview:self.lblDes];
        
        
    }
    return self;
}

@end
