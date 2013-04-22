//
//  RotatingTableCell.h
//  SDWebImage Demo
//
//  Created by HengHong on 8/11/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//
#import "RateLabel.h"
#import <UIKit/UIKit.h>
#import "HHStarView.h"


typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellDirection){
    MCSwipeTableViewCellDirectionLeft = 0,
    MCSwipeTableViewCellDirectionCenter,
    MCSwipeTableViewCellDirectionRight
};
typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellState){
    MCSwipeTableViewCellStateNone = 0,
    MCSwipeTableViewCellState1,
    MCSwipeTableViewCellState2,
    MCSwipeTableViewCellState3,
    MCSwipeTableViewCellState4
};
typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellMode){
    MCSwipeTableViewCellModeExit = 0,
    MCSwipeTableViewCellModeSwitch
};


@interface RotatingTableCell : UITableViewCell 
{
    
    
    
}
@property (nonatomic) int currentImageIndex;
@property(nonatomic, assign) MCSwipeTableViewCellState state;

@property(nonatomic, assign) MCSwipeTableViewCellDirection direction;
@property(nonatomic, assign) CGFloat currentPercentage;
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UIScrollView *mainContainer;
@property (strong, nonatomic) NSMutableArray *buttonImagesArray;

@property (strong, nonatomic) UIView *ratingView;
@property (strong, nonatomic) UIView *mainRatingBackgroundCellView;
@property (strong, nonatomic) UIView *mainRatingCellView;
@property (strong, nonatomic) HHStarView* ratingStarView;

@property (strong, nonatomic) UIView *imagesView;
@property (strong, nonatomic) UIView *mainImagesBackgroundCellView;
@property (strong, nonatomic) UIView *mainImagesCellView;


@property (strong, nonatomic) UIView *mainCellView;
@property (strong, nonatomic) UIView *mainTitleView;
@property (strong, nonatomic) RateLabel *rateLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) UILabel *sourceLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UIImageView *distanceIcon;
//@property (strong, nonatomic) HHStarView* starView;
@property (strong, nonatomic) NSNumber* itemIndex;
@property (strong, nonatomic) UIView *colorBarView;
@property (strong, nonatomic) UIView *distanceColorBarView;
@property (strong, nonatomic) HHStarView* starview;
- (void)bounceToOrigin;
@end
