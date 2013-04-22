#import "CircleLayout.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIKit/UIKit.h>
#import "GScursor.h"

#import "UnderMapViewController.h"

#import "GeoScrollViewController.h"
#import "ShopDetailViewController.h"
#import "MapSlidingViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SVWebViewController.h"

#import "FoodPlaceViewController.h"

#define kCalloutShadowRadius 10.0f
#define kCalloutShadowOpacity 0.9f
#define kShadowInset 0.05f
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height > 500 )
@interface UnderMapViewController()

@end

@implementation UnderMapViewController
@synthesize mapView,shouldShowPinAnimation;
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
    


    self.locationButtonView.layer.cornerRadius = 5.0f;
    self.locationButtonView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.locationButtonView.layer.shadowOpacity = 0.3;
    self.locationButtonView.layer.shadowOffset = CGSizeMake(-1.0f, -1.0f);
    self.locationButtonView.layer.shadowRadius = 1.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.locationButtonView.bounds];
    self.locationButtonView.layer.shadowPath = path.CGPath;
    
    self.InfoPanelView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.InfoPanelView.layer.shadowOpacity = 0.3;
    self.InfoPanelView.layer.shadowOffset = CGSizeMake(-1.0f, -1.0f);
    self.InfoPanelView.layer.shadowRadius = 1.0f;
    path = [UIBezierPath bezierPathWithRect:self.InfoPanelView.bounds];
    self.InfoPanelView.layer.shadowPath = path.CGPath;
    self.cursorImage  = [UIImage imageNamed:@"cursor.png"];
    shouldShowPinAnimation = YES;
    onceToken = 0;
    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
       self.slidingViewController.underRightWidthLayout = ECFullWidth;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleGesture:)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tgr];
}
- (IBAction)getDirections:(id)sender {
    [(GeoScrollViewController*)self.slidingViewController.topViewController getDirectionsToSelectedGSObj];
}

-(void)viewWillAppear:(BOOL)animated
{


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
    [self setInfoPanelView:nil];
    [self setShopButton:nil];
    [self setShopLabel:nil];
    [self setShopImageView:nil];
    [self setLocationButtonView:nil];
    [self setResetTopViewButton:nil];
    [self setResetTopViewButton:nil];
    [self setDistanceLabel:nil];
    [super viewDidUnload];
}

- (IBAction)showGeoscroll:(id)sender {
    NSLog(@"show geoscroll");
    CGRect slideViewFinalFrame = CGRectMake(self.view.bounds.size.width-320, self.view.bounds.size.height, 320, 75);
    self.shopLabel.hidden=YES;
    self.shopImageView.hidden= YES;
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.InfoPanelView.frame = slideViewFinalFrame;
                     }
                     completion:^(BOOL finished){
                         self.InfoPanelView.hidden= YES;
                         [self.slidingViewController resetTopView];
                     }];
    


}
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    GeoScrollViewController* topVC = ((GeoScrollViewController*)self.slidingViewController.topViewController);
    [topVC didTouchMapAtCoordinate:touchMapCoordinate];

}


#pragma mark -
#pragma mark MKMapViewDelegate

-(void)mapView:(MKMapView *)retMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
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
        [((GeoScrollViewController*)self.slidingViewController.topViewController) didReceiveUserLocation:self.mapView.userLocation];
        NSLog(@"setting region");
    });
    ((GeoScrollViewController*)self.slidingViewController.topViewController).userLocation = userLocation;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    if ([annotation isKindOfClass:[FoodPlace class]]){
        static NSString* pinIdentifier = @"pinIdentifierString";
        MKAnnotationView* pinView =(MKAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        if (!pinView)
        {
            MKAnnotationView *customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                           reuseIdentifier:pinIdentifier];
            
            
            customPinView.image = [UIImage imageNamed:@"pin.png"];
            customPinView.layer.anchorPoint = CGPointMake(0.5, 1.0);
            customPinView.centerOffset = CGPointMake(0,0);
            customPinView.canShowCallout = NO;
            [customPinView setUserInteractionEnabled:YES];
            customPinView.clipsToBounds = NO;
            return customPinView;
            
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
            
            

            [customPinView setUserInteractionEnabled:YES];
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

    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{

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


        }
    }
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.slidingViewController.underRightShowing) {
        self.locationButton.hidden = NO;

    }

    if(animated){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"regionDidChangeAnimated" object:nil];
    }else{
        
    }
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{

}

#pragma mark Custom Methods
- (IBAction)zoomToLoc:(id)sender
{
//    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    if (self.mapView.userLocation) {
        MKCoordinateRegion region;
        region.center.latitude = [self.mapView userLocation].coordinate.latitude;
        region.center.longitude = [self.mapView userLocation].coordinate.longitude;
        region.span.latitudeDelta = 0.01;
        region.span.longitudeDelta = 0.01;
        [mapView setRegion:region animated:YES];
    }
    
}

- (IBAction)zoomToAll:(id)sender
{
    

    
}

- (IBAction)backAction:(id)sender
{
    [[NSNotificationCenter defaultCenter]removeObserver:self.slidingViewController.topViewController];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showWebView:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone"
                                                             bundle: nil];
    FoodPlaceViewController* foodplaceViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"FoodPlace"];
    foodplaceViewController.foodplace = self.gsObjSelected;
    [self.navigationController pushViewController:foodplaceViewController animated:YES];
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
- (IBAction)showCategoryButtons:(id)sender
{
    if(!_categoriesShown){
        
   
    for (UIButton* btn in _categoryButtons) {
        CGRect slideViewFinalFrame = CGRectMake(270, 130+(btn.tag*45), 45, 45);
                [UIView animateWithDuration:0.3
                          delay:0.2
                        options: UIViewAnimationOptionCurveEaseOut
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
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 btn.frame = slideViewFinalFrame;
                             }
                             completion:^(BOOL finished){
                                  _categoriesShown = NO;
                             }];
        }
       
    }
}


-(void)resetOverlay
{
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"mycell"];
    cell.imageView.image = [UIImage imageNamed:@"buttonBlue.png"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 136;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(BOOL)shouldAutorotate{
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}
@end

