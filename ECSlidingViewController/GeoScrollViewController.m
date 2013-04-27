
#import "touchScrollView.h"
#import "SVWebViewController.h"
#import "GeoScrollViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CrumbObj.h"
#import "SorterCell.h"
#import "EndTableCell.h"
#import "RotatingTableCell.h"
#import "MapSlidingViewController.h"
#import "UnderMapViewController.h"
#import "AFNetworking.h"
#import "AFHTTPClient.h"
#import "AppDelegate.h"


#define sqlUpdateDate @"2013-04-25T08:23:30Z"
#define kMainFont     [UIFont systemFontOfSize:27.0f]
#define kSubtitleFont [UIFont systemFontOfSize:11.0f]
#define kSourceFont [UIFont systemFontOfSize:12.0f]
#define kDistanceFont [UIFont systemFontOfSize:12.0f]
#define kCellHeightConstraint 240
#define kCellSubtitleHeightConstraint 200
#define kCellPaddingLeft 10
#define kCellPaddingTop 5
#define kCellColorBarWidth 11
#define kStarLeftPadding 37
#define kStarTopPadding 10+2
#define kStarHeight 14.75
#define kCellCornerRad 0.0
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height > 500 )
#define BLUE_COLOR [UIColor colorWithRed:100.0f/255.0f green:185.0f/255.0f blue:250.0f/255.0f alpha:1.0f]
@implementation GeoScrollViewController
@synthesize  scopedGSObjectArray,GSObjectArray, loadedGSObjectArray,currentSearch,userLocation,fullscreenButton;

#pragma mark view load up and data preparation methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

-(void)viewDidLoad
{
    NSLog(@"view didload");

    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@""];
    });
    self.GSObjectArray = [[NSMutableArray alloc] init];
    self.loadedGSObjectArray = [[NSMutableArray alloc] init];
    self.scopedGSObjectArray = [[NSMutableArray alloc] init];
    self.canSearch = NO;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.tableView.frame = self.view.bounds;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setScrollsToTop:YES];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.alpha=0;
    [self.tableView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [self.view addSubview:self.tableView];
    GSserialQueue = dispatch_queue_create("com.example.GSSerialQueue", NULL);
    GSdataSerialQueue = dispatch_queue_create("com.example.GSDataSerialQueue", NULL);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(underLeftWillDisappear)
                                                 name:ECSlidingViewUnderLeftWillDisappear object:nil];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        [self didRefreshTable:nil];

    });
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
    
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft||orientation == UIInterfaceOrientationLandscapeRight) {
        [self.slidingViewController setAnchorLeftPeekAmount:160.0f];
        [self.slidingViewController resetTopView];
    }else{
        [self.slidingViewController setAnchorLeftPeekAmount:1.0f];
    }

    
    
}




    
    
    




-(void)prepareDataForDisplay
{
    NSLog(@"running prepareDataForDisplay");
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
        [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self slowReload];
            if ([[UIDevice currentDevice] systemVersion].floatValue < 6.0)
            {
                int64_t delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underLeftViewController).mapView.region;
                    [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:@"" IntoArray:self.GSObjectArray WithRefresh:YES];
                    NSLog(@"loading completed");

                    [self.tableView reloadData];
                    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                    [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.loadedGSObjectArray.count] duration:2.0 animated:YES];
                   
                    
                });
            }
            else
            {
           
            }
            
        });
    });
    
    
    
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view willappear");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topDidAnchorLeft ) name:ECSlidingViewTopDidAnchorLeft object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underRightWillDisappear) name:ECSlidingViewUnderRightWillDisappear object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underLeftWillAppear) name:ECSlidingViewUnderLeftWillAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underLeftWillDisappear) name:ECSlidingViewUnderLeftWillDisappear object:nil];
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[UnderMapViewController class]]) {
        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"UnderMap"];
    }


    [self.tableView reloadData];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"view will dis");
    [self resignFirstResponder];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}


