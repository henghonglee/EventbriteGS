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

@synthesize mainCellView,colorBarView,rankLabel,starview,distanceLabel,distanceIcon ,sourceLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.buttonImagesArray = [[NSMutableArray alloc]init];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin ];
//        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
//        [self addGestureRecognizer:_panGestureRecognizer];
//        [_panGestureRecognizer setDelegate:self];
//        self.state = MCSwipeTableViewCellState2;
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
//                self.mainCellView.alpha = 0.3;
                [master didScrollToEntryAtIndex:((NSIndexPath*)[((UITableView*)self.superview) indexPathForCell:self]).row-1];
            }
            
        }else{
            self.colorBarView.alpha = 0.0;
//            self.mainCellView.alpha = 0.3;
        }
    }else{    
        if ((convertedPoint.y+(self.bounds.size.height/2)) >=230 && (convertedPoint.y+(self.bounds.size.height/2)) <=310) {
            if (self.colorBarView.alpha != 0.7) {
                self.colorBarView.alpha = 0.7;
//                self.mainCellView.alpha = 0.3;
                [master didScrollToEntryAtIndex:((NSIndexPath*)[((UITableView*)self.superview) indexPathForCell:self]).row-1];
            }
            
        }else{
            self.colorBarView.alpha = 0.0;
//            self.mainCellView.alpha = 0.3;
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


#pragma mark - Handle Gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    UIGestureRecognizerState state = [gesture state];
    CGPoint translation = [gesture translationInView:self.contentView];
    CGPoint velocity = [gesture velocityInView:self.contentView];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(self.mainContainer.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
    NSTimeInterval animationDuration = [self animationDurationWithVelocity:velocity];
    _direction = [self directionWithPercentage:percentage];
    
    if (state == UIGestureRecognizerStateBegan) {
    }
    else if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        CGPoint center = {self.mainContainer.center.x + translation.x, self.mainContainer.center.y};
        [self.mainContainer setCenter:center];
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
      
        _currentPercentage = percentage;

        
        if (_direction != MCSwipeTableViewCellDirectionCenter ){
            [self moveWithDuration:animationDuration andDirection:_direction];
            if (_direction == MCSwipeTableViewCellDirectionCenter) {
                self.state = MCSwipeTableViewCellState2;
            }else if (_direction == MCSwipeTableViewCellDirectionRight)
            {
                self.state = MCSwipeTableViewCellState3;
            }else if (_direction == MCSwipeTableViewCellDirectionLeft)
            {
                self.state = MCSwipeTableViewCellState1;
            }
        }
        else{
            self.state = MCSwipeTableViewCellState2;
            [self bounceToOrigin];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGestureRecognizer) {
        UIScrollView *superview = (UIScrollView *) self.superview;
        CGPoint translation = [(UIPanGestureRecognizer *) gestureRecognizer translationInView:superview];
        
        // Make sure it is scrolling horizontally
        return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO && (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
    }
    return NO;
}

#pragma mark - Utils

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width {
    CGFloat offset = percentage * width;
    
    if (offset < -width) offset = -width;
    else if (offset > width) offset = 1.0;
    
    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}
- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage {
    
    if (self.state == MCSwipeTableViewCellState1){
            return MCSwipeTableViewCellDirectionCenter;
    }
    if (self.state == MCSwipeTableViewCellState3){
            return MCSwipeTableViewCellDirectionCenter;
    }
    
    if (percentage < -kMCStop1){

        return MCSwipeTableViewCellDirectionLeft;
    }
    else if (percentage > kMCStop1){

        return MCSwipeTableViewCellDirectionRight;
    }
    else{

        return MCSwipeTableViewCellDirectionCenter;
    }
}
- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff = kMCDurationHightLimit - kMCDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;
    
    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;
    
    return (kMCDurationHightLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}
#pragma mark - Movement


- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction {
    CGFloat origin;
    
    if (direction == MCSwipeTableViewCellDirectionLeft)
        origin = -270;
    else
        origin = 270;
    
    CGRect rect = self.mainContainer.frame;
    rect.origin.x = origin;
    
    
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [self.mainContainer setFrame:rect];
                     }
                     completion:^(BOOL finished) {
                     }];
}


@end
