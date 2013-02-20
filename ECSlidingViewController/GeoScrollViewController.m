#import "SVWebViewController.h"
#import "SearchViewController.h"
#import "GeoScrollViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CrumbObj.h"
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

#define kMainFont [UIFont systemFontOfSize:25.0]
#define kSubtitleFont [UIFont systemFontOfSize:12.0f]
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
@implementation GeoScrollViewController
@synthesize  scopedGSObjectArray,GSObjectArray, loadedGSObjectArray,currentSearch,userLocation;

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
    
    self.boolhash = [[NSMutableDictionary alloc] init];
    self.GSObjectArray = [[NSMutableArray alloc] init];
    self.loadedGSObjectArray = [[NSMutableArray alloc] init];
    self.scopedGSObjectArray = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin ;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollsToTop = YES;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^
   {
      
       [SVProgressHUD showWithStatus:@"Loading"];
   });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self LoadData];
    });

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}



-(void)didRefreshTable:(id)sender
{
    NSArray* menuItems = [NSArray arrayWithObjects:@"IEATISHOOTIPOST",@"LADY IRON CHEF",@"LOVE SG FOOD",@"SGFOODONFOOT",@"DANIEL FOOD DIARY", nil];
    
    
    
    NSMutableArray* delarray = [[NSMutableArray alloc]init];
    for (NSString* blog in menuItems)
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:blog] isEqualToString:@"Enabled"])
        {
             NSLog(@" enabled");
            if (![[self.boolhash objectForKey:blog] isEqualToString:@"Enabled"])
            {
                        [self retrieveAndProcessDataFromCacheOrServerForBlog:blog];
                        [self.boolhash setObject:@"Enabled" forKey:blog];
                                                 
            }else{
                NSLog(@"already enabled");
            }
        }
        else
        {
            if ([[self.boolhash objectForKey:blog] isEqualToString:@"Enabled"])
            {
                
                for (GSObject* gsobj in self.loadedGSObjectArray)
                {
                    if ([gsobj.source isEqualToString:blog])
                    {
                        [delarray addObject:gsobj];
                    }
                }
                
                [self.boolhash setObject:@"Disabled" forKey:blog];
                
                for (GSObject* delgs in delarray)
                {
                    [self.loadedGSObjectArray removeObject:delgs];
                }
               
            }
        }
    }
    [self prepareDataForDisplay];
    dispatch_async(dispatch_get_main_queue(), ^
   {
       NSLog(@"dismissing progress hud");
       [SVProgressHUD dismiss];
   });
    
}

-(void)retrieveAndProcessDataFromCacheOrServerForBlog:(NSString*)blog
{

 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *yourArrayFileName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat",blog]];
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfFile:yourArrayFileName options:NSDataReadingMappedIfSafe error:&error];
    if (error)
    {
        NSLog(@"error = %@",error);
        //if error get from main bundle .. means first launch
        NSString* dbFile = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",blog] ofType:@"dat"];
        NSData* filedata = [NSData dataWithContentsOfFile:dbFile options:NSDataReadingMappedIfSafe error:&error];
        NSArray *archivedArray = [NSKeyedUnarchiver unarchiveObjectWithData:filedata];
        [self processData:archivedArray];
    }
    else
    {
        NSArray *archivedArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSLog(@"got data from file %@",yourArrayFileName);
        [self processData:archivedArray];
        
    }




    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tastebudsapp.herokuapp.com/items?source=%@",[blog stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
    
    NSLog(@"url = %@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSLog(@"recieved response json");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
        {
            NSString *dataArrayName;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            dataArrayName = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat",blog]];
                                
            NSData *retrieveddata = [NSKeyedArchiver archivedDataWithRootObject:JSON];
            if (![retrieveddata isEqualToData:data])
            {
                [retrieveddata writeToFile:yourArrayFileName atomically:YES];
                [[self class]addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dataArrayName]];
                NSLog(@"wrotedata to file %@",dataArrayName);
            }
            else
            {
                NSLog(@"data is duplicate, not saved");
            }
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"failed with error = %@",error);
    }];
    [operation start];
}


