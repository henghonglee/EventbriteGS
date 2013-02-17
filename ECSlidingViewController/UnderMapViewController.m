#import "CircleLayout.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIKit/UIKit.h>
#import "GScursor.h"
#import "GSObject.h"
#import "UnderMapViewController.h"
#import "ViewController.h"
#import "GeoScrollViewController.h"
#import "ShopDetailViewController.h"
#import "MapSlidingViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>


#define kCalloutShadowRadius 10.0f
#define kCalloutShadowOpacity 0.9f
#define kShadowInset 0.05f
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height > 500 )
@interface UnderMapViewController()

@end

@implementation UnderMapViewController
@synthesize mapView,shouldShowPinAnimation,callout;
static dispatch_once_t onceToken;

- (void)viewDidLoad
{
  [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.shop1 setContentMode:UIViewContentModeScaleAspectFill];
    [self.shop2 setContentMode:UIViewContentModeScaleAspectFill];
    self.shop1.layer.borderColor = [UIColor blackColor].CGColor;
    self.shop1.layer.borderWidth = 2.0f;
    self.shop1.clipsToBounds =YES;
    self.shop2.layer.borderColor = [UIColor blackColor].CGColor;
    self.shop2.layer.borderWidth = 2.0f;
    self.shop2.clipsToBounds =YES;
    self.cursorImage  = [UIImage imageNamed:@"cursor.png"];
    shouldShowPinAnimation = YES;
    onceToken = 0;
    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
       self.slidingViewController.underRightWidthLayout = ECFullWidth;

}

-(void)viewWillAppear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCallout) name:@"SHOWMENU" object:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidUnload {
    [self setLocationButton:nil];
    [self setAllButton:nil];
    [self setCategoryButtons:nil];
    [self setCategorySelectionButton:nil];
    [self setShop1:nil];
    [self setShop1:nil];
    [self setShop2:nil];
    [self setShop1LoadingIndicator:nil];
    [self setShop2LoadingIndicator:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark MKMapViewDelegate

-(void)mapView:(MKMapView *)retMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"did update user location");
    CLLocation* seaLoc = [[CLLocation alloc]initWithLatitude:0.0 longitude:0.0];
    if ([userLocation.location distanceFromLocation:seaLoc] < 100) {
        return;
    }
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region;
        region.center.latitude = [self.mapView userLocation].coordinate.latitude;
        region.center.longitude = [self.mapView userLocation].coordinate.longitude;
        region.span.latitudeDelta = 0.01;
        region.span.longitudeDelta = 0.01;
        [retMapView setRegion:region animated:NO];
        
    });
    [((GeoScrollViewController*)self.slidingViewController.topViewController) didReceiveUserLocation:self.mapView.userLocation];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    if ([annotation isKindOfClass:[GSObject class]]){
        static NSString* pinIdentifier = @"pinIdentifierString";
        MKAnnotationView* pinView =(MKAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        if (!pinView)
        {
            MKAnnotationView *customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                           reuseIdentifier:pinIdentifier];
            
            
            customPinView.image = [UIImage imageNamed:@"pin.png"];
            customPinView.layer.anchorPoint = CGPointMake(0.6, 1.0);
            customPinView.centerOffset = CGPointMake(3,-2);
            customPinView.canShowCallout = NO;
            customPinView.opaque = YES;
            return customPinView;
            
           // return nil;
        }
        else
        {
            pinView.annotation = annotation;
            
        }
        return pinView;
    }
    if ([annotation isKindOfClass:[GScursor class]]){
        static NSString* cursorIdentifier = @"cursorIdentifierString";
        MKAnnotationView* cursorView =(MKAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:cursorIdentifier];
        if (!cursorView)
        {
            MKAnnotationView *customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:cursorIdentifier];
            
            

            [customPinView setUserInteractionEnabled:NO];
            customPinView.image = self.cursorImage;
            customPinView.centerOffset = CGPointMake(0,0);
            customPinView.canShowCallout = NO;
            return customPinView;
        }
        else
        {
            cursorView.annotation = annotation;
        }
        return cursorView;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[GScursor class]]||[view isKindOfClass:[MKUserLocation class]] ) {
        
        return;
    }else if([view.annotation isKindOfClass:[GSObject class]]){
//        if (!callout) {
//            callout = [[CustomCalloutView alloc]initWithFrame:CGRectMake(0, 15, 240, 73)];
//            
//            GSObject* selectedGSObj = view.annotation;
//            
//            callout.alpha = 0;
//            [callout.starview rating:selectedGSObj.shopScore.floatValue/10.0f withAnimation:YES];
//            callout.detailTitleLabel.text = selectedGSObj.title;
//            callout.detailSubtitleLabel.text = selectedGSObj.subTitle;
//            callout.gsObject = selectedGSObj;
//            callout.containerView.backgroundColor = selectedGSObj.cursorColor;
//            //adding shadows
//            callout.layer.shadowColor = [UIColor blackColor].CGColor;
//            callout.layer.shadowOpacity = kCalloutShadowOpacity;
//            callout.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//            callout.layer.shadowRadius = kCalloutShadowRadius;
//            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(callout.bounds, callout.bounds.size.width*kShadowInset, callout.bounds.size.height*kShadowInset)];
//            callout.layer.shadowPath = path.CGPath;
//        
//            UIButton* newButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            newButton.frame = CGRectMake(0, 0, 240, 100);
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                           initWithTarget:self action:@selector(showDetail:)];
//            tap.numberOfTapsRequired = 1;
//            [newButton addGestureRecognizer:tap];
//            [callout addSubview:newButton];
//            if(selectedGSObj.imageArray.count>0){
//            [callout.detailImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[selectedGSObj.imageArray objectAtIndex:0]]]];
//            }
//            [view addSubview:callout];
//            [UIView animateWithDuration:0.3
//                                  delay:0.2
//                                options: UIViewAnimationCurveEaseOut
//                             animations:^{
//                                 callout.alpha = 1;
//                             } 
//                             completion:^(BOOL finished){
//                                 
//                             }];
//        
//        }
    }
    
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{

//    [self hideCallout];
}

