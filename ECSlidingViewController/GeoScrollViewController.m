#import "GeoScrollViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "GSObject.h"
#import "GScursor.h"
#import "SorterCell.h"
#import "EndTableCell.h"
#import "RotatingTableCell.h"
#import "MapSlidingViewController.h"
#import "UnderMapViewController.h"
#import "CustomCalloutView.h"
#import "AFNetworking.h"
#import "AFHTTPClient.h"
#import "HHStarView.h"
#import "ViewController.h"
#import "CircleLayout.h"
#import "ShopDetailViewController.h"
#define kMainFont [UIFont systemFontOfSize:25.0f]
#define kCellHeightConstraint 260
#define kCellPaddingLeft 3
#define kCellPaddingTop 3
#define kCellColorBarWidth 11
#define kStarLeftPadding 37
#define kStarTopPadding 10+2
#define kStarHeight 14.75
#define kCellCornerRad 20.0
@implementation GeoScrollViewController
@synthesize  GSObjectArray, loadedGSObjectArray,currentSearch;

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
    NSLog(@"viewdidload for geoscroll");
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topDidAnchorRight ) name:ECSlidingViewTopDidAnchorRight object:nil];
    
    self.GSObjectArray = [[NSMutableArray alloc] init];
    self.loadedGSObjectArray = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollsToTop = YES;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    [self LoadData];
}
-(void)LoadData
{
    [((UnderMapViewController*)self.slidingViewController.underRightViewController) dismissCallout];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //    dispatch_async(dispatch_get_current_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topDidAnchorRight ) name:ECSlidingViewTopDidAnchorRight object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underLeftWillDisappear) name:ECSlidingViewUnderLeftWillDisappear object:nil];
        
        NSString * dbFile = [[NSBundle mainBundle] pathForResource:@"lovesgfood" ofType:@"json"];
        NSString * contents = [NSString stringWithContentsOfFile:dbFile encoding:NSASCIIStringEncoding error:nil];
        NSData* filedata = [contents dataUsingEncoding:NSUTF8StringEncoding];
//        
//        [self processData:filedata];
//        
        dbFile = [[NSBundle mainBundle] pathForResource:@"ladyic" ofType:@"json"];
        contents = [NSString stringWithContentsOfFile:dbFile encoding:NSASCIIStringEncoding error:nil];
        filedata = [contents dataUsingEncoding:NSUTF8StringEncoding];
        
        [self processData:filedata];
//
//        dbFile = [[NSBundle mainBundle] pathForResource:@"ieat" ofType:@"json"];
//        contents = [NSString stringWithContentsOfFile:dbFile encoding:NSASCIIStringEncoding error:nil];
//        
//        filedata = [contents dataUsingEncoding:NSUTF8StringEncoding];
//        
//        [self processData:filedata];

//        dbFile = [[NSBundle mainBundle] pathForResource:@"testing" ofType:@"json"];
//        contents = [NSString stringWithContentsOfFile:dbFile encoding:NSASCIIStringEncoding error:nil];
//        
//        filedata = [contents dataUsingEncoding:NSUTF8StringEncoding];
//        
//        [self processData:filedata];
        
        [self prepareDataForDisplay];
        
    });
}