-(void)LoadData
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(topDidAnchorRight )
//                                                 name:ECSlidingViewTopDidAnchorRight object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(underLeftWillDisappear)
                                                 name:ECSlidingViewUnderLeftWillDisappear object:nil];
    
    [self didRefreshTable:nil];
}

-(void)prepareDataForDisplay
{
    @synchronized(self.loadedGSObjectArray) {
        NSLog(@"running prepareDataForDisplay");
        if(userLocation)
        {
            self.loadedGSObjectArray = [self sortLoadedArray:self.loadedGSObjectArray ByVariable:@"distanceInMeters" ascending:YES];
        }
        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
        [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
    }

   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.tableView.frame = self.view.bounds;
        [self.tableView reloadData];
        if ([[UIDevice currentDevice] systemVersion].floatValue < 6.0)
        {
            int64_t delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underLeftViewController).mapView.region;
                
                    [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:@"" IntoArray:self.GSObjectArray WithRefresh:YES];
                       NSLog(@"loading completed");
                    if(userLocation)
                    {
                        self.GSObjectArray = [self sortLoadedArray:self.GSObjectArray ByVariable:@"distanceInMeters" ascending:YES];
                    }
                    [self.tableView reloadData];
                    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                    [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.loadedGSObjectArray.count] duration:2.0 animated:YES];
                    [self updateOverlay];
                
            });
        }
        else
        {
            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
            [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.loadedGSObjectArray.count] duration:2.0 animated:YES];
            [self updateOverlay];
        }
        
    });


}
-(void)processData:(id)data
{
    if (data==nil)return;
    NSMutableArray* dataArray = [[NSMutableArray alloc]initWithArray:data];
    
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
            gsObject.locationString = [dataObject objectForKey:@"location"];
            gsObject.link = [dataObject objectForKey:@"link"];
            gsObject.itemId = [NSNumber numberWithInt:[[dataObject objectForKey:@"id"] intValue]];
            CGSize s = [gsObject.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
            CGSize x = [gsObject.subTitle sizeWithFont:kSubtitleFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
//            CGSize sourceSize = [gsObject.source sizeWithFont:kSourceFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 10)];//padding btw title and subtitle;
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + MAX(30,s.height))];
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 5)];//padding btw title and subtitle;
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + x.height)];
//            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 5)];//padding btw title and subtitle;
//            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + sourceSize.height)];
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 5)];//padding btw title and subtitle;
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 10)];//padding btw title and subtitle;
            
            gsObject.cellHeight = [NSNumber numberWithInt:(gsObject.cellHeight.intValue + 10)];//padding btw title and subtitle;
            
            gsObject.descriptionhtml = [dataObject objectForKey:@"descriptionHTML"];
            gsObject.source = [dataObject objectForKey:@"source"];
            if ([[dataObject objectForKey:@"source"] isEqualToString:@"LADY IRON CHEF"])
            {
                gsObject.cursorColor = [UIColor blueColor]; //lady iron chef
            }
            else if ([[dataObject objectForKey:@"source"] isEqualToString:@"IEATISHOOTIPOST"])
            {
                gsObject.cursorColor = [UIColor redColor];//ieat
            }
            else if ([[dataObject objectForKey:@"source"] isEqualToString:@"DANIEL FOOD DIARY"])
            {
                gsObject.cursorColor = [UIColor magentaColor];
            }
            else if ([[dataObject objectForKey:@"source"] isEqualToString:@"KEROPOKMAN"])
            {
                gsObject.cursorColor = [UIColor greenColor];
            }
            else if ([[dataObject objectForKey:@"source"] isEqualToString:@"LOVE SG FOOD"])
            {
                    gsObject.cursorColor = [UIColor blackColor];
            }
            else if ([[dataObject objectForKey:@"source"] isEqualToString:@"SGFOODONFOOT"])
            {
                gsObject.cursorColor = [UIColor cyanColor];
            }
            else
            {
                gsObject.cursorColor = [UIColor darkTextColor];
            }            
        }

        if ([[dataObject objectForKey:@"images"] isEqual:[NSNull null]])
        {
            gsObject.imageArray = [NSArray array];
        }
        else
        {
            if (![[dataObject objectForKey:@"images"] isKindOfClass:[NSString class]])
            {
                gsObject.imageArray = [NSArray arrayWithArray:[dataObject objectForKey:@"images"]];
            }
            else
            {
                 gsObject.imageArray = [NSArray array];
            }
            

        }
        
        if ([[dataObject objectForKey:@"foodtype"] isKindOfClass:[NSString class]])
        {
            gsObject.foodTypeArray = [NSArray array];
        }
        else
        {
            gsObject.foodTypeArray = [NSArray arrayWithArray:[dataObject objectForKey:@"foodtype"]];
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
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
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
#warning check this
//                NSLog(@"user loc = %@, %@",userLocation,userLocation.location);
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
-(NSMutableArray*) sortLoadedArray:(NSMutableArray*)loadedArray ByVariable:(NSString*)variable  ascending:(BOOL)ascending
{
    if ([variable isEqualToString:@"distanceInMeters"]) {
        currentScopeType = kScopeTypeDistance;
        if (userLocation ) {
            for (GSObject* gsObj in loadedArray)
            {

                if (!(gsObj.distanceInMeters.doubleValue > 0)) {
                CLLocation *gsLoc = [[CLLocation alloc] initWithLatitude:gsObj.latitude.doubleValue longitude:gsObj.longitude.doubleValue];
                    if (![gsLoc isEqual:[NSNull null]] && ![userLocation.location isEqual:[NSNull null]]) {
                        CLLocationDistance meters = [gsLoc distanceFromLocation:userLocation.location];
                        [gsObj setDistanceInMeters:[NSNumber numberWithDouble:meters]];
                    }else{
                        [gsObj setDistanceInMeters:[NSNumber numberWithDouble:99999]];
                    }
                }
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
   return [NSMutableArray arrayWithArray:[loadedArray sortedArrayUsingDescriptors:descriptors]];

    
}


//calculates scope and updates loaded array into display array , when region is omitted, all data is used.
-(void)recalculateScopeFromLoadedArray:(NSMutableArray*)loadedArray WithRegion:(MKCoordinateRegion)region AndSearch:(NSString*)search IntoArray:(NSMutableArray*)resultArray WithRefresh:(BOOL)refresh
{
    self.random = NO;
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
                     //   [map removeAnnotation:annnote];  // remove any annotations that exist
                    }
                }
            }
        }
//    @synchronized(loadedArray){
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
                //first find out if its a location
                NSArray* searchterms = [search componentsSeparatedByString:@"+"];

                for (NSString* term in searchterms)
                {
                    if ([term rangeOfString:@"addr="].location!=NSNotFound)
                    {
                        if (searchterms.count == 1)
                        {
                            //address is the only one found , as long as entries are within just add them to the gsobjectarray
                            [self updateCrumbsWithGsObject:gsObj IntoResultArray:resultArray withMap:map andRegion:region];
                            continue;
                        }
                    }
                    
                    //find gsobjects which match searches
                    if(([term caseInsensitiveCompare:gsObj.title] == NSOrderedSame || [gsObj.title rangeOfString:term options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound))
                    {
                        [self updateCrumbsWithGsObject:gsObj IntoResultArray:resultArray withMap:map andRegion:region];
                    }
                    else 
                    {
                        if ([gsObj.foodTypeArray containsObject:term]) {
                            [self updateCrumbsWithGsObject:gsObj IntoResultArray:resultArray withMap:map andRegion:region];                            
                        }
                    
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
                                dispatch_async(dispatch_get_main_queue(), ^
                                {
                                        [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbView setNeedsDisplayInMapRect:updateRect];
                                        // move the map alittle
                                        MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
                                        [underMapView setVisibleMapRect:MKMapRectInset([underMapView visibleMapRect], [underMapView visibleMapRect].size.width*0.005, [underMapView visibleMapRect].size.height*0.005) animated:YES];
                                });
                        }
                }

                if([self coordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) ContainedinRegion:region])
                {
                    
                    [resultArray addObject:gsObj];
                }
            
            }
        }
   
}

