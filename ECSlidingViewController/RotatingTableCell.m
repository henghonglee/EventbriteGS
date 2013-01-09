//
//  RotatingTableCell.m
//  SDWebImage Demo
//
//  Created by HengHong on 8/11/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "RotatingTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "GeoScrollViewController.h"
@implementation RotatingTableCell
@synthesize mainCellView,colorBarView,rankLabel,starview;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint convertedPoint =[self convertPoint:self.mainCellView.frame.origin toView:[[UIApplication sharedApplication] keyWindow]];
    GeoScrollViewController* master = (GeoScrollViewController*)((UITableView*)self.superview).delegate;
    if ((convertedPoint.y+(self.bounds.size.height/2)) >=230 && (convertedPoint.y+(self.bounds.size.height/2)) <=310) {
        if (self.colorBarView.alpha != 0.7) {
            //self.colorBarView.backgroundColor = [UIColor redColor] ;
            self.colorBarView.alpha = 0.7;
            [master didScrollToEntryAtIndex:((NSIndexPath*)[((UITableView*)self.superview) indexPathForCell:self]).row-1];
        }
        
    }else{
      //  self.colorBarView.backgroundColor = [UIColor blackColor] ;
        self.colorBarView.alpha = 0.0;
    }
}
@end
