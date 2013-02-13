//
//  RotatingTableCell.h
//  SDWebImage Demo
//
//  Created by HengHong on 8/11/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHStarView.h"

@interface RotatingTableCell : UITableViewCell
@property (strong, nonatomic) UIView *mainCellView;
@property (strong, nonatomic) UILabel *rankLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
//@property (strong, nonatomic) HHStarView* starView;
@property (strong, nonatomic) NSNumber* itemIndex;
@property (strong, nonatomic) UIView *colorBarView;
@property (strong, nonatomic) HHStarView* starview;
@end