-(void)updateCrumbsWithGsObject:(GSObject*)gsObj IntoResultArray:(NSMutableArray*)resultArray withMap:(MKMapView*)map andRegion:(MKCoordinateRegion)region
{
    if (![resultArray containsObject:gsObj]) {
        if([self coordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) ContainedinRegion:region])
        {
            [resultArray addObject:gsObj];
        }
        [scopedGSObjectArray addObject:gsObj];
        
        //if crumbs not present, add one
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
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)selectedInstructions:(UIButton*)sender
{
    [sender removeFromSuperview];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        if ([self.slidingViewController.slidingViewController underLeftShowing]) {
            NSLog(@"did shake phone in Menu view controller.. show instructions for Menu here");
            BOOL removedInstructions = NO;
            for (UIView* view in self.slidingViewController.slidingViewController.underLeftViewController.view.subviews) {
                if ([view isKindOfClass:[UIButton class]])
                {
                    if (view.tag == 1) {
                        [view removeFromSuperview];
                        removedInstructions = YES;
                    }
                }
            }
            if (!removedInstructions) {
                UIButton* MenuInstructions = [UIButton buttonWithType:UIButtonTypeCustom];
                [MenuInstructions setTag:1];
                [MenuInstructions setFrame:self.slidingViewController.slidingViewController.underLeftViewController.view.bounds];
                [MenuInstructions setImage:[UIImage imageNamed:@"MenuInstructions.png"] forState:UIControlStateNormal];
                [MenuInstructions addTarget:self action:@selector(selectedInstructions:) forControlEvents:UIControlEventTouchDown];
                [self.slidingViewController.slidingViewController.underLeftViewController.view addSubview:MenuInstructions];
            }
            
        }else{
            if ([self.slidingViewController underRightShowing]) {
                NSLog(@"did shake phone in undermap view controller.. show instructions for undermap here");
                BOOL removedInstructions = NO;
                for (UIView* view in self.slidingViewController.underRightViewController.view.subviews) {
                    if ([view isKindOfClass:[UIButton class]])
                    {
                        if (view.tag == 1) {
                            [view removeFromSuperview];
                            removedInstructions = YES;
                        }
                    }
                }
                if (!removedInstructions) {
                    UIButton* MenuInstructions = [UIButton buttonWithType:UIButtonTypeCustom];
                    [MenuInstructions setTag:1];
                    [MenuInstructions setFrame:self.slidingViewController.underRightViewController.view.bounds];
                    [MenuInstructions setImage:[UIImage imageNamed:@"MapInstructions.png"] forState:UIControlStateNormal];
                    [MenuInstructions addTarget:self action:@selector(selectedInstructions:) forControlEvents:UIControlEventTouchDown];
                    [self.slidingViewController.underRightViewController.view addSubview:MenuInstructions];
                }
            
            }else{
                NSLog(@"did shake phone in geoscroll view controller.. show instructions for geoscroll here");
                BOOL removedInstructions = NO;
                for (UIView* view in self.slidingViewController.topViewController.view.subviews) {
                    if ([view isKindOfClass:[UIButton class]])
                    {
                        if (view.tag == 1) {
                            [view removeFromSuperview];
                            removedInstructions = YES;
                        }
                    }
                }
                if (!removedInstructions) {
                    UIButton* MenuInstructions = [UIButton buttonWithType:UIButtonTypeCustom];
                    [MenuInstructions setTag:1];
                    [MenuInstructions setFrame:self.slidingViewController.topViewController.view.bounds];
                    [MenuInstructions setImage:[UIImage imageNamed:@"GeoscrollInstructions.png"] forState:UIControlStateNormal];
                    [MenuInstructions addTarget:self action:@selector(selectedInstructions:) forControlEvents:UIControlEventTouchDown];
                    [self.slidingViewController.topViewController.view addSubview:MenuInstructions];
                }
            }
        }
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

-(void)topDidAnchorRight{
    NSLog(@"topDidAnchorRight");
}
-(void)topDidAnchorLeft
{

    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    for (id annnote in underMapView.annotations) {
        if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
            //NOOP
        }else{

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

    NSLog(@"underLeftWillDisAppear");
    if (self.selectionChanged) {
        self.selectionChanged=NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading"];    
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self didRefreshTable:nil];
        });
        
    }
    for (UIView* view in self.slidingViewController.underRightViewController.view.subviews) {
        if ([view isKindOfClass:[UIButton class]])
        {
            if (view.tag == 1) {
                [view removeFromSuperview];
            }
        }
    }

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
        

        
        
        //here we recalculate using span and find out which data sets sit in the map enclosed.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
            [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                for (id annnote in underMapView.annotations) {
                    NSLog(@"annotate = %@, %@",NSStringFromClass([annnote class]),((GSObject*)annnote).title);
                    if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
                        //NOOP
                    }else{
                        //[underMapView deselectAnnotation:annnote animated:YES];
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
                    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                    [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                    [self updateOverlay];
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
    if (self.random) {
        idx = self.randomIndex;
    }
    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    for (id annnote in underMapView.annotations) {
        if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
            //NOOP
        }else{
            [underMapView removeAnnotation:annnote];  // remove any annotations that exist
        }
    }
    [underMapView addAnnotation:[self.GSObjectArray objectAtIndex:idx]];
    [((UnderMapViewController*)self.slidingViewController.underRightViewController) willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
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

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollViewDidEndDecelerating:scrollView];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //TODO: animate pin here!
    MKMapView* underMapView = ((MKMapView*)((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView);
    for (id annote in underMapView.annotations) {
        if ([annote isKindOfClass:[GSObject class]]) { //should only have one
            MKAnnotationView*annView = [underMapView viewForAnnotation:annote];
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CATransform3D zRotation;
                zRotation = CATransform3DMakeRotation(M_PI/10, 0, 0, 1.0);
                annView.layer.transform = zRotation;
                
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    CATransform3D zRotation;
                    zRotation = CATransform3DMakeRotation(-M_PI/10, 0, 0, 1.0);
                    annView.layer.transform = zRotation;
                    
                }completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        CATransform3D zRotation;
                        zRotation = CATransform3DMakeRotation(M_PI/12, 0, 0, 1.0);
                        annView.layer.transform = zRotation;
                        
                    }completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            CATransform3D zRotation;
                            zRotation = CATransform3DMakeRotation(-M_PI/12, 0, 0, 1.0);
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
            
        }
    }
    
}



#pragma mark - Search Bar Delegates



-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
        self.random = NO;
        SearchViewController * searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Search"];
        searchViewController.delegate = self;
        searchViewController.dataArray = self.loadedGSObjectArray;
        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
        searchViewController.searchRegion = region;
        [searchViewController.underMapView setRegion:region animated:NO];
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        self.tableView.hidden = YES;
        [self presentModalViewController:searchViewController animated:YES];
        return NO;

}
-(void)searchViewControllerDidFinishWithSearchString:(NSString *)searchString
{
    NSLog(@"searchString = %@",searchString);
    self.tableView.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topDidAnchorLeft ) name:ECSlidingViewTopDidAnchorLeft object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underRightWillDisappear) name:ECSlidingViewUnderRightWillDisappear object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underLeftWillAppear) name:ECSlidingViewUnderLeftWillAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underLeftWillDisappear) name:ECSlidingViewUnderLeftWillDisappear object:nil];
    ((SorterCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).searchTextField.text = searchString;
    [self textFieldShouldReturn:((SorterCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).searchTextField];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [scopedGSObjectArray removeAllObjects];
    if (textField.text.length > 0) {
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        overlay.progress = 1.0;
        [overlay postMessage:[NSString stringWithFormat:@"Current Search: %@",textField.text] animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            currentSearch = textField.text;
            
            if (currentSearch.length>0) {
                NSArray* searchterms = [currentSearch componentsSeparatedByString:@"+"];
                
                for (NSString* term in searchterms) {
                    NSLog(@"term - %@",term);
                    if ([term rangeOfString:@"addr="].location!=NSNotFound) {
                        //reverse geocode
                        if (!self.geocoder) {
                            self.geocoder = [[CLGeocoder alloc] init];
                        }
                        NSString* searchaddress;
                        searchaddress = [[term stringByReplacingOccurrencesOfString:@"addr=" withString:@""] stringByAppendingString:@" Singapore"];
                        NSLog(@"found addr %@",searchaddress);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            textField.text = @"";
                            currentSearch = @"";
                            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                            overlay.animation = MTStatusBarOverlayAnimationFallDown;
                            
                            [overlay postImmediateFinishMessage:@"Cleared" duration:1.0 animated:YES];
                            
                        });
                        [self.geocoder geocodeAddressString:searchaddress completionHandler:^(NSArray *placemarks, NSError *error) {
                            NSLog(@"geocoder returned");
                            if ([placemarks count] > 0) {
                                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                NSLog(@"found geocode at %@",placemark);

                                //remember and apply at end
                                self.shouldZoomToLocation = [[CLLocation alloc]initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
                                [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:MKCoordinateRegionMake(self.shouldZoomToLocation.coordinate, MKCoordinateSpanMake(0.005, 0.005)) AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];

                                dispatch_async(dispatch_get_main_queue(), ^{

                                    [((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView setRegion:MKCoordinateRegionMake(self.shouldZoomToLocation.coordinate, MKCoordinateSpanMake(0.005, 0.005)) animated:YES];
                                    
                                    [self.tableView reloadData];
                                    
                                    
                                    if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
                                    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                                    [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                                    [self updateOverlay];
                                    
                                });

                                
                            }else{
                                NSLog(@"couldnt find location");
                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Sorry!" message:[NSString stringWithFormat:@"We couldn't find %@",searchaddress] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];

                            }
                        }];
                    }else{
                        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
                        [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.scopedGSObjectArray.count == 1) {
                                MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
                                for (GSObject* gsObj in scopedGSObjectArray) {
                                    [underMapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue), MKCoordinateSpanMake(0.005, 0.005)) animated:YES];
                                }
                                [self.GSObjectArray removeAllObjects];
                                [self.GSObjectArray addObjectsFromArray:self.scopedGSObjectArray];
                            }
                            [self.tableView reloadData];
                            if (self.scopedGSObjectArray.count > 1) {
                            MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
                            [underMapView setVisibleMapRect:MKMapRectInset([underMapView visibleMapRect], [underMapView visibleMapRect].size.width*0.005, [underMapView visibleMapRect].size.height*0.005) animated:YES];
                            }
                            
                            if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
                            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                            [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                            [self updateOverlay];
                            
                        });
                    }
                }
            }
            
        });

    }else{
        currentSearch = @"";
        textField.text = @"";

        [textField resignFirstResponder];
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        overlay.animation = MTStatusBarOverlayAnimationFallDown;
        
        [overlay postImmediateFinishMessage:@"Cleared" duration:1.0 animated:YES];
        
        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
        [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:@"" IntoArray:self.GSObjectArray WithRefresh:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
            
            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
            [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
            [self updateOverlay];
        });

    }
    return YES;
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
-(void)calculateRandom
{
    self.random = !self.random;
    self.randomIndex = rand() % self.GSObjectArray.count;
    [self.tableView reloadData];
    if (self.random) {
        [self scrollViewDidEndDecelerating:self.tableView];
    }
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

-(void)showMap
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}