- (void)mapView:(MKMapView *)mapView
didAddAnnotationViews:(NSArray *)annotationViews
{
    if (shouldShowPinAnimation) {
    for (MKAnnotationView *annView in annotationViews)
    {
        if ([annView.annotation isKindOfClass:[GScursor class]])
            return;
        [self.mapView bringSubviewToFront:annView];
        CGRect endFrame = annView.frame;
        annView.layer.anchorPoint = CGPointMake(0.6, 1.0);
        annView.frame = CGRectMake(annView.frame.origin.x+annView.frame.size.width*0.6, annView.frame.origin.y+annView.frame.size.height,0.0f, 0.0f);
        annView.frame = endFrame;
//        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseIn
//                         animations:^{
//                             
//                         }completion:^(BOOL finished) {
//                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
//                                 CATransform3D zRotation;
//                                 zRotation = CATransform3DMakeRotation(M_PI/10, 0, 0, 1.0);
//                                 annView.layer.transform = zRotation;
//                                 
//                             }completion:^(BOOL finished) {
//                                 [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
//                                     CATransform3D zRotation;
//                                     zRotation = CATransform3DMakeRotation(-M_PI/10, 0, 0, 1.0);
//                                     annView.layer.transform = zRotation;
//                                     
//                                 }completion:^(BOOL finished) {
//                                     [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
//                                         CATransform3D zRotation;
//                                         zRotation = CATransform3DMakeRotation(M_PI/12, 0, 0, 1.0);
//                                         annView.layer.transform = zRotation;
//                                         
//                                     }completion:^(BOOL finished) {
//                                         [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
//                                             CATransform3D zRotation;
//                                             zRotation = CATransform3DMakeRotation(-M_PI/12, 0, 0, 1.0);
//                                             annView.layer.transform = zRotation;
//                                             
//                                         }completion:^(BOOL finished) {
//                                             [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
//                                                 CATransform3D zRotation;
//                                                 zRotation = CATransform3DMakeRotation(0, 0, 0, 1.0);
//                                                 annView.layer.transform = zRotation;
//                                                 
//                                             }completion:^(BOOL finished) {
//                                                 
//                                             }];
//                                         }];
//                                     }];
//                                 }];
//                             }];
//                         }];
        }
    }
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    if (self.slidingViewController.underRightShowing) {
//        self.locationButton.hidden = NO;
//
//        if (_isCalloutHidden) {
//            NSLog(@"callout was hidden");
//        }else{
//            [self showCallout];
//        }
//        [UIView animateWithDuration:0.3
//                              delay:0.2
//                            options: UIViewAnimationCurveEaseOut
//                         animations:^{
//                             self.slidingViewController.topViewController.view.frame = CGRectMake(-280, 0, 320, 460);
//                         }
//                         completion:^(BOOL finished){
//                             
//                         }];
//        
//    }

    if(animated){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"regionDidChangeAnimated" object:nil];
    }else{
        
    }
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
//    if (callout.alpha == 0.0f) {
//        _isCalloutHidden = YES;
//    }else{
//        _isCalloutHidden = NO;
//        [self hideCallout];
//    }
//    
//    [self hideCategoryButtons];
//    self.locationButton.hidden = YES;
//
//    if (self.slidingViewController.underRightShowing) {
//    [UIView animateWithDuration:0.1
//                          delay:0.0
//                        options: UIViewAnimationCurveEaseOut
//                     animations:^{
//                         self.slidingViewController.topViewController.view.frame = CGRectMake(-320, 0, 320, 460);
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];
//    }
//    if(animated)
//        NSLog(@"regionwillchange, animated = true");
//    else
//    {
//        for (UIView* views in self.view.subviews) {
//            if ([views isKindOfClass:[CustomCalloutView class]]) {
//                [UIView animateWithDuration:0.3
//                                      delay:0.2
//                                    options: UIViewAnimationCurveEaseOut
//                                 animations:^{
//                                     views.alpha =0;
//                                 }
//                                 completion:^(BOOL finished){
//                                     [views removeFromSuperview];
//                                 }];
//
//            }
//        }
//    }
}

