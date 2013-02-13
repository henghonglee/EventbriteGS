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
#import "CustomCalloutView.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface UnderMapViewController : UIViewController <MKMapViewDelegate>
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
@property (nonatomic) BOOL isCalloutHidden;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *categoryButtons;
@property (strong, nonatomic) CustomCalloutView* callout;
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *detailButton;
@property (weak, nonatomic) IBOutlet UIButton *categorySelectionButton;
@property (nonatomic)BOOL shouldShowPinAnimation;
@property (nonatomic,strong) UIImage *cursorImage;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIImageView *shop1;
@property (weak, nonatomic) IBOutlet UIImageView *shop2;

- (IBAction)selectCategory:(id)sender;
-(void)dismissCallout;
-(void)hideCategoryButtons;
@end
