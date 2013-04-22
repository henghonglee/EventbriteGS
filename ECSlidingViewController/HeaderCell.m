//
//  HeaderCell.m
//  ECSlidingViewController
//
//  Created by HengHong on 3/12/12.
//
//

#import "HeaderCell.h"
#import <QuartzCore/QuartzCore.h>
#import "CounterView.h"
#import <MapKit/MapKit.h>
#define kTextViewPadding 10.0f
#define kCoverHeight 150.0f
#define kProfileImageHeight 65.0f
#define kTopPadding 10
#define kLeftPadding 10
#define kRightPadding 10
#define kBottomPadding 10
#define kPaddingBtwElements 5
#define kTitleLabelHeight 43
#define kSubTitleLabelHeight 35
#define kLikeCounterViewWidth 100
#define kCouponCounterViewWidth 100
#define kStarCounterViewWidth 120
#define kCounterViewHeight 50.0f
@implementation HeaderCell
@synthesize cellScrollView,cellImage,descriptionTextView;
        static dispatch_once_t onceToken;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    onceToken = 0;
    if (self) {
        // Initialization code
        NSLog(@"initializing header");
        self.contentView.backgroundColor = [UIColor clearColor];
        self.cellScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.cellScrollView.clipsToBounds = NO;
        [self.cellScrollView setBackgroundColor:[UIColor whiteColor]];


        
        self.cellImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kCoverHeight)];
        [self.cellImage setImage:[UIImage imageNamed:@"sbcover.jpg"]];
        self.cellImage.clipsToBounds = YES;
        [self.cellImage setContentMode:UIViewContentModeScaleAspectFill];


        
        UIView* shadeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kCoverHeight)];
        [shadeView setBackgroundColor:[UIColor blackColor]];
        [shadeView setAlpha:0.3f];

        
        self.profileImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, kTopPadding,kProfileImageHeight, kProfileImageHeight)];
        self.profileImage.center = CGPointMake(self.bounds.size.width/2,kTopPadding+kProfileImageHeight/2 );
        
        [self.profileImage setContentMode:UIViewContentModeScaleAspectFill];
        self.profileImage.clipsToBounds = YES;
        [self.profileImage.layer setCornerRadius:10.0f];
        [self.profileImage.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.profileImage.layer setBorderWidth:3.0f];
        [self.profileImage setImage:[UIImage imageNamed:@"sblogo.jpg"]];

        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0 , 0, self.bounds.size.width-kLeftPadding-kRightPadding, kTitleLabelHeight)];
        self.titleLabel.center = CGPointMake(self.bounds.size.width/2, kPaddingBtwElements+kTopPadding+kProfileImageHeight+kTitleLabelHeight/2);

        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setNumberOfLines:0];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.titleLabel setShadowColor:[UIColor blackColor]];
        [self.titleLabel setShadowOffset:CGSizeMake(1.0f, 1.0f)];

        
        self.subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width-kLeftPadding-kRightPadding-kLeftPadding-kRightPadding, kTitleLabelHeight)];
        self.subtitleLabel.center = CGPointMake(self.titleLabel.center.x , self.titleLabel.center.y + kSubTitleLabelHeight);
        
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.backgroundColor = [UIColor clearColor];
        self.subtitleLabel.textColor = [UIColor whiteColor];
        [self.subtitleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [self.subtitleLabel setShadowColor:[UIColor blackColor]];
        [self.subtitleLabel setShadowOffset:CGSizeMake(1.0f, 1.0f)];

//        self.starView = [[HHStarView alloc]initWithFrame:CGRectMake(0, kCoverHeight-49.75f, 320, 49.75f) andRating:1.0f animated:YES];

        self.likeCounterView = [[CounterView alloc]initWithFrame:CGRectMake(0, kCoverHeight, kLikeCounterViewWidth, kCounterViewHeight) andTitle:@"523" andSubtitle:@"LIKES"];

        self.couponCounterView = [[CounterView alloc]initWithFrame:CGRectMake(self.likeCounterView.frame.size.width, kCoverHeight, kCouponCounterViewWidth, kCounterViewHeight)andTitle:@"523" andSubtitle:@"COUPONS"];
        self.starCounterView = [[CounterView alloc]initWithFrame:CGRectMake(self.likeCounterView.frame.size.width+self.couponCounterView.frame.size.width, kCoverHeight, kStarCounterViewWidth, kCounterViewHeight)andTitle:@"5" andSubtitle:@"STARS"];
        
        UIScrollView* descriptionScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, kCoverHeight + kCounterViewHeight, self.bounds.size.width, self.bounds.size.height -kCounterViewHeight - kCoverHeight)];
        [descriptionScroll setContentSize:CGSizeMake(320*3, self.bounds.size.height -kCounterViewHeight - kCoverHeight)];
        descriptionScroll.pagingEnabled = YES;
        descriptionScroll.bounces = YES;
        [descriptionScroll setDelegate:self];        
        descriptionTextView = [[UILabel alloc]initWithFrame:CGRectMake(kTextViewPadding,kTextViewPadding,self.bounds.size.width-2*kTextViewPadding,descriptionScroll.frame.size.height-kTextViewPadding*2)];
        [descriptionTextView setNumberOfLines:0];
        [descriptionTextView setFont:[UIFont systemFontOfSize:14.0f]];
        
        self.openingLabel= [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width*2+kTextViewPadding, kTextViewPadding+self.addressLabel.frame.size.height, self.bounds.size.width - kTextViewPadding*2 , descriptionScroll.bounds.size.height-2*kTextViewPadding)];
        
        
        self.addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width+kTextViewPadding, kTextViewPadding, self.bounds.size.width - kTextViewPadding*2 , 40)];
        self.phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width+kTextViewPadding, kTextViewPadding+self.addressLabel.frame.size.height, self.bounds.size.width - kTextViewPadding*2 ,40)];
        
        
        [self.addressLabel setBackgroundColor:[UIColor clearColor]];
        [self.openingLabel setBackgroundColor:[UIColor clearColor]];
        [self.phoneLabel setBackgroundColor:[UIColor clearColor]];
        [self.phoneLabel setNumberOfLines:0];
        [self.addressLabel setNumberOfLines:0];
        [self.openingLabel setNumberOfLines:0];