-(void)prepareDataForDisplay
{
    if(userLocation)
    {
        [self sortLoadedArray:self.loadedGSObjectArray ByVariable:@"distanceInMeters" IntoArray:self.GSObjectArray ascending:YES];
    }
    NSLog(@"%d entries",self.loadedGSObjectArray.count);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underLeftViewController).mapView.region;
            [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:@"" IntoArray:self.GSObjectArray WithRefresh:YES];
        });
    });

}
-(void)processData:(id)data
{
    if (data==nil)return;
    NSMutableArray* dataArray = [[NSMutableArray alloc]init];
    dataArray = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:kNilOptions
                 error:nil];
    
    for (NSDictionary* dataObject in dataArray) {
        GSObject *gsObject = [[GSObject alloc] init];
        
        if ([[dataObject objectForKey:@"title"] isEqual:[NSNull null]])
        {
            continue;
        }
        else
        {
            //gsObject.objectID = [dataObject objectForKey:@"id"];
            
            gsObject.title = [dataObject objectForKey:@"title"];
            gsObject.subTitle = [dataObject objectForKey:@"subtitle"];
            CGSize s = [gsObject.title sizeWithFont:[UIFont systemFontOfSize:25.0f] constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
            
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 10)];
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 10)];//padding btw star
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + MAX(30,s.height))];
            
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 2)];//padding btw title and subtitle;
            CGSize x = [gsObject.subTitle sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
            
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + MAX(30,x.height))];
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 10)];
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 14.75)];
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 2)];//padding btw title and subtitle;
            gsObject.descriptionhtml = [dataObject objectForKey:@"descriptionHTML"];
            gsObject.source = [dataObject objectForKey:@"source"];
            if ([[dataObject objectForKey:@"source"] isEqualToString:@"Lady Iron Chef"]) {
                gsObject.cursorColor = [UIColor blueColor]; //lady iron chef
            }else if ([[dataObject objectForKey:@"source"] isEqualToString:@"ieatishootipost"]) {
                gsObject.cursorColor = [UIColor redColor];//ieat
            }else{
                gsObject.cursorColor = [UIColor blackColor]; //lovesgfood                
            }
            

            
        }
        if ([[dataObject objectForKey:@"image"] isEqual:[NSNull null]])
        {
            continue;
        }
        else
        {
            gsObject.imageArray = [NSArray arrayWithArray:[dataObject objectForKey:@"image"]];
        }
        if ([[dataObject objectForKey:@"description"] isEqual:[NSNull null]])
        {
            continue;
        }
        else
        {
            NSString* descarray = [[NSString alloc]init];
            for (NSString* desc in [dataObject objectForKey:@"description"]) {
                descarray = [descarray stringByAppendingString:[NSString stringWithFormat:@"%@\n",desc]];
            }
            gsObject.description = descarray;
            
            
        }
        
        if ([[dataObject objectForKey:@"latitude"] isEqual:[NSNull null]] || [[dataObject objectForKey:@"longitude"] isEqual:[NSNull null]])
        {
            NSLog(@"couldnt find lat lon");
            continue;
        }
        
        gsObject.latitude =[NSNumber numberWithDouble: [[dataObject objectForKey:@"latitude"] doubleValue]];
        gsObject.longitude =[NSNumber numberWithDouble:[[dataObject objectForKey:@"longitude"] doubleValue]];
        
        [self.loadedGSObjectArray addObject:gsObject];
    }
        
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"firsttop appearing");
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
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"firststop disappearing");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark custom methods
//sorts loaded array by gsobject variable, recalculates and adds relavent data to display array
-(void)sortLoadedArray:(NSMutableArray*)loadedArray ByVariable:(NSString*)variable IntoArray:(NSMutableArray*)resultArray ascending:(BOOL)ascending
{
    if ([variable isEqualToString:@"distanceInMeters"]) {
        currentScopeType = kScopeTypeDistance;
        //reset location info based on new location
        if (userLocation) {
            for (GSObject* gsObj in loadedArray)
            {
                CLLocation *gsLoc = [[CLLocation alloc] initWithLatitude:gsObj.latitude.doubleValue longitude:gsObj.longitude.doubleValue];
                CLLocationDistance meters = [gsLoc distanceFromLocation:userLocation.location];
                [gsObj setDistanceInMeters:[NSNumber numberWithDouble:meters]];
            }
        }
    }else if([variable isEqualToString:@"likes"]){
        currentScopeType = kScopeTypeLikes;
    }else if([variable isEqualToString:@"dealCount"]){
        currentScopeType = kScopeTypeDeals;
    }
    
    NSSortDescriptor * frequencyDescriptor =
    [[NSSortDescriptor alloc] initWithKey:variable
                                ascending:ascending] ;
    NSArray * descriptors = [NSArray arrayWithObjects:frequencyDescriptor, nil];
    NSArray * sortedArray = [loadedArray sortedArrayUsingDescriptors:descriptors];
    [loadedArray removeAllObjects];
    [loadedArray addObjectsFromArray:sortedArray];
    //adjust points to scope
    MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
    [self recalculateScopeFromLoadedArray:loadedArray WithRegion:region AndSearch:currentSearch IntoArray:resultArray WithRefresh:YES];
}

