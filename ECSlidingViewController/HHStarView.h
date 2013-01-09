//
//  HHStarView.h
//  startest
//
//  Created by HengHong on 6/12/12.
//  Copyright (c) 2012 HengHong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHStarView : UIView
@property (nonatomic) float maxrating;
@property (nonatomic) float rating;
@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic,strong) UILabel* label;
- (id)initWithFrame:(CGRect)frame andRating:(float)rating animated:(BOOL)animated;
-(void)rating:(float)rating withAnimation:(BOOL)animated;
@end
