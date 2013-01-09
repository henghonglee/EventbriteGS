//
//  HeaderCell.h
//  ECSlidingViewController
//
//  Created by HengHong on 3/12/12.
//
//

#import <UIKit/UIKit.h>
#import "HHStarView.h"
#import <MapKit/MapKit.h>
#import "CounterView.h"
@interface HeaderCell : UICollectionViewCell<UIScrollViewDelegate,MKMapViewDelegate>


@property  (strong, nonatomic) CounterView* likeCounterView;
@property  (strong, nonatomic) CounterView* couponCounterView;
@property  (strong, nonatomic) CounterView* starCounterView;

@property (strong, nonatomic) UIImageView* profileImage;
@property (strong, nonatomic) UILabel* titleLabel;
@property (strong, nonatomic) UILabel* subtitleLabel;
@property (strong, nonatomic) UIImageView* cellImage;
@property (strong, nonatomic) UIScrollView* cellScrollView;
@property (strong, nonatomic) HHStarView* starView;
@property (strong, nonatomic) UILabel* descriptionTextView;
@property (strong, nonatomic) MKMapView* mapView;
@property (strong, nonatomic) UIImageView* pinView;
@property (strong, nonatomic) UILabel* addressLabel;
@property (strong, nonatomic) UILabel* openingLabel;
@property (strong, nonatomic) UILabel* phoneLabel;

@end