//sorts both loaded and display arrays by gsobject variable
-(void)sortLoadedArray:(NSMutableArray*)loadedArray andArray:(NSMutableArray*)resultArray ByVariable:(NSString*)variable  ascending:(BOOL)ascending
{
    if ([variable isEqualToString:@"distanceInMeters"]) {
        currentScopeType = kScopeTypeDistance;
        if (userLocation) {
            for (GSObject* gsObj in loadedArray)
            {
                CLLocation *gsLoc = [[CLLocation alloc] initWithLatitude:gsObj.latitude.doubleValue longitude:gsObj.longitude.doubleValue];
                CLLocationDistance meters = [gsLoc distanceFromLocation:userLocation.location];
                [gsObj setDistanceInMeters:[NSNumber numberWithDouble:meters]];
            }
            for (GSObject* gsObj in resultArray)
            {
                CLLocation *gsLoc = [[CLLocation alloc] initWithLatitude:gsObj.latitude.doubleValue longitude:gsObj.longitude.doubleValue];
                CLLocationDistance meters = [gsLoc distanceFromLocation:userLocation.location];
                [gsObj setDistanceInMeters:[NSNumber numberWithDouble:meters]];
            }
        }
    }else if([variable isEqualToString:@"likes"]){
        currentScopeType = kScopeTypeLikes;
    }else if([variable isEqualToString:@"dealCount"]){
        currentScopeType = kScopeTypeDeals;
    }
    
    NSSortDescriptor * frequencyDescriptor =
    [[NSSortDescriptor alloc] initWithKey:variable
                                ascending:ascending] ;
    NSArray * descriptors = [NSArray arrayWithObjects:frequencyDescriptor, nil];
    NSArray * sortedArray = [loadedArray sortedArrayUsingDescriptors:descriptors];
    [loadedArray removeAllObjects];
    [loadedArray addObjectsFromArray:sortedArray];
    
    NSArray * sortedResultArray = [resultArray sortedArrayUsingDescriptors:descriptors];
    [resultArray removeAllObjects];
    [resultArray addObjectsFromArray:sortedResultArray];
    //adjust points to scope
    
}