//
//
        [descriptionScroll addSubview:self.addressLabel];
        [descriptionScroll addSubview:self.openingLabel];
        [descriptionScroll addSubview:self.phoneLabel];        
        [descriptionScroll addSubview:descriptionTextView];
        
        
        
        self.mapView = [[MKMapView alloc]initWithFrame:self.cellImage.frame];
        self.mapView.alpha = 0;
        self.mapView.showsUserLocation = YES;
        [self.mapView setUserInteractionEnabled:NO];
        
        self.pinView = [[UIImageView alloc]initWithFrame:CGRectMake(-23, -kCoverHeight/2, self.bounds.size.width, kCoverHeight)];
        [self.pinView setImage:[UIImage imageNamed:@"flag.png"]];
        [self.pinView setContentMode:UIViewContentModeScaleAspectFit];
        [self.pinView setAlpha:0];
        
        [self.cellScrollView addSubview:self.mapView];
        [self.cellScrollView addSubview:self.pinView];
        [self.cellScrollView addSubview:self.cellImage];
        [self.cellImage addSubview:shadeView];
        [self.contentView addSubview:self.cellScrollView];
        [self.cellScrollView addSubview:self.subtitleLabel];
        [self.cellScrollView addSubview:self.titleLabel];
        [self.cellScrollView addSubview:self.profileImage];
        [self.cellScrollView addSubview:self.starCounterView];
        [self.cellScrollView addSubview:self.couponCounterView];
        [self.cellScrollView addSubview:self.likeCounterView];
        [self.cellScrollView addSubview:descriptionScroll];
        
        //[self.cellScrollView addSubview:self.starView];
        
    }
    NSLog(@"done initializing header");
    return self;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= self.bounds.size.width) {
            
            [UIView animateWithDuration:0.2
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.profileImage.alpha = 0;
                         self.titleLabel.alpha= 0;
                         self.subtitleLabel.alpha = 0;
                         self.cellImage.alpha= 0;
                         self.mapView.alpha = 1;
                         self.pinView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    }else{
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.profileImage.alpha = 1;
                                 self.titleLabel.alpha= 1;
                                 self.subtitleLabel.alpha = 1;
                                 self.cellImage.alpha= 1;
                                 self.mapView.alpha = 0;
                                 self.pinView.alpha = 0;
                             }
                             completion:^(BOOL finished){
                                 NSLog(@"Done!");
                             }];
        
    }
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < -70) {
        dispatch_once(&onceToken, ^{
            NSLog(@"go back");
            [[NSNotificationCenter defaultCenter]postNotificationName:@"popstack" object:nil];
        });
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