//calculates scope and updates loaded array into display array , when region is omitted, all data is used.
-(void)recalculateScopeFromLoadedArray:(NSMutableArray*)loadedArray WithRegion:(MKCoordinateRegion)region AndSearch:(NSString*)search IntoArray:(NSMutableArray*)resultArray WithRefresh:(BOOL)refresh
{
    NSLog(@"calling recalculate");
    __block MKMapRect updateRect;
    self.random = NO;
    [resultArray removeAllObjects];
    
    MKMapView* map = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    
    if (refresh) {
        

        if (((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs){
            [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.pointsArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.pointsArray.count-1)]];
            [map removeOverlays:map.overlays];
            //
            memset( ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.points, 1, ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.pointCount-1);
            ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.pointCount = 1;
        }
    }
    for (Event* gsObj in loadedArray)
    {
          
            if (refresh)
            {
                
                if (!((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs)
                {
                    NSLog(@"alloc crumbpath");
                    
                    ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs = [[CrumbPath alloc] initWithCenterCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue)];
                    
                }
                if (map.overlays.count == 0) {
                    NSLog(@"adding overlay");
                    [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];    
                    NSLog(@"done adding overlay count = %d",map.overlays.count);
                    
                }

                updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor redColor]];
             
            }
            
            if([self coordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) ContainedinRegion:region])
            {
                [resultArray addObject:gsObj];
            }
            
            
        
    }
    
    if (refresh)
    {
        NSLog(@"drawing map rect");
        dispatch_async(dispatch_get_main_queue(), ^
       {
           [SVProgressHUD dismiss];
           [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbView setNeedsDisplayInMapRect:MKMapRectWorld];
           MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
           [underMapView setVisibleMapRect:MKMapRectInset([underMapView visibleMapRect], [underMapView visibleMapRect].size.width*0.005, [underMapView visibleMapRect].size.height*0.005) animated:YES];
           NSLog(@"resizing..");
           
       });
        
        
    }else{
        NSLog(@"not refresh");
    }
    NSLog(@"done recalculating");
    //    self.canSearch = YES;
}


-(void)selectedInstructions:(id)sender
{
    [sender removeFromSuperview];
    sender = nil;
}


//checks if a point is in the region
-(BOOL)coordinate:(CLLocationCoordinate2D)coord ContainedinRegion:(MKCoordinateRegion)region
{
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    if (
        coord.latitude  >= northWestCorner.latitude &&
        coord.latitude  <= southEastCorner.latitude &&
        
        coord.longitude >= northWestCorner.longitude &&
        coord.longitude <= southEastCorner.longitude
        )
    {
        return YES;
    }else {
        return NO;
    }
}

//zoom to a particular location .. used in table select .. doesnt reload, just zooms
- (void)updateMapZoomLocation:(CLLocationCoordinate2D)newLocation WithZoom:(BOOL)zoom
{
    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    MKCoordinateRegion region;
    region.center.latitude = newLocation.latitude;
    region.center.longitude = newLocation.longitude;
    if (zoom) {
        region.span.latitudeDelta = 0.01000f;
        region.span.longitudeDelta = 0.01000f;
        
    }else{
        region.span.latitudeDelta = underMapView.region.span.latitudeDelta;
        region.span.longitudeDelta =underMapView.region.span.longitudeDelta;
    }
    
    
    [underMapView setRegion:region animated:YES];
    
    
}


#pragma mark Notification Center Handlers

-(void)didReceiveUserLocation:(MKUserLocation*)location
{
    NSLog(@"did recieve user location");
    userLocation = location;

}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


-(void)topDidAnchorRight{
    NSLog(@"topDidAnchorRight");
}
-(void)topDidAnchorLeft
{
    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    for (id annnote in underMapView.annotations) {
        if ([annnote isKindOfClass:[MKUserLocation class]]) {
            //NOOP
        }else{
            
            [underMapView selectAnnotation:annnote animated:YES];
        }
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft||orientation == UIInterfaceOrientationLandscapeRight) {
        
    }else{
        
        UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
        menuViewController.InfoPanelView.frame = CGRectMake(self.view.bounds.size.width-320, self.view.bounds.size.height, 320, 75);
        menuViewController.InfoPanelView.hidden = NO;
        menuViewController.shopLabel.hidden = NO;
        menuViewController.shopImageView.hidden = NO;
        menuViewController.locationButtonView.hidden = NO;
        menuViewController.locationButton.hidden = NO;
        menuViewController.resetTopViewButton.hidden = NO;
        [menuViewController.resetTopViewButton addGestureRecognizer:self.slidingViewController.panGesture];
        menuViewController.allButton.hidden = NO;
        
        CGRect shopImageViewFinalFrame = CGRectMake(menuViewController.shopImageView.frame.origin.x, menuViewController.view.bounds.size.height-75+7, menuViewController.shopImageView.frame.size.width, menuViewController.shopImageView.frame.size.height);
        CGRect shopLabelFinalFrame = CGRectMake(menuViewController.shopLabel.frame.origin.x, menuViewController.view.bounds.size.height-75+7, menuViewController.shopLabel.frame.size.width, menuViewController.shopLabel.frame.size.height);
        
        menuViewController.shopLabel.frame = CGRectMake(menuViewController.shopLabel.frame.origin.x, menuViewController.view.bounds.size.height, menuViewController.shopLabel.frame.size.width, menuViewController.shopLabel.frame.size.height);
        
        menuViewController.shopImageView.frame = CGRectMake(menuViewController.shopImageView.frame.origin.x, menuViewController.view.bounds.size.height, menuViewController.shopImageView.frame.size.width, menuViewController.shopImageView.frame.size.height);
        
        CGRect slideViewFinalFrame = CGRectMake(menuViewController.view.bounds.size.width-320, menuViewController.view.bounds.size.height-75, menuViewController.view.bounds.size.width, 75);
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             menuViewController.InfoPanelView.frame = slideViewFinalFrame;
                             menuViewController.shopImageView.frame = shopImageViewFinalFrame;
                             menuViewController.shopLabel.frame = shopLabelFinalFrame;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                         }];
        
        menuViewController.shouldShowPinAnimation = YES;
    }
}

