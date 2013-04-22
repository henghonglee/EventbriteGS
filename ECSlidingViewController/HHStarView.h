//
//  HHStarView.h
//  startest
//
//  Created by HengHong on 6/12/12.
//  Copyright (c) 2012 HengHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodPlace.h"
@interface HHStarView : UIView
{
    dispatch_queue_t GSdataSerialQueue;
}
@property dispatch_queue_t GSdataSerialQueue;
@property (nonatomic) int userRating;
@property (nonatomic) BOOL isSending;
@property (nonatomic) BOOL animated;
@property (nonatomic) int maxrating;
@property (nonatomic) int rating;
@property (nonatomic,strong) NSManagedObjectContext* context;
@property (nonatomic) float kLabelAllowance;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic,strong) UILabel* label;
@property (nonatomic,strong) UILabel* sublabel;
@property (nonatomic,strong) FoodPlace* foodplace;

- (id)initWithFrame:(CGRect)frame andRating:(int)rating withLabel:(BOOL)label animated:(BOOL)animated;
-(void)starViewSetRating:(int)Rating isUser:(BOOL)isUser isAnimated:(BOOL)isanimated;
-(void)starViewSetRating:(int)Rating isUser:(BOOL)isUser;
-(void)deleteUserRatingsForStall;
@end
