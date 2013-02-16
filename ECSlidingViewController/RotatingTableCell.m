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
@synthesize mainCellView,colorBarView,rankLabel,starview,distanceLabel,distanceIcon ,sourceLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin ];
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
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGPoint convertedPoint =[self convertPoint:self.mainCellView.frame.origin toView:[[UIApplication sharedApplication] keyWindow]];
    GeoScrollViewController* master = (GeoScrollViewController*)((UITableView*)self.superview).delegate;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationIsLandscape(orientation)) {
        if ((convertedPoint.x+(self.bounds.size.height/2)) >=(230) && (convertedPoint.x+(self.bounds.size.height/2)) <=(280)) {
            if (self.colorBarView.alpha != 0.7) {
                self.colorBarView.alpha = 0.7;
                self.mainCellView.alpha = 0.3;
                [master didScrollToEntryAtIndex:((NSIndexPath*)[((UITableView*)self.superview) indexPathForCell:self]).row-1];
            }
            
        }else{
            self.colorBarView.alpha = 0.0;
            self.mainCellView.alpha = 0.3;
        }
    }else{    
        if ((convertedPoint.y+(self.bounds.size.height/2)) >=230 && (convertedPoint.y+(self.bounds.size.height/2)) <=310) {
            if (self.colorBarView.alpha != 0.7) {
                self.colorBarView.alpha = 0.7;
                self.mainCellView.alpha = 0.3;
                [master didScrollToEntryAtIndex:((NSIndexPath*)[((UITableView*)self.superview) indexPathForCell:self]).row-1];
            }
            
        }else{
            self.colorBarView.alpha = 0.0;
            self.mainCellView.alpha = 0.3;
        }
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"did rotate to landscape");
    }
    else
    {
        NSLog(@"did rotate to portrait");
    }
}
@end