-(void)underLeftWillAppear
{
}
-(void)underLeftWillDisappear
{
    

    
}

-(void)underRightWillDisappear
{

        if (self.slidingViewController.underRightShowing) {
            
            UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
            NSLog(@"underright will disappear");

            menuViewController.InfoPanelView.hidden = YES;
            menuViewController.shopLabel.hidden = YES;
            menuViewController.locationButtonView.hidden = YES;
            menuViewController.shopImageView.hidden = YES;
            menuViewController.locationButton.hidden = YES;
            menuViewController.resetTopViewButton.hidden = YES;
            [menuViewController.resetTopViewButton removeGestureRecognizer:self.slidingViewController.panGesture];
            menuViewController.allButton.hidden = YES;
            menuViewController.categorySelectionButton.hidden = YES;
            MKMapView* underMapView = menuViewController.mapView;
            MKMapRect newRegion = underMapView.visibleMapRect;
            
            // can only collect more data if the new region is greater than the largest crawled region.
            if(MKMapRectContainsRect(oldRegion, newRegion)){
                //we've crawled data here before, its in the cache.
            }else{
                oldRegion = newRegion;
            }

            static dispatch_once_t dispatchOnceToken;
            dispatch_once(&dispatchOnceToken, ^{
            dispatch_async(GSserialQueue, ^{
                
                MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
                [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"calling table reload");
                    [self.tableView reloadData];
                });
                for (id annnote in underMapView.annotations) {
                    if ([annnote isKindOfClass:[MKUserLocation class]]) {
                        //NOOP
                    }else{
                        //[underMapView deselectAnnotation:annnote animated:YES];
                        if ([self.GSObjectArray containsObject:annnote]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.GSObjectArray indexOfObject:annnote]+1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                            });
                            
                        }
                        
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                    [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                    [SVProgressHUD dismiss];
                    dispatchOnceToken = 0;
                });
            });
        });
    }

}

#pragma mark scroll view delegates

-(void)didScrollToEntryAtIndex:(int)idx
{
    if (self.random) {
        idx = self.randomIndex;
    }
    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    for (id annnote in underMapView.annotations) {
        if ([annnote isKindOfClass:[MKUserLocation class]]) {
            //NOOP
        }else{
            [underMapView removeAnnotation:annnote];  // remove any annotations that exist
        }
    }
    Event* gsObj = [self.GSObjectArray objectAtIndex:idx];
    self.selectedGsObject = gsObj;
    
    [underMapView addAnnotation:gsObj];
    UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
    menuViewController.shopLabel.text = gsObj.title;
    [menuViewController.shopImageView setImageWithURL:[NSURL URLWithString:gsObj.logo_ssl]];
    menuViewController.gsObjSelected = gsObj;

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    
    for (UITableViewCell* tablecell in [((UITableView*)scrollView) visibleCells]) {
        [tablecell setNeedsLayout];
    }
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollViewDidEndDecelerating:scrollView];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self animatePin];
    
}



#pragma mark - Search Bar Delegates



-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    return NO;
}



#pragma mark - Table View




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if ([GSObjectArray count]>0) {
        if (self.random) {
            return 3;
        }
        return [GSObjectArray count]+2;
    }
    return 2;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if(indexPath.row == 0){
            return 131;
        }else if( indexPath.row == [GSObjectArray count]+1){
            if([GSObjectArray count]==0)
            {
                return 285;
            }
            else
            {
                return 175;
            }
        }
        return ((Event*)[GSObjectArray objectAtIndex:indexPath.row-1]).cell_height.intValue;
}