#pragma mark Custom Methods
- (IBAction)zoomToLoc:(id)sender
{
//    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    MKCoordinateRegion region;
    region.center.latitude = [self.mapView userLocation].coordinate.latitude;
    region.center.longitude = [self.mapView userLocation].coordinate.longitude;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    [mapView setRegion:region animated:YES];
    
    
    
}

- (IBAction)zoomToAll:(id)sender
{
    
//    self.crumbs.points = nil;
 //   self.crumbs = nil;
   /* for (UIView* views in self.view.subviews) {
        if ([views isKindOfClass:[CustomCalloutView class]]) {
            [UIView animateWithDuration:0.3
                                  delay:0.2
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 views.alpha =0;
                             }
                             completion:^(BOOL finished){
                                 [views removeFromSuperview];
                             }];
            
        }
    }
    */
    
}

- (IBAction)backAction:(id)sender
{
    [[NSNotificationCenter defaultCenter]removeObserver:self.slidingViewController.topViewController];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showDetail:(id)sender
{
    ShopDetailViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShopDetail"];
    
    
    viewController.gsObject = callout.gsObject;
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)selectCategory:(UIButton*)sender
{
    if (sender.tag==0) {
        
    }else{
        GeoScrollViewController* topVC = ((GeoScrollViewController*)self.slidingViewController.topViewController);
        
                ((MapSlidingViewController*)self.slidingViewController).category = sender.tag;
                
                [topVC.loadedGSObjectArray removeAllObjects];
                [topVC.GSObjectArray removeAllObjects];
                [topVC LoadData];
              
        
    }
}
- (IBAction)showCategoryButtons:(id)sender {
    if(!_categoriesShown){
        
   
    for (UIButton* btn in _categoryButtons) {
        CGRect slideViewFinalFrame = CGRectMake(270, 130+(btn.tag*45), 45, 45);
                [UIView animateWithDuration:0.3
                          delay:0.2
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         btn.frame = slideViewFinalFrame;
                     } 
                     completion:^(BOOL finished){
                        _categoriesShown = YES;
                     }];
        }
    }else{
        for (UIButton* btn in _categoryButtons) {
            CGRect slideViewFinalFrame = CGRectMake(270,405, 45, 45);
            [UIView animateWithDuration:0.3
                                  delay:0.2
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 btn.frame = slideViewFinalFrame;
                             }
                             completion:^(BOOL finished){
                                  _categoriesShown = NO;
                             }];
        }
       
    }
}
-(void)hideCategoryButtons
{
    for (UIButton* btn in _categoryButtons) {
        CGRect slideViewFinalFrame = CGRectMake(270,405, 45, 45);
        [UIView animateWithDuration:0.3
                              delay:0.2
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             btn.frame = slideViewFinalFrame;
                         }
                         completion:^(BOOL finished){
                             _categoriesShown = NO;
                         }];
    }
}
-(void)dismissCallout
{

    for (id annote in self.mapView.annotations) {
        if ([annote isKindOfClass:[GSObject class]]) {
            for (UIView* view in ((MKAnnotationView*)[mapView viewForAnnotation:annote]).subviews) {
                if ([view isKindOfClass:[CustomCalloutView class]]) {
                    [UIView animateWithDuration:0.1
                                          delay:0.0
                                        options: UIViewAnimationCurveEaseOut
                                     animations:^{
                                         callout.alpha = 0;
                                     }
                                     completion:^(BOOL finished){
                                         [callout removeFromSuperview];
                                         callout = nil;
                                     }];
                    
                }
            }
        }
    }
}
-(void)hideCallout
{
    for (id annote in self.mapView.annotations) {
        if ([annote isKindOfClass:[GSObject class]]) {
            for (UIView* view in ((MKAnnotationView*)[mapView viewForAnnotation:annote]).subviews) {
                if ([view isKindOfClass:[CustomCalloutView class]]) {
                    [UIView animateWithDuration:0.2
                                          delay:0.0
                                        options: UIViewAnimationCurveEaseOut
                                     animations:^{
                                         callout.alpha = 0;
                                     }
                                     completion:^(BOOL finished){
                                         
                                     }];
                    
                }
            }
        }
    }
}
-(void)showCallout
{
    for (id annote in self.mapView.annotations) {
        if ([annote isKindOfClass:[GSObject class]]) {
            for (UIView* view in ((MKAnnotationView*)[mapView viewForAnnotation:annote]).subviews) {
                if ([view isKindOfClass:[CustomCalloutView class]]) {
                    [UIView animateWithDuration:0.2
                                          delay:0.0
                                        options: UIViewAnimationCurveEaseOut
                                     animations:^{
                                         callout.alpha = 1;
                                     }
                                     completion:^(BOOL finished){
                                     }];
                }
            }
        }
    }
}

-(void)resetOverlay
{
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        for (id annote in self.mapView.annotations) {
            if ([annote isKindOfClass:[GSObject class]]) {
                if (((GSObject*)annote).imageArray.count>0) {
                [self.shop1 setImageWithURL:[((GSObject*)annote).imageArray objectAtIndex:0]];
                    [self.shop1LoadingIndicator startAnimating];
                }else{
                    [self.shop1LoadingIndicator stopAnimating];
                    [self.shop1 setImageWithURL:[NSURL URLWithString:@""]];
                }
                if (((GSObject*)annote).imageArray.count>1) {
                [self.shop2 setImageWithURL:[((GSObject*)annote).imageArray objectAtIndex:1]];
                    [self.shop2LoadingIndicator startAnimating];
                }else{
                    [self.shop2LoadingIndicator stopAnimating];
                    [self.shop2 setImageWithURL:[NSURL URLWithString:@""]];
                }

            }
        }
    }
    else
    {
     
    }
}
@end
