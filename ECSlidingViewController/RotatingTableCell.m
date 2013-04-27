//
//  RotatingTableCell.m
//  SDWebImage Demo
//
//  Created by HengHong on 8/11/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

static CGFloat const kMCStop1 = 0.10; // Percentage limit to trigger the first action
static CGFloat const kMCStop2 = 0.75; // Percentage limit to trigger the second action
static CGFloat const kMCBounceAmplitude = 20.0; // Maximum bounce amplitude when using the MCSwipeTableViewCellModeSwitch mode
static NSTimeInterval const kMCBounceDuration1 = 0.2; // Duration of the first part of the bounce animation
static NSTimeInterval const kMCBounceDuration2 = 0.1; // Duration of the second part of the bounce animation
static NSTimeInterval const kMCDurationLowLimit = 0.25; // Lowest duration when swipping the cell because we try to simulate velocity
static NSTimeInterval const kMCDurationHightLimit = 0.1; // Highest duration when swipping the cell because we try to simulate velocity


#import "RotatingTableCell.h"
#import <QuartzCore/QuartzCore.h>
#import "GeoScrollViewController.h"
@implementation RotatingTableCell

@synthesize mainCellView,colorBarView,distanceLabel,distanceIcon ,sourceLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.buttonImagesArray = [[NSMutableArray alloc]init];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin ];

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

    if (self.mainContainer.contentOffset.x == 0 || self.mainContainer.contentOffset.x == 640) {
        [self.mainContainer scrollRectToVisible:CGRectMake(320, 0, 320, self.bounds.size.height) animated:YES];
    }else{
        [super layoutSubviews];
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGPoint convertedPoint =[self convertPoint:self.mainCellView.frame.origin toView:[[UIApplication sharedApplication] keyWindow]];
    GeoScrollViewController* master = (GeoScrollViewController*)((UITableView*)self.superview).delegate;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationIsLandscape(orientation)) {
        if ((convertedPoint.x+(self.bounds.size.height/2)) >=(230) && (convertedPoint.x+(self.bounds.size.height/2)) <=(280)) {
            if (self.colorBarView.alpha != 0.7) {
                self.colorBarView.alpha = 0.7;
                [master didScrollToEntryAtIndex:((NSIndexPath*)[((UITableView*)self.superview) indexPathForCell:self]).row-1];
            }
            
        }else{
            self.colorBarView.alpha = 0.0;
        }
    }else{    
        if ((convertedPoint.y+(self.bounds.size.height/2)) >=230 && (convertedPoint.y+(self.bounds.size.height/2)) <=310) {
            if (self.colorBarView.alpha != 0.7) {
                self.colorBarView.alpha = 0.7;
                [master didScrollToEntryAtIndex:((NSIndexPath*)[((UITableView*)self.superview) indexPathForCell:self]).row-1];
            }
            
        }else{
            self.colorBarView.alpha = 0.0;
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