-(void)didTapCell:(UITapGestureRecognizer*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:sender.view.superview.tag inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        if (indexPath.row == 0 || indexPath.row == [self.GSObjectArray count]+1)
        {
            return;
        }
    
    Event* selectedGSObj;
    selectedGSObj   = [self.GSObjectArray objectAtIndex:indexPath.row-1];

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",selectedGSObj.url]];
    NSLog(@"url = %@",URL);
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];

    [self.navigationController pushViewController:webViewController animated:YES];
    
}






-(void)didTouchMapAtCoordinate:(CLLocationCoordinate2D)mapTouchCoordinate
{
    MKMapView* map = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    CLLocation* touchLocation = [[CLLocation alloc]initWithLatitude:mapTouchCoordinate.latitude longitude:mapTouchCoordinate.longitude];
    MKZoomScale currentZoomScale = map.bounds.size.width / map.visibleMapRect.size.width;
    UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
    
    for (Event* gsObj in self.loadedGSObjectArray)
    {
        CLLocation* location = [[CLLocation alloc]initWithLatitude:gsObj.latitude.doubleValue longitude:gsObj.longitude.doubleValue];
        if ([touchLocation distanceFromLocation:location]< (0.2*MKRoadWidthAtZoomScale(currentZoomScale)))
        {
            
            CGRect shopImageViewFinalFrame = CGRectMake(menuViewController.shopImageView.frame.origin.x,menuViewController.view.bounds.size.height-75+7, menuViewController.shopImageView.frame.size.width, menuViewController.shopImageView.frame.size.height);
            CGRect shopLabelFinalFrame = CGRectMake(menuViewController.shopLabel.frame.origin.x, menuViewController.view.bounds.size.height-75+7, menuViewController.shopLabel.frame.size.width, menuViewController.shopLabel.frame.size.height);
            CGRect slideViewFinalFrame = CGRectMake(00, menuViewController.view.bounds.size.height-75, 320, 75);
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 menuViewController.InfoPanelView.frame =  CGRectMake(menuViewController.InfoPanelView.frame.origin.x, menuViewController.view.bounds.size.height, menuViewController.InfoPanelView.frame.size.width, menuViewController.InfoPanelView.frame.size.height);
                                 menuViewController.shopLabel.frame = CGRectMake(menuViewController.shopLabel.frame.origin.x, menuViewController.view.bounds.size.height, menuViewController.shopLabel.frame.size.width, menuViewController.shopLabel.frame.size.height);
                                 menuViewController.shopImageView.frame = CGRectMake(menuViewController.shopImageView.frame.origin.x, menuViewController.view.bounds.size.height, menuViewController.shopImageView.frame.size.width, menuViewController.shopImageView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 MKCoordinateRegion region =map.region;
                                 [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:self.currentSearch IntoArray:self.GSObjectArray WithRefresh:NO];
                                 [self.tableView reloadData];
                                 if ([self.GSObjectArray containsObject:gsObj]) {
                                     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.GSObjectArray indexOfObject:gsObj]+1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                                 }else{
                                     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                 }
                                 [UIView animateWithDuration:0.2
                                                       delay:0.0
                                                     options: UIViewAnimationOptionCurveEaseOut
                                                  animations:^{
                                                      menuViewController.InfoPanelView.frame = slideViewFinalFrame;
                                                      menuViewController.shopLabel.frame = shopLabelFinalFrame;
                                                      menuViewController.shopImageView.frame = shopImageViewFinalFrame;
                                                  }
                                                  completion:^(BOOL finished){
                                                      
                                                  }];
                             }];
            
            [self animatePin];
            break;
        }
    }
}

-(void)dismissSelf:(UIButton*) sender
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         sender.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [sender removeFromSuperview];
                     }];
}

-(BOOL)shouldAutorotate{
    
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

-(void)showMap
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}


-(void)animatePin
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version floatValue]>5.1) {
    MKMapView* underMapView = ((MKMapView*)((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView);
    for (id annote in underMapView.annotations) {
        if ([annote isKindOfClass:[Event class]]) { //should only have one
            MKAnnotationView*annView = [underMapView viewForAnnotation:annote];
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CATransform3D zRotation;
                zRotation = CATransform3DMakeRotation(-M_PI/6, 0, 0, 1.0);
                annView.layer.transform = zRotation;
                
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    CATransform3D zRotation;
                    zRotation = CATransform3DMakeRotation(M_PI/6, 0, 0, 1.0);
                    annView.layer.transform = zRotation;
                    
                }completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        CATransform3D zRotation;
                        zRotation = CATransform3DMakeRotation(-M_PI/6, 0, 0, 1.0);
                        annView.layer.transform = zRotation;
                        
                    }completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            CATransform3D zRotation;
                            zRotation = CATransform3DMakeRotation(M_PI/8, 0, 0, 1.0);
                            annView.layer.transform = zRotation;
                            
                        }completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                CATransform3D zRotation;
                                zRotation = CATransform3DMakeRotation(-M_PI/8, 0, 0, 1.0);
                                annView.layer.transform = zRotation;
                                
                            }completion:^(BOOL finished) {
                                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                    CATransform3D zRotation;
                                    zRotation = CATransform3DMakeRotation(0, 0, 0, 1.0);
                                    annView.layer.transform = zRotation;
                                    
                                }completion:^(BOOL finished) {
                                    
                                }];
                            }];
                        }];
                    }];
                }];
            }];
            
            
        }
    }
        
    }
}