//calculates scope and updates loaded array into display array , when region is omitted, all data is used.
-(void)recalculateScopeFromLoadedArray:(NSMutableArray*)loadedArray WithRegion:(MKCoordinateRegion)region AndSearch:(NSString*)search IntoArray:(NSMutableArray*)resultArray WithRefresh:(BOOL)refresh
{

        [resultArray removeAllObjects];
        MKMapView* map = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
        if (search.length > 0){//remove all annotations
            
            for (id annnote in map.annotations) {
                if ([annnote isKindOfClass:[MKUserLocation class]])
                {
                    //NOOP
                }else{
                    [map removeAnnotation:annnote];  // remove any annotations that exist
                }
            }
            
            
        }else{
            if (refresh) {
                for (id annnote in map.annotations) {
                    if ([annnote isKindOfClass:[MKUserLocation class]])
                    {
                        //NOOP
                    }else{
                        [map removeAnnotation:annnote];  // remove any annotations that exist
                    }
                }
            }
        }
    @synchronized(loadedArray){
        if (refresh) {
            if (((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs){
            [map removeOverlays:map.overlays];
            memset( ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.points, 1, ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.pointCount-1);
            ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs.pointCount = 1;
            }
        }
    
        for (GSObject* gsObj in loadedArray)
        {
            if (search.length > 0)
            {
                
                if([search caseInsensitiveCompare:gsObj.title] == NSOrderedSame || [gsObj.title rangeOfString:search options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound)
                {
                    if([self coordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) ContainedinRegion:region])
                    {
                        [resultArray addObject:gsObj];
                    }
                    
                    if (!((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs)
                    {
                        ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs = [[CrumbPath alloc] initWithCenterCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue)];
                        [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];
                        
                    }
                    if (map.overlays.count == 0) {
                        [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];
                    }
                    MKMapRect updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:gsObj.cursorColor];
                    
                    if (!MKMapRectIsNull(updateRect))
                    {
                        MKZoomScale currentZoomScale = (CGFloat)(map.bounds.size.width / map.visibleMapRect.size.width);
                        CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                        updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbView setNeedsDisplayInMapRect:updateRect];
                        });
                    }
                }
            }
            else
            {
                if (refresh)
                {
                    if (!((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs)
                        {
                            NSLog(@"alloc crumbpath");
                            ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs = [[CrumbPath alloc] initWithCenterCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue)];
                            [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];
                           
                        }
                        if (map.overlays.count == 0) {
                            NSLog(@"adding overlay");
                            [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];
                        }
                        MKMapRect updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:gsObj.cursorColor];
                        
                        if (!MKMapRectIsNull(updateRect))
                        {
                            // There is a non null update rect.
                            // Compute the currently visible map zoom scale
                            MKZoomScale currentZoomScale = (CGFloat)(map.bounds.size.width / map.visibleMapRect.size.width);
                            // Find out the line width at this zoom scale and outset the updateRect by that amount
                            CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                            updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                            // Ask the overlay view to update just the changed area.
                            dispatch_async(dispatch_get_main_queue(), ^{
                            [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbView setNeedsDisplayInMapRect:updateRect];
                                
                                
                                });
                        }
                }
                if([self coordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) ContainedinRegion:region])
                {
                    [resultArray addObject:gsObj];
                    
                }
            
            }
        }
            if (refresh||search.length>0) {
                int64_t delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //MKCoordinateRegion currentRegion= MKCoordinateRegionForMapRect(map.visibleMapRect);
                    
                    MKCoordinateRegion targetRegion= MKCoordinateRegionForMapRect(MKMapRectInset(map.visibleMapRect, map.visibleMapRect.size.width*0.005, map.visibleMapRect.size.height*0.005));
                    
                    //MKZoomScale currentZoomScale = (CGFloat)(map.bounds.size.width / map.visibleMapRect.size.width);
                    //NSLog(@"current zoom scale = %f",currentZoomScale);
                    [map setRegion:targetRegion animated:NO];
                });
            }

    }
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
    userLocation = location;
}
-(void)topDidAnchorRight{
    NSLog(@"topDidAnchorRight");
}
-(void)topDidAnchorLeft
{
    NSLog(@"top did anchor left");
    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    for (id annnote in underMapView.annotations) {
        if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
            //NOOP
        }else{
            NSLog(@"selecting annotation");
            [underMapView selectAnnotation:annnote animated:YES];
        }
    }

    UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
    menuViewController.locationButton.hidden = NO;
    menuViewController.allButton.hidden = NO;
    for (UIButton* btn in menuViewController.categoryButtons) {
        btn.hidden = NO;
    }
    menuViewController.categorySelectionButton.hidden = NO;
    menuViewController.shouldShowPinAnimation = YES;
}