-(void)showMenu
{
    [self.slidingViewController.slidingViewController anchorTopViewTo:ECRight];
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
        //cell.searchBar.selectedScopeButtonIndex = currentScopeType;
//        UIButton* MenuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        MenuButton.frame = CGRectMake(0,0, 44, 44);
//        [MenuButton setTitle:@"Menu" forState:UIControlStateNormal];
//        [MenuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
//        UIButton* MapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        MapButton.frame = CGRectMake(cell.bounds.size.width-44,0, 44, 44);
//        [MapButton addTarget:self action:@selector(showMap)  forControlEvents:UIControlEventTouchUpInside];
//
        if (self.GSObjectArray.count > 2) {
            [cell.randomButton addTarget:self action:@selector(calculateRandom) forControlEvents:UIControlEventTouchUpInside];
            cell.randomContainer.hidden = NO;
        }else{
            cell.randomContainer.hidden = YES;

        }
        
//        [cell.navView addSubview:MenuButton];
//        [cell.navView addSubview:MapButton];
        cell.searchTextField.text = currentSearch;
        cell.searchTextField.delegate = self;
        cell.sorterBackgroundView.layer.cornerRadius = 0;
        
        
        
        return cell;
    
    }
    if((self.random && indexPath.row==2) ||(!self.random && indexPath.row == [GSObjectArray count]+1)){
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
        endcell.endTableBackgroundView.layer.cornerRadius = 0;
        if([SVProgressHUD isVisible])
        {
            endcell.endTableBackgroundView.hidden = YES;
        }else{
            if (self.GSObjectArray.count==0) {
                endcell.endTableBackgroundView.hidden = NO;
            }else{
                endcell.endTableBackgroundView.hidden = YES;
            }
        }
        return endcell;
    }
    GSObject* gsObj;
    if (self.random) {
        gsObj = [self.GSObjectArray objectAtIndex:self.randomIndex];
    }else{
        gsObj = [self.GSObjectArray objectAtIndex:indexPath.row-1];
    }
    CGSize s = [gsObj.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize subTitleSize = [gsObj.subTitle sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
    NSString *FromCellIdentifier = [NSString stringWithFormat:@"%@,%d,%d",gsObj.source,(int)s.height,(int)subTitleSize.height];
    
    RotatingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier];

    if (cell == nil)
    {
        CGSize s = [gsObj.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize subTitleSize = [gsObj.subTitle sizeWithFont:kSubtitleFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize sourceSize = [gsObj.source sizeWithFont:kSourceFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        cell = [[RotatingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FromCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.mainCellView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, cell.bounds.size.width-2*kCellPaddingLeft, gsObj.cellHeight.intValue-kCellPaddingTop*2)];
        
        cell.colorBarView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, kCellColorBarWidth, gsObj.cellHeight.intValue-kCellPaddingTop*2)];
//        [cell.colorBarView setBackgroundColor:[UIColor magentaColor]];
        [cell.colorBarView setBackgroundColor:gsObj.cursorColor];
        
        cell.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kStarLeftPadding,10,kCellHeightConstraint,s.height)];
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.titleLabel.textColor = [UIColor whiteColor];
        [cell.titleLabel setFont:kMainFont];
        [cell.titleLabel setNumberOfLines:0];
        cell.titleLabel.shadowColor = [UIColor blackColor];
        cell.titleLabel.shadowOffset = CGSizeMake(1, 1);
        
        
        
        cell.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kStarLeftPadding,10 + s.height + 5 ,kCellSubtitleHeightConstraint,subTitleSize.height)];
        cell.subTitleLabel.backgroundColor = [UIColor clearColor];
        cell.subTitleLabel.textColor = [UIColor whiteColor];
        [cell.subTitleLabel setFont:kSubtitleFont];
        [cell.subTitleLabel setNumberOfLines:0];
        cell.subTitleLabel.shadowColor = [UIColor blackColor];
        cell.subTitleLabel.shadowOffset = CGSizeMake(1, 1);
        
