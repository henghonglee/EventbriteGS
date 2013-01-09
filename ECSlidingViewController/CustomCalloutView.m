//
//  CustomCalloutView.m
//  ECSlidingViewController
//
//  Created by HengHong on 23/11/12.
//

#import <QuartzCore/QuartzCore.h>
#import "CustomCalloutView.h"
@implementation CustomCalloutView
@synthesize detailImageView,detailSubtitleLabel,detailTitleLabel,gsObject,containerView,detailButton,starview;

#define kContainerPadding 5.0f
#define kPaddingBetweenElements 5.0f
#define kPaddingTop 5.0f
#define kPaddingRight 10.0f
#define kPaddingLeft 20.0f
#define kPaddingBottom 30.0f
#define kColorBarWidth 15.0f
#define kCloseButtonWidthHeight 25.0f
#define kImageViewSizeWidth 32.0f
#define kImageViewSizeHeight 32.0f
#define kPinPoint 140.0f
#define kCalloutArrowHeight 12.0f
#define kCalloutArrowWidth 10.0f
#define kStarViewHeight 14.75f
#define kStarViewWidth 80+14.75+15
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setUserInteractionEnabled:YES];
        self.opaque = NO;
        
        starview = [[HHStarView alloc]initWithFrame:CGRectMake(kPaddingLeft,kPaddingTop + kImageViewSizeHeight+kPaddingBetweenElements, 80+14.75+15, 14.75) andRating:0.0f animated:NO];
        
        
        detailSubtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kPaddingLeft, kPaddingTop + kImageViewSizeHeight+kPaddingBetweenElements+kStarViewHeight, self.bounds.size.width-kPaddingLeft-kPaddingRight, self.bounds.size.height-kPaddingTop-kPaddingBottom-kImageViewSizeHeight)];

        detailTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kImageViewSizeWidth+kPaddingLeft+kPaddingBetweenElements, kPaddingTop, self.bounds.size.width-kPaddingRight-kPaddingLeft-kImageViewSizeWidth-kPaddingBetweenElements, kImageViewSizeHeight)];
        detailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeft,kPaddingTop,kImageViewSizeWidth , kImageViewSizeHeight)];


        containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,kColorBarWidth, self.bounds.size.height-kCalloutArrowHeight)];
        containerView.backgroundColor = [UIColor redColor];
        containerView.opaque = YES;
        UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, kColorBarWidth-2,self.bounds.size.height-kCalloutArrowHeight) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(100.0, 100.0)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = containerView.layer.bounds;
        maskLayer.path = maskPath.CGPath;
        containerView.layer.mask = maskLayer;
        
        [detailTitleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [detailTitleLabel setTextColor:[UIColor whiteColor]];
        [detailTitleLabel setNumberOfLines:0];
        [detailTitleLabel setOpaque:YES];
        [detailTitleLabel setBackgroundColor:[UIColor clearColor]];
        
        [detailSubtitleLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [detailSubtitleLabel setNumberOfLines:0];
        [detailSubtitleLabel setOpaque:YES];
        [detailSubtitleLabel setTextColor:[UIColor whiteColor]];
        [detailSubtitleLabel setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:starview];
        [self addSubview:detailImageView];
        [self addSubview:detailTitleLabel];
        [self addSubview:detailSubtitleLabel];
        [self addSubview:containerView];

    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
        float radius = 15.0f;
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextClearRect(currentContext,rect);
    CGContextMoveToPoint(currentContext, radius, 0.0);
    CGContextAddLineToPoint(currentContext, self.bounds.size.width-radius,0.0 );
    CGContextAddArcToPoint(currentContext, self.bounds.size.width, 0.0, self.bounds.size.width, radius, radius);
    CGContextAddLineToPoint(currentContext, self.bounds.size.width, self.bounds.size.height - kCalloutArrowHeight-radius);
    CGContextAddArcToPoint(currentContext, self.bounds.size.width, self.bounds.size.height - kCalloutArrowHeight,self.bounds.size.width-radius, self.bounds.size.height - kCalloutArrowHeight, radius);
    CGContextAddLineToPoint(currentContext, kPinPoint+kCalloutArrowWidth, self.bounds.size.height - kCalloutArrowHeight);
    CGContextAddLineToPoint(currentContext, kPinPoint, self.bounds.size.height);//tip
    CGContextAddLineToPoint(currentContext, kPinPoint-kCalloutArrowWidth, self.bounds.size.height - kCalloutArrowHeight);
    CGContextAddLineToPoint(currentContext, 0.0 +radius, self.bounds.size.height - kCalloutArrowHeight );
    CGContextAddArcToPoint(currentContext, 0.0 ,self.bounds.size.height - kCalloutArrowHeight, 0.0, self.bounds.size.height - kCalloutArrowHeight-radius , radius);

    CGContextAddLineToPoint(currentContext, 0.0, radius);
    CGContextAddArcToPoint(currentContext, 0,0,radius,0.0 , radius);
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 0.5f);
    CGContextFillPath(currentContext);
}



@end