-(void)underLeftWillAppear
{
//    [self.view removeGestureRecognizer:self.slidingViewController.panGesture];
//    self.coverView = [[UIView alloc]initWithFrame:self.view.bounds];
//    [self.coverView setBackgroundColor:[UIColor greenColor]];
//    [self.view addSubview:self.coverView];
//    
//    [self.view bringSubviewToFront:self.coverView];
//    [self.coverView addGestureRecognizer:self.slidingViewController.navigationController.slidingViewController.panGesture];
//    
}
-(void)underLeftWillDisappear
{
//    NSLog(@"underLeftWillDisAppear");
//    
//    for (UIGestureRecognizer* gr in self.view.gestureRecognizers) {
//        [self.view removeGestureRecognizer:gr];
//    }
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
//    
}

-(void)underRightWillDisappear
{
    if (self.slidingViewController.underRightShowing) {
        UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
        NSLog(@"underright will disappear");
        [menuViewController dismissCallout];
        menuViewController.locationButton.hidden = YES;
        menuViewController.allButton.hidden = YES;
        [menuViewController hideCategoryButtons];
        for (UIButton* btn in menuViewController.categoryButtons) {
            btn.hidden = YES;
        }
        menuViewController.categorySelectionButton.hidden = YES;
        MKMapView* underMapView = menuViewController.mapView;
        MKMapRect newRegion = underMapView.visibleMapRect;
        
        // can only collect more data if the new region is greater than the largest crawled region.
        if(MKMapRectContainsRect(oldRegion, newRegion)){
            //we've crawled data here before, its in the cache.
        }else{
            oldRegion = newRegion;
            //TODO: here we still need to crawl more data
        }
        for (id annnote in underMapView.annotations) {
            if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
                //NOOP
            }else{
                [underMapView deselectAnnotation:annnote animated:YES];
                
            }
        }
        
        
        //here we recalculate using span and find out which data sets sit in the map enclosed.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
            [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:NO];
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
                for (id annnote in underMapView.annotations) {
                    if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
                        //NOOP
                    }else{
                        //keep focus on the prev selected object
                        if ([self.GSObjectArray containsObject:annnote]) {
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.GSObjectArray indexOfObject:annnote]+1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                            for (UITableViewCell* tablecell in [self.tableView visibleCells]) {
                                [tablecell setNeedsLayout];
                            }
                        }else{
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                            
                        }
                    }
                }
                
            });
            
        });
   
    }
//    else{
//        [((MapSlidingViewController*)self.slidingViewController).navigationController.slidingViewController anchorTopViewTo:ECRight];
//
//    }
    
}

#pragma mark scroll view delegates