-(void)clearBgColorForButton:(UIButton*)sender
{
    NSLog(@"changing background color");
    [sender setBackgroundColor:[UIColor whiteColor]];
}
-(void)setBgColorForButton:(UIButton*)sender
{
    NSLog(@"changing background color");
    [sender setBackgroundColor:[UIColor lightGrayColor]];
}
-(void)showMap:(UIButton*)sender
{
     [self.slidingViewController anchorTopViewTo:ECLeft];
}


-(void)getDirectionsToSelectedGSObj
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Directions" message:@"This will open maps app on your phone" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.delegate = self;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self showDirectionsViaRedirect];
    }
    else
    {
    }
}
-(void)showDirectionsViaRedirect{
    NSString* saddr = @"Current+Locaton";
    NSString* daddr = @"";
    
    if([[UIApplication sharedApplication] canOpenURL:
        [NSURL URLWithString:@"comgooglemaps://"]]){
        saddr = [NSString stringWithFormat:@"%f,%f", self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude];
        daddr = [NSString stringWithFormat:@"%f,%f", self.selectedGsObject.latitude.doubleValue,self.selectedGsObject.longitude.doubleValue];
        NSLog(@"");
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&zoom=14&directionsmode=driving",saddr,daddr]]];
    }else{
        
        NSString* urlStr;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=6) {
            //iOS 6+, Should use map.apple.com. Current Location doesn't work in iOS 6 . Must provide the coordinate.
            if ((self.userLocation.coordinate.latitude != kCLLocationCoordinate2DInvalid.latitude) && (self.userLocation.coordinate.longitude != kCLLocationCoordinate2DInvalid.longitude)) {
                //Valid location.
                saddr = [NSString stringWithFormat:@"%f,%f", self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude];
                urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@", saddr, daddr];
            } else {
                //Invalid location. Location Service disabled.
                urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%@", daddr];
            }
        } else {
            // < iOS 6. Use maps.google.com
            urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@", saddr,daddr];
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
    }
    
    
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"did recieve memory warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)slowReload
{
    if (self.tableView.alpha==0) {
        [self.tableView reloadData];
        [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.tableView.alpha=1;
                     } 
                     completion:^(BOOL finished){

                     }];
    }else{
        [self.tableView reloadData];
    }
}
-(NSString*)currentDateString
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    NSDate *localDate = [NSDate date];
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    NSTimeInterval gmtTimeInterval = [localDate timeIntervalSinceReferenceDate] - timeZoneOffset;
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    return [format stringFromDate:gmtDate];
}



-(void)didSelectImage:(id)sender
{
    if (((UIImageView*)((UITapGestureRecognizer*)sender).view).image != nil) {
        CGRect startRect = [((UIImageView*)((UITapGestureRecognizer*)sender).view) convertRect:self.view.bounds toView:nil];
        self.fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fullscreenButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
        [self.fullscreenButton setFrame:CGRectMake(startRect.origin.x, startRect.origin.y, ((UITapGestureRecognizer*)sender).view.bounds.size.height, ((UITapGestureRecognizer*)sender).view.bounds.size.height)];
        UIImageView* newImageView = [[UIImageView alloc]initWithFrame:self.fullscreenButton.bounds];
        [newImageView setImage:((UIImageView*)((UITapGestureRecognizer*)sender).view).image];
        [newImageView setContentMode:UIViewContentModeScaleAspectFit];
        [newImageView setUserInteractionEnabled:NO];
        [self.fullscreenButton addSubview:newImageView];
        [self.view addSubview:self.fullscreenButton];
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.fullscreenButton.frame = self.view.bounds;
                             newImageView.frame = self.view.bounds;
                         }
                         completion:^(BOOL finished){
                             [self.fullscreenButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
                         }];
    }
    
}
@end