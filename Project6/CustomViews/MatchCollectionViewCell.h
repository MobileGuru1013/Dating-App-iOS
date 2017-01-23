//
//  MatchCollectionViewCell.h
//  Streams
//
//  Created by Glenn on 12/21/14.
//  Copyright (c) 2014 Glenn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Public.h"

@interface MatchCollectionViewCell : UICollectionViewCell
{
    UIImageView *crownImageView;
}
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *ageAddressLbl;
@property (nonatomic, strong) UILabel *distanceLbl;
@property (nonatomic, strong) UILabel *matchLbl;
@property (nonatomic, strong) UIImageView *matchBackImageView;
@property (nonatomic, strong) UIButton *lockButton;

@property (nonatomic, strong) UIImageView *banImageView;

- (void)setLock:(BOOL) val;
- (void)markPurchased:(BOOL) val;
- (void)setBan:(BOOL) val;
@end