-(void)didScrollToEntryAtIndex:(int)idx
{
    
    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    for (id annnote in underMapView.annotations) {
        if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
            //NOOP
        }else{
            [underMapView removeAnnotation:annnote];  // remove any annotations that exist
        }
    }
    [underMapView addAnnotation:[self.GSObjectArray objectAtIndex:idx]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    for (UITableViewCell* tablecell in [((UITableView*)scrollView) visibleCells]) {
        [tablecell setNeedsLayout];
    }
}
-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView  {
    NSLog(@"shoudl scroll to top");
    return YES;
}
#pragma mark - Search Bar Delegates

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if (selectedScope == kScopeTypeDistance)
    {
        [self sortLoadedArray:self.loadedGSObjectArray andArray:self.GSObjectArray ByVariable:@"distanceInMeters" ascending:YES];
        [self.tableView reloadData];
        if ([self.GSObjectArray count]>0)
        {
            [self didScrollToEntryAtIndex:0];
        }
    }else if(selectedScope == kScopeTypeLikes){
        [self sortLoadedArray:self.loadedGSObjectArray andArray:self.GSObjectArray ByVariable:@"likes" ascending:NO];
        [self.tableView reloadData];
        if ([self.GSObjectArray count]>0)
        {
            [self didScrollToEntryAtIndex:0];
        }

    }else if(selectedScope == kScopeTypeDeals){
        [self sortLoadedArray:self.loadedGSObjectArray andArray:self.GSObjectArray ByVariable:@"dealCount" ascending:NO];
        [self.tableView reloadData];
        if ([self.GSObjectArray count]>0)
        {
            [self didScrollToEntryAtIndex:0];
        }
        
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        currentSearch = searchBar.text;
        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
        [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
        //TODO: should zoom to a level to contain all searches
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
        });
        
    });
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar
{
    currentSearch = @"";
    aSearchBar.text = @"";
    [aSearchBar resignFirstResponder];
	MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
        });
    //});
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if ([GSObjectArray count]>0) {
        return [GSObjectArray count]+2;
    }
    return 2;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 175;
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
    return ((GSObject*)[GSObjectArray objectAtIndex:indexPath.row-1]).cellHeight.intValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        static NSString *SorterCellIdentifier = @"SorterCell";
        SorterCell* cell = (SorterCell*) [tableView dequeueReusableCellWithIdentifier:SorterCellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SorterCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (SorterCell*)currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                }
            }
        }
        cell.searchBar.selectedScopeButtonIndex = currentScopeType;
        cell.searchBar.text = currentSearch;
        cell.parentViewController = self;
        cell.searchBar.delegate = self;

        cell.sorterBackgroundView.layer.cornerRadius = 20;
        
        return cell;
    
    }
    if(indexPath.row == [GSObjectArray count]+1){
        static NSString *EndCellIdentifier = @"EndTableCell";
        EndTableCell* endcell = (EndTableCell*) [tableView dequeueReusableCellWithIdentifier:EndCellIdentifier];
        if (endcell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EndTableCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    endcell = (EndTableCell*)currentObject;
                    endcell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
        }
        endcell.endTableBackgroundView.layer.cornerRadius = 20;
        
        return endcell;
    }
    GSObject* gsObj = [self.GSObjectArray objectAtIndex:indexPath.row-1];
    CGSize s = [gsObj.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize subTitleSize = [gsObj.subTitle sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
    NSString *FromCellIdentifier = [NSString stringWithFormat:@"%@,%d,%d",gsObj.source,(int)s.height,(int)subTitleSize.height];
    
    RotatingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier];

    if (cell == nil)
    {
        CGSize s = [gsObj.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize subTitleSize = [gsObj.subTitle sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        cell = [[RotatingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FromCellIdentifier];
        cell.mainCellView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, cell.bounds.size.width-2*kCellPaddingLeft, gsObj.cellHeight.intValue-kCellPaddingTop*2)];
        [cell.contentView addSubview:cell.mainCellView];
        cell.colorBarView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, kCellColorBarWidth, gsObj.cellHeight.intValue-kCellPaddingTop*2)];
        [cell.colorBarView setBackgroundColor:gsObj.cursorColor];
        [cell.contentView addSubview:cell.colorBarView];
        cell.starview = [[HHStarView alloc]initWithFrame:CGRectMake(kStarLeftPadding,kStarTopPadding+s.height+5, 80+kStarHeight+15, kStarHeight) andRating:0.0f animated:NO];
        [cell.contentView addSubview:cell.starview];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kStarLeftPadding,10,kCellHeightConstraint,s.height)];
        [cell.contentView addSubview:cell.titleLabel];

        
        cell.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kStarLeftPadding,kStarTopPadding + s.height+ kStarHeight+10 ,kCellHeightConstraint,subTitleSize.height)];
        [cell.contentView addSubview:cell.subTitleLabel];
    }
   
    cell.mainCellView.alpha = 0.3;
    cell.mainCellView.backgroundColor = [UIColor blackColor];
    
    



    cell.titleLabel.text = gsObj.title;
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    cell.titleLabel.textColor = [UIColor whiteColor];
    [cell.titleLabel setFont:kMainFont];
    [cell.titleLabel setNumberOfLines:0];

    cell.titleLabel.shadowColor = [UIColor blackColor];
    cell.titleLabel.shadowOffset = CGSizeMake(1, 1);



    cell.subTitleLabel.text = gsObj.subTitle;
    cell.subTitleLabel.backgroundColor = [UIColor clearColor];
    cell.subTitleLabel.textColor = [UIColor whiteColor];
    [cell.subTitleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [cell.subTitleLabel setNumberOfLines:0];
    cell.subTitleLabel.shadowColor = [UIColor blackColor];
    cell.subTitleLabel.shadowOffset = CGSizeMake(1, 1);

    
    
//    UILabel* dealCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(subTitleLabel.frame.size.width+kStarLeftPadding,kStarTopPadding + s.height+ kStarHeight ,70,subTitleSize.height)];
//    dealCountLabel.text = [NSString stringWithFormat:@"%d Deals",gsObj.dealCount.intValue];
//    dealCountLabel.backgroundColor = [UIColor clearColor];
//    dealCountLabel.textColor = [UIColor whiteColor];
//    [dealCountLabel setFont:[UIFont systemFontOfSize:12.0f]];
//    [dealCountLabel setTextAlignment:NSTextAlignmentRight];
//    [dealCountLabel setNumberOfLines:0];
//    dealCountLabel.shadowColor = [UIColor blackColor];
//    dealCountLabel.shadowOffset = CGSizeMake(1, 1);
//    [cell.contentView addSubview:dealCountLabel];
    
    
    
	[cell.starview rating:gsObj.shopScore.floatValue/10.0f withAnimation:NO];
    cell.mainCellView.layer.cornerRadius = 20;
    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, 2, 12, (gsObj.cellHeight.intValue - 10)) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(kCellCornerRad, kCellCornerRad)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = cell.colorBarView.layer.bounds;
    maskLayer.path = maskPath.CGPath;
    cell.colorBarView.layer.mask = maskLayer;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == [self.GSObjectArray count]+1) {
        return;
    }
    NSLog(@"did select row ");
        GSObject* selectedGSObj = [self.GSObjectArray objectAtIndex:indexPath.row-1];
    