//        cell.sourceLabel = [[UILabel alloc]initWithFrame:CGRectMake(kStarLeftPadding,10 + s.height + 5 + subTitleSize.height + 5 ,kCellSubtitleHeightConstraint,sourceSize.height)];
//        cell.sourceLabel.backgroundColor = [UIColor clearColor];
//        cell.sourceLabel.textColor = [UIColor whiteColor];
//        [cell.sourceLabel setFont:kSourceFont];
//        [cell.sourceLabel setNumberOfLines:0];
//        cell.sourceLabel.shadowColor = [UIColor blackColor];
//        cell.sourceLabel.shadowOffset = CGSizeMake(1, 1);

        cell.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.bounds.size.width-10-5-40,gsObj.cellHeight.intValue-5-30 ,40,30)];
        cell.distanceLabel.backgroundColor = [UIColor clearColor];
        cell.distanceLabel.textColor = [UIColor whiteColor];
        [cell.distanceLabel setFont:kDistanceFont];
        [cell.distanceLabel setTextAlignment:NSTextAlignmentRight];
        [cell.distanceLabel setNumberOfLines:0];
        cell.distanceLabel.shadowColor = [UIColor blackColor];
        cell.distanceLabel.shadowOffset = CGSizeMake(1, 1);
        
        
        
        cell.distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(cell.distanceLabel.frame.origin.x - 10 ,cell.distanceLabel.frame.origin.y  ,10,cell.distanceLabel.frame.size.height)];
        [cell.distanceIcon setImage:[UIImage imageNamed:@"distanceWhite.png"]];
        [cell.distanceIcon setContentMode:UIViewContentModeScaleAspectFit];
        

        [cell.contentView addSubview:cell.mainCellView];
        [cell.contentView addSubview:cell.colorBarView];
        [cell.contentView addSubview:cell.starview];
        [cell.contentView addSubview:cell.titleLabel];
        [cell.contentView addSubview:cell.subTitleLabel];
        [cell.contentView addSubview:cell.sourceLabel];
        [cell.contentView addSubview:cell.distanceIcon];
        [cell.contentView addSubview:cell.distanceLabel];
        
    }
   
    cell.mainCellView.alpha = 0.3;
    cell.mainCellView.backgroundColor = [UIColor blackColor];
    cell.titleLabel.text = gsObj.title;
    cell.subTitleLabel.text = [[gsObj.subTitle stringByReplacingOccurrencesOfString:@": " withString:@""]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.sourceLabel.text = [NSString stringWithFormat:@"source: %@",gsObj.source];
    CLLocation *gsLoc = [[CLLocation alloc] initWithLatitude:gsObj.latitude.doubleValue longitude:gsObj.longitude.doubleValue];
    CLLocationDistance meters = [gsLoc distanceFromLocation:userLocation.location];
    [gsObj setDistanceInMeters:[NSNumber numberWithDouble:meters]];
    if (gsObj.distanceInMeters.intValue<1000) {
     cell.distanceLabel.text = [NSString stringWithFormat:@"%d m",gsObj.distanceInMeters.intValue];
    }else if (gsObj.distanceInMeters.intValue>1000) {
     cell.distanceLabel.text = [NSString stringWithFormat:@"%.01f km",gsObj.distanceInMeters.floatValue/1000.0f];
    }else if (gsObj.distanceInMeters.intValue>100000) {
        cell.distanceLabel.text = [NSString stringWithFormat:@""];
    }
    
    
    cell.mainCellView.layer.cornerRadius = 0;
    
//    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, 2, 12, (gsObj.cellHeight.intValue - 10)) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(kCellCornerRad, kCellCornerRad)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = cell.colorBarView.layer.bounds;
//    maskLayer.path = maskPath.CGPath;
//    cell.colorBarView.layer.mask = maskLayer;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == [self.GSObjectArray count]+1)
    {
        return;
    }
    GSObject* selectedGSObj;
    if (self.random) {
        selectedGSObj   = [self.GSObjectArray objectAtIndex:self.randomIndex];
    }else{
      selectedGSObj   = [self.GSObjectArray objectAtIndex:indexPath.row-1];
    }

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",selectedGSObj.link]];
	SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
    webViewController.gsobj = selectedGSObj;
    webViewController.currentLocation = self.userLocation;
	[self.navigationController pushViewController:webViewController animated:YES];
    
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

-(void)updateOverlay
{
    if (currentSearch.length > 0)
    {
        int64_t delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
            overlay.progress = 1.0;
            [overlay postMessage:[NSString stringWithFormat:@"Current Search: %@",currentSearch] animated:YES];
        });
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {

        [self.slidingViewController setAnchorLeftPeekAmount:160.0f];
    }
    else
    {
        [self.slidingViewController setAnchorLeftPeekAmount:50.0f];
    }
}

@end