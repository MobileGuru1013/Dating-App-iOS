//
//  MatchCollectionViewCell.m
//  Streams
//
//  Created by Glenn on 12/21/14.
//  Copyright (c) 2014 Glenn. All rights reserved.
//

#import "MatchCollectionViewCell.h"
#import "UIViewAdditions.h"

@implementation MatchCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        self.photoView.clipsToBounds = NO;
        self.photoView.layer.borderWidth = 1.5;
        self.photoView.layer.borderColor = [COLOR_IN_DARK_GRAY CGColor];
        
        self.nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.photoView.bottom+5, self.width, 20)];
        self.nameLbl.font = [UIFont boldSystemFontOfSize:15];
        self.nameLbl.textColor = COLOR_IN_DARK_GRAY;
        self.nameLbl.textAlignment = NSTextAlignmentCenter;
        
        self.ageAddressLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.nameLbl.bottom, self.width, 16)];
        self.ageAddressLbl.font = [UIFont boldSystemFontOfSize:13];
        self.ageAddressLbl.textColor = COLOR_IN_DARK_GRAY;
        self.ageAddressLbl.textAlignment = NSTextAlignmentCenter;
        
        self.distanceLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,self.ageAddressLbl.bottom, self.width, 15)];
        self.distanceLbl.font = [UIFont boldSystemFontOfSize:12];
        self.distanceLbl.textColor = COLOR_IN_DARK_GRAY;
        self.distanceLbl.textAlignment = NSTextAlignmentCenter;
        
        self.matchBackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.distanceLbl.bottom+2, self.height-self.distanceLbl.bottom-8, self.height-self.distanceLbl.bottom-8)];
        self.matchBackImageView.image = [UIImage imageNamed:@"matchMark.png"];
        self.matchBackImageView.centerX = self.width/2;
        
        self.matchLbl = [[UILabel alloc] initWithFrame:self.matchBackImageView.frame];
        self.matchLbl.font = [UIFont boldSystemFontOfSize:20];
        self.matchLbl.textColor = [UIColor whiteColor];
        self.matchLbl.textAlignment = NSTextAlignmentCenter;
        
        self.banImageView = [[UIImageView alloc] initWithFrame:self.photoView.bounds];
        self.banImageView.clipsToBounds = YES;
        self.banImageView.image = [[UIImage imageNamed:@"ban_mark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.banImageView setTintColor:[UIColor colorWithRed:240.0/255.0 green:176.0/255.0 blue:177.0/255.0 alpha:0.6]];
        self.banImageView.width = self.photoView.width-40;
        self.banImageView.height = self.photoView.height-40;
        self.banImageView.center = self.photoView.center;
        
        crownImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 38)];
        crownImageView.image = [UIImage imageNamed:@"crown1.png"];
        crownImageView.left = 10;
        crownImageView.top = 10;
                
        self.lockButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
        [self.lockButton setTintColor:[UIColor whiteColor]];
        self.lockButton.bottom = self.photoView.bottom-6;
        self.lockButton.centerX = self.photoView.centerX;
        [self.lockButton setImage:[UIImage imageNamed:@"unlock_icon.png"] forState:UIControlStateNormal];
        [self.lockButton setTitle:@" Unlock" forState:UIControlStateNormal];
        [self.lockButton setTitleColor:COLOR_IN_BLACK forState:UIControlStateNormal];
        [self.lockButton setTitleColor:COLOR_IN_DARK_GRAY forState:UIControlStateHighlighted];
        [self.lockButton setBackgroundColor:[COLOR_IN_GRAY colorWithAlphaComponent:0.9]];
        self.lockButton.layer.cornerRadius = 4;
        self.lockButton.layer.masksToBounds = YES;
        self.lockButton.layer.borderColor = [COLOR_IN_GRAY CGColor];
        
        [self.contentView addSubview:self.photoView];
        [self.contentView addSubview:self.nameLbl];
        [self.contentView addSubview:self.ageAddressLbl];
        [self.contentView addSubview:self.distanceLbl];
        [self.contentView addSubview:self.matchBackImageView];
        [self.contentView addSubview:self.matchLbl];
        [self.contentView addSubview:self.banImageView];
        
        self.contentView.backgroundColor = COLOR_IN_GRAY;
    }
    return self;
}

- (void)setLock:(BOOL) val {
    if(val) {
        self.photoView.alpha = 0.8;
        [self.contentView addSubview:self.lockButton];
        [crownImageView removeFromSuperview];
    } else {
        self.photoView.alpha = 1.0;
        [self.lockButton removeFromSuperview];
        [crownImageView removeFromSuperview];
    }
}

- (void)markPurchased:(BOOL) val {
    if(val)
        [self.contentView addSubview:crownImageView];
    else
        [crownImageView removeFromSuperview];
}

- (void)setBan:(BOOL) val {
    if(val) {
        [self.contentView addSubview:self.banImageView];
    } else {
        [self.banImageView removeFromSuperview];
    }
}

@end