//        CircleLayout* customLayout = [[CircleLayout alloc]init];
//
//        ViewController* viewController = [[ViewController alloc]initWithCollectionViewLayout:customLayout];
//        viewController.gsObject = selectedGSObj;
    ShopDetailViewController* viewController = [[ShopDetailViewController alloc]initWithNibName:@"ShopDetailViewController" bundle:nil];
    viewController.gsObject = selectedGSObj;
        [self.navigationController pushViewController:viewController animated:YES];
    
    //pin should not be moving on clicked
   // menuViewController.shouldShowPinAnimation = NO;
   // [self updateMapZoomLocation:CLLocationCoordinate2DMake(selectedGSObj.latitude.doubleValue, selectedGSObj.longitude.doubleValue) WithZoom:YES];
   // [self.slidingViewController anchorTopViewTo:ECRight];
   // [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}



#pragma mark unmark icloudbackup
#include <sys/xattr.h> // Needed import for setting file attributes

+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)fileURL {
    
    // First ensure the file actually exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        NSLog(@"File %@ doesn't exist!",[fileURL path]);
        return NO;
    }
    
    // Determine the iOS version to choose correct skipBackup method
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer isEqualToString:@"5.0.1"]) {
        const char* filePath = [[fileURL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        NSLog(@"Excluded '%@' from backup",fileURL);
        return result == 0;
    }
    else if (&NSURLIsExcludedFromBackupKey) {
        NSError *error = nil;
        BOOL result = [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (result == NO) {
            NSLog(@"Error excluding '%@' from backup. Error: %@",fileURL, error);
            return NO;
        }
        else { // Succeeded
            NSLog(@"Excluded '%@' from backup",fileURL);
            return YES;
        }
    } else {
        // iOS version is below 5.0, no need to do anything
        return YES;
    }
}

@end