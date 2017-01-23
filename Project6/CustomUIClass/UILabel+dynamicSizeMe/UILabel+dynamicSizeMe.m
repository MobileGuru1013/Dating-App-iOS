//
//  UILabel+dynamicSizeMe.m
//  Project6
//
//  Created by superman on 2/23/15.
//  Copyright (c) 2015 superman. All rights reserved.
//

#import "UILabel+dynamicSizeMe.h"

@implementation UILabel (dynamicSizeMe)

-(float)resizeToFit{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(float)expectedHeight {
    
    [self setNumberOfLines:0];
    [self setLineBreakMode:NSLineBreakByCharWrapping];
//    UIFont *font = [UIFont systemFontOfSize:14.0]; //Warning! It's an example, set the font, you need
//    
//    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
//                                          font, NSFontAttributeName,
//                                          nil];
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
    CGSize requiredSize = [self sizeThatFits: maximumLabelSize];
//
//    
//    CGRect expectedLabelRect = [[self text] boundingRectWithSize:maximumLabelSize
//                                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
//                                                      attributes:attributesDictionary
//                                                         context:nil];
//    CGSize *expectedLabelSize = &expectedLabelRect.size;
    
    return requiredSize.height;
}

@end
