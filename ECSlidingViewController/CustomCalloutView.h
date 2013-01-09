//
//  CustomCalloutView.h
//  ECSlidingViewController
//
//  Created by HengHong on 23/11/12.
//
//

#import <UIKit/UIKit.h>
#import "GSObject.h"
#import "HHStarView.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface CustomCalloutView : UIView
{
    
}
@property (nonatomic,strong) HHStarView* starview;
@property (nonatomic,strong)UIView* containerView;
@property (nonatomic,strong)GSObject* gsObject;
@property (nonatomic,strong)UIImageView* detailImageView;
@property (nonatomic,strong)UILabel* detailTitleLabel;
@property (nonatomic,strong)UILabel* detailSubtitleLabel;
@property (nonatomic,strong)UIButton* detailButton;
@end
