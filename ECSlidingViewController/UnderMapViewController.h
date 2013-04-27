//
//  MenuViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import <MapKit/MapKit.h>
#import "Event.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface UnderMapViewController : UIViewController <MKMapViewDelegate,UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    MKMapView *mapView;
}
//@property (nonatomic,strong) MKAnnotationView* lastSelectedAnnotationView;
@property (nonatomic, strong) CrumbPath *crumbs;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *shop1LoadingIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *shop2LoadingIndicator;
@property (nonatomic, strong) CrumbPathView *crumbView;
@property (nonatomic, unsafe_unretained) CGFloat peekLeftAmount;
@property (nonatomic) BOOL categoriesShown;
@property (weak, nonatomic) IBOutlet UIView *InfoPanelView;
@property (nonatomic) BOOL isCalloutHidden;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *categoryButtons;

@property (weak, nonatomic) IBOutlet UIButton *resetTopViewButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UIView *locationButtonView;
@property (weak, nonatomic) IBOutlet UILabel *shopLabel;

@property (weak, nonatomic) IBOutlet UIButton *ShopButton;

@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *detailButton;
@property (weak, nonatomic) IBOutlet UIButton *categorySelectionButton;
@property (nonatomic)BOOL shouldShowPinAnimation;
@property (nonatomic,strong) UIImage *cursorImage;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIImageView *shop1;
@property (weak, nonatomic) IBOutlet UIImageView *shop2;
@property (nonatomic,strong) Event* gsObjSelected;
- (IBAction)showGeoscroll:(id)sender;

@end
