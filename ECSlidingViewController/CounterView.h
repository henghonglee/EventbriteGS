//
//  CounterView.h
//  ECSlidingViewController
//
//  Created by HengHong on 8/12/12.
//
//

#import <UIKit/UIKit.h>

@interface CounterView : UIView

@property (nonatomic,strong)UILabel* titleLabel;
@property (nonatomic,strong)UILabel* subtitleLabel;
- (id)initWithFrame:(CGRect)frame andTitle:(NSString*)title andSubtitle:(NSString*)subtitle;
@end
