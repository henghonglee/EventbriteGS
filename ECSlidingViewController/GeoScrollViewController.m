#import "LoadingViewController.h"
#import "ImageCell.h"
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
#import "Flurry.h"
#import "AppDelegate.h"
#import "FoodItem.h"
#import "FoodImage.h"
#import "FoodPlace.h"
#import "FoodType.h"
#import "FoodDescription.h"
#define kMainFont [UIFont systemFontOfSize:27.0]
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
    
    //    self.queryArray = NSArray arrayWithObjects:@"try 'Bak Chor Mee'",@"try 'Ramen'",@"try 'East Coast Road'", nil
    self.alphaValue = 0.3f;
    self.ongoingRequests =[[NSMutableArray alloc] init];
    self.boolhash = [[NSMutableDictionary alloc] init];
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
    self.tableView.scrollsToTop = YES;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.alpha=0;
    [self.tableView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    [self.view addSubview:self.tableView];
    
    GSserialQueue = dispatch_queue_create("com.example.GSSerialQueue", NULL);
    GSdataSerialQueue = dispatch_queue_create("com.example.GSDataSerialQueue", NULL);
    
    
    //    dispatch_async(dispatch_get_main_queue(), ^
    //   {
    //       LoadingViewController* loadingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoadingView"];
    //       [self.navigationController.topViewController presentViewController:loadingViewController animated:YES completion:^{
    //
    //       }];
    //   });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self LoadData];
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
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"RightReveal"]==nil) {
        [self hintRight];
    }else if ([[NSUserDefaults standardUserDefaults]objectForKey:@"LeftReveal"]==nil) {
        [self hintLeft];
    }
    
    
}



-(void)didRefreshTable:(id)sender
{
    //NSArray* menuItems = [NSArray arrayWithObjects:@"LADY IRON CHEF", nil];
    NSArray* menuItems = [NSArray arrayWithObjects:@"IEATISHOOTIPOST",@"LADY IRON CHEF",@"LOVE SG FOOD",@"SGFOODONFOOT",@"DANIEL FOOD DIARY", nil];
    NSMutableArray* delarray = [[NSMutableArray alloc]init];
    NSMutableArray* involvedBlogs = [[NSMutableArray alloc]init];
    [involvedBlogs removeAllObjects];
    for (NSString* blog in menuItems)
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:blog] isEqualToString:@"Enabled"])
        {
            
            if (![[self.boolhash objectForKey:blog] isEqualToString:@"Enabled"])
            {
                
                dispatch_async(GSdataSerialQueue, ^{
                    [self retrieveAndProcessDataFromCacheOrServerForBlog:blog];
                });
                [involvedBlogs addObject:blog];
                [self.boolhash setObject:@"Enabled" forKey:blog];
                
                
            }else{
                //                NSLog(@"already enabled");
            }
        }
        else
        {
            if ([[self.boolhash objectForKey:blog] isEqualToString:@"Enabled"])
            {
                
                for (FoodItem* gsobj in self.loadedGSObjectArray)
                {
                    if ([gsobj.source isEqualToString:blog])
                    {
                        [delarray addObject:gsobj];
                    }
                }
                
                [self.boolhash setObject:@"Disabled" forKey:blog];
                
                for (FoodItem* delgs in delarray)
                {
                    [self.loadedGSObjectArray removeObject:delgs];
                }
                
            }
        }
    }
    NSLog(@"ADDING to serial queue");
    dispatch_async(GSserialQueue, ^{
        [self processDataWithCoreDataForSources:involvedBlogs withCompletionBlock:nil];
    });
    NSLog(@"ADDING to serial queue");
    dispatch_async(GSserialQueue, ^{
        
        [self prepareDataForDisplay];
        
        
        self.canSearch = YES;
        dispatch_async(dispatch_get_main_queue(), ^
       {
           NSLog(@"dismissing progress hud");
           [SVProgressHUD dismiss];
       });
        
    });
    
}

-(void)retrieveAndProcessDataFromCacheOrServerForBlog:(NSString*)blog //withCompletion:(void)(^))
{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];

    NSString *stringFromDate;
    if([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lastupdated%@",blog]] != NULL)
    {
        stringFromDate = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"lastupdated%@",blog]];
    }else{
    //   stringFromDate = [format stringFromDate:[NSDate date]];
        stringFromDate = @"2013-03-30T11:43:00Z";
    }
    
    NSString* dateEscaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                  NULL,
                                                                                                  (__bridge CFStringRef) stringFromDate,
                                                                                                  NULL,
                                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                  kCFStringEncodingUTF8));
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tastebudsapp.herokuapp.com/%@/%@.json",[blog stringByReplacingOccurrencesOfString:@" " withString:@"%20"],dateEscaped]];
    
    if ([self.ongoingRequests containsObject:blog]) {
        NSLog(@"skipping");
    }else{
        [self.ongoingRequests addObject:blog];
        NSLog(@"added %@ to the list of ongoing = %@",blog,self.ongoingRequests);
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0f];
        
        NSLog(@"url = %@",url);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
         {
             
             NSLog(@"recieved response json");
             dispatch_async(GSdataSerialQueue, ^
                            {
                                NSError *error;
                                //            NSManagedObjectContext *context = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
                                NSManagedObjectContext* context = [self dataManagedObjectContext];
                                
                                //    NSLog(@"processing data = %@",JSON);
                                
                                NSMutableArray* jsonArray = [[NSMutableArray alloc]initWithArray:JSON];
                                
                                for (NSDictionary* item in jsonArray) {

                                        FoodItem *fooditem = nil;
                                        NSFetchRequest *request = [[NSFetchRequest alloc] init];
                                        request.includesPropertyValues = NO;
                                        request.entity = [NSEntityDescription entityForName:@"FoodItem" inManagedObjectContext:context];
                                        request.predicate = [NSPredicate predicateWithFormat:@"item_id = %d", [[item objectForKey:@"id"] intValue]];
                                        
                                        NSError *executeFetchError = nil;
                                        fooditem = [[context executeFetchRequest:request error:&executeFetchError] lastObject];
                                        if (executeFetchError) {
                                            
                                        } else if (!fooditem) {
                                            fooditem = [NSEntityDescription insertNewObjectForEntityForName:@"FoodItem"
                                                                                     inManagedObjectContext:context];
                                        }

                                        NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                        [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                                        NSDate *createdDate = [format dateFromString:[item objectForKey:@"created_at"]];
                                        
                                        NSDate *updatedDate = [format dateFromString:[item objectForKey:@"updated_at"]];
                                        NSDate* lastUpdated = [fooditem valueForKey:@"updated_at"];
                                        
                                        if (([updatedDate compare:lastUpdated] == NSOrderedAscending)||[updatedDate isEqualToDate:lastUpdated])  {
                                            continue;
                                        }
                                        [fooditem setValue:updatedDate forKey:@"updated_at"];
                                        [fooditem setValue:createdDate forKey:@"created_at"];
                                        [fooditem setValue:[item objectForKey:@"title"] forKey:@"title"];
                                        if ([[item objectForKey:@"subtitle"] isEqual:[NSNull null]])
                                        {
                                            [fooditem setValue:@"" forKey:@"sub_title"];
                                        }else{
                                            [fooditem setValue:[item objectForKey:@"subtitle"] forKey:@"sub_title"];
                                        }
                                       

                                        CGSize s = [fooditem.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
                                        CGSize x = [fooditem.sub_title sizeWithFont:kSubtitleFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
    
                                        fooditem.cell_height = [NSNumber numberWithInt:(fooditem.cell_height.intValue + 10)];//padding btw title and subtitle;
                                        fooditem.cell_height = [NSNumber numberWithInt:(fooditem.cell_height.intValue + MAX(30,s.height))];
                                        fooditem.cell_height = [NSNumber numberWithInt:(fooditem.cell_height.intValue + 5)];//padding btw title and subtitle;
                                        fooditem.cell_height = [NSNumber numberWithInt:(fooditem.cell_height.intValue + x.height)];
                                        fooditem.cell_height = [NSNumber numberWithInt:(fooditem.cell_height.intValue + 5)];//padding btw title and subtitle;
                                        fooditem.cell_height = [NSNumber numberWithInt:(fooditem.cell_height.intValue + 10)];//padding btw title and subtitle;
                                        
                                        [fooditem setValue:[NSNumber numberWithInt:(fooditem.cell_height.intValue + 10)]forKey:@"cell_height"];//padding btw title and subtitle;
                                        //gsObject.descriptionhtml = [foodItem valueForKey:@"descriptionHTML"];
                                        
                                        
                                        [fooditem setValue:[NSNumber numberWithBool:[[item objectForKey:@"is_post"] boolValue]] forKey:@"is_post"];
                                        [fooditem setValue:[item objectForKey:@"source"] forKey:@"source"];
                                        [fooditem setValue:[item objectForKey:@"id"] forKey:@"item_id"];
                                        [fooditem setValue:[item objectForKey:@"location"] forKey:@"location_string"];
                                        [fooditem setValue:[item objectForKey:@"link"] forKey:@"link"];
                                        
                                        if (![[item objectForKey:@"foursqure_venue"] isEqual:[NSNull null]])
                                        {
                                            [fooditem setValue:[item objectForKey:@"foursqure_venue"] forKey:@"foursquare_venue"];
                                        }
                                        if (![[item objectForKey:@"place_id"] isEqual:[NSNull null]])
                                        {
                                            FoodPlace *foodplace = nil;
                                            NSFetchRequest *request = [[NSFetchRequest alloc] init];
                                            request.includesPropertyValues = NO;
                                            request.entity = [NSEntityDescription entityForName:@"FoodPlace" inManagedObjectContext:context];
                                            request.predicate = [NSPredicate predicateWithFormat:@"item_id = %d", [[item objectForKey:@"place_id"] intValue]];
                                            NSError *executeFetchError = nil;
                                            foodplace = [[context executeFetchRequest:request error:&executeFetchError] lastObject];
                                            
                                            if (executeFetchError) {
                                                NSLog(@"fetch error");
                                            } else if (!foodplace) {
                                                
                                                //if no foodplace found create one
                                                NSLog(@"creating new food place");
                                                foodplace = [NSEntityDescription insertNewObjectForEntityForName:@"FoodPlace"
                                                                                         inManagedObjectContext:context];
                                                foodplace.item_id = [NSNumber numberWithInt:[[item objectForKey:@"place_id"] intValue]];
                                                fooditem.place = foodplace;
                                                if (![[item objectForKey:@"foursqure_venue"] isEqual:[NSNull null]])
                                                {
                                                    [foodplace setValue:[item objectForKey:@"foursqure_venue"] forKey:@"foursquare_venue"];
                                                }else{
                                                    [foodplace setValue:@"unknown" forKey:@"foursquare_venue"];
                                                }
                                                //get most recent
                                                [foodplace setValue:[item objectForKey:@"title"] forKey:@"title"];
                                                
                                                
                                                
                                            }else if(foodplace){
                                                //found a foodplace with the correct id, add fooditem to foodplace and foodplace to fooditem
                                                 NSLog(@"found food place.. adding item to it");
                                                [foodplace addItemsObject:fooditem];
                                                fooditem.place = foodplace;
                                            }else{
                                                NSLog(@"unknown error");
                                            }

                                            
                                        }
                                        double lat = [[item objectForKey:@"latitude"] doubleValue];
                                        double lon = [[item objectForKey:@"longitude"] doubleValue];
                                        [fooditem setValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
                                        [fooditem setValue:[NSNumber numberWithDouble:lon] forKey:@"longitude"];
                                        
                                        if ([[item objectForKey:@"foodtype"] isKindOfClass:[NSArray class]]) {
                                            
                                            NSArray* foodtypeArray = [item objectForKey:@"foodtype"];
                                            if (foodtypeArray.count>0) {
                                                [fooditem removeFoodtypes:fooditem.foodtypes];
                                                for (NSString* foodstring in foodtypeArray) {
                                                    FoodType *foodtype = [NSEntityDescription
                                                                          insertNewObjectForEntityForName:@"FoodType"
                                                                          inManagedObjectContext:context];
                                                    [foodtype setValue:foodstring forKey:@"type"];
                                                    [fooditem addFoodtypesObject:foodtype];
                                                }
                                            }
                                        }
                                        if ([[item objectForKey:@"images"] isKindOfClass:[NSArray class]]) {
                                            
                                            NSArray* high_res_images_array = [item objectForKey:@"images"];
                                            NSArray* low_res_images_array = [item objectForKey:@"low_res_images"];
                                            if (high_res_images_array.count>0) {
                                                [fooditem removeImages:fooditem.images];
                                                for (int i=0;i<high_res_images_array.count;i++)
                                                {
                                                    FoodImage* image = [NSEntityDescription
                                                                        insertNewObjectForEntityForName:@"FoodImage"
                                                                        inManagedObjectContext:context];
                                                    [image setValue:[high_res_images_array objectAtIndex:i] forKey:@"high_res_image"];
                                                    [image setValue:[low_res_images_array objectAtIndex:i] forKey:@"low_res_image"];
                                                    [fooditem addImagesObject:image];
                                                    
                                                }
                                            }
                                            
                                        }
                                        
                                        FoodDescription *fooddescription = [NSEntityDescription
                                                                            insertNewObjectForEntityForName:@"FoodDescription"
                                                                            inManagedObjectContext:context];
                                        [fooddescription setValue:[item objectForKey:@"descriptionHTML"] forKey:@"descriptionHTML"];
                                        [fooditem setValue:fooddescription forKey:@"descriptionHTML"];
                                        
                                        
                                    if (![context save:&error]) {
                                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                                    }else{
                                        NSLog(@"saved");
                                    }
                                    
                                }
                                
                                
                                
                                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                                [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                                NSString *currentDateString = [format stringFromDate:[NSDate date]];
                                [[NSUserDefaults standardUserDefaults] setObject:currentDateString forKey:[NSString stringWithFormat:@"lastupdated%@",blog]];
                                [[NSUserDefaults standardUserDefaults]synchronize];
                                
                                NSLog(@"done with blog = %@",blog);
                                
                                [self.ongoingRequests removeObject:blog];
                                
                            });
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
         {
             NSLog(@"failed with error = %@",error);
             [self.ongoingRequests removeObject:blog];
         }];
        [operation start];
    }
    

    
}

-(void)LoadData
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(underLeftWillDisappear)
                                                 name:ECSlidingViewUnderLeftWillDisappear object:nil];
    
    [self didRefreshTable:nil];
    
}

-(void)prepareDataForDisplay
{
    NSLog(@"running prepareDataForDisplay");
    self.loadedGSObjectArray = [self sortLoadedArray:self.loadedGSObjectArray ByVariable:@"distanceInMeters" ascending:YES];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
        [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
            [self slowReload];
            if ([[UIDevice currentDevice] systemVersion].floatValue < 6.0)
            {
                int64_t delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underLeftViewController).mapView.region;
                    [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:@"" IntoArray:self.GSObjectArray WithRefresh:YES];
                    NSLog(@"loading completed");
                    if(userLocation)
                        self.GSObjectArray = [self sortLoadedArray:self.GSObjectArray ByVariable:@"distanceInMeters" ascending:NO];
                    
                    [self.tableView reloadData];
                    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                    [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.loadedGSObjectArray.count] duration:2.0 animated:YES];
                    [self updateOverlay];
                    
                });
            }
            else
            {
                //            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                //            [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.loadedGSObjectArray.count] duration:2.0 animated:YES];
                //            [self updateOverlay];
            }
            
        });
    });
    
    
    
    
    
}

-(void)processDataWithCoreDataForSources:(NSMutableArray*)source withCompletionBlock:(void (^)(BOOL finished))completionBlock
{
    
    NSError *error;
    NSManagedObjectContext *context = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.includesPropertyValues = NO;
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"FoodItem" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    
    switch (source.count) {
        case 0:
            return;
            break;
        case 1:
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(source == %@) AND is_post == TRUE",[source objectAtIndex:0],[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]]]];
            break;
        case 2:
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(source == %@ OR source == %@) AND is_post == TRUE",[source objectAtIndex:0],[source objectAtIndex:1],[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]]]];
            break;
        case 3:
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(source == %@ OR source == %@ OR source == %@) AND is_post == TRUE",[source objectAtIndex:0],[source objectAtIndex:1],[source objectAtIndex:2],[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]]]];
            break;
        case 4:
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(source == %@ OR source == %@ OR source == %@ OR source == %@) AND is_post LIKE[c] %@",[source objectAtIndex:0],[source objectAtIndex:1],[source objectAtIndex:2],[source objectAtIndex:3],[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]]]];
            break;
        case 5:
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(source == %@ OR source == %@ OR source == %@ OR source == %@ OR source == %@) AND is_post LIKE[c] %@",[source objectAtIndex:0],[source objectAtIndex:1],[source objectAtIndex:2],[source objectAtIndex:3],[source objectAtIndex:4],[NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]]]];
            break;
        default:
            break;
    }
    
    
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (FoodItem* item in fetchedObjects) {
        if ([item.is_post isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            NSLog(@"found a false");
        }
    
    }
    
        NSLog(@"fetched = %d objects ",fetchedObjects.count);
        [self.loadedGSObjectArray addObjectsFromArray:fetchedObjects];
        
    if (completionBlock) {
        completionBlock(YES);
    }
    
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
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft||orientation == UIInterfaceOrientationLandscapeRight) {
        self.imageTableView.hidden = NO;
    }else{
        self.imageTableView.hidden = YES;
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

#pragma mark custom methods

//sorts both loaded and display arrays by gsobject variable
-(NSMutableArray*) sortLoadedArray:(NSMutableArray*)loadedArray ByVariable:(NSString*)variable  ascending:(BOOL)ascending
{
    //notsorting
    
    
    
     NSLog(@"sorting by %@",variable);
     if ([variable isEqualToString:@"distanceInMeters"]) {
     currentScopeType = kScopeTypeDistance;
     }else if([variable isEqualToString:@"likes"]){
     currentScopeType = kScopeTypeLikes;
     }else if([variable isEqualToString:@"dealCount"]){
     currentScopeType = kScopeTypeDeals;
     }
    
     NSSortDescriptor * frequencyDescriptor =
     [[NSSortDescriptor alloc] initWithKey:@"distance_in_meters"
     ascending:ascending] ;
     NSArray * descriptors = [NSArray arrayWithObjects:frequencyDescriptor, nil];
     NSArray * sortedArray = [loadedArray sortedArrayUsingDescriptors:descriptors];
     [loadedArray removeAllObjects];
     [loadedArray addObjectsFromArray:sortedArray];
     
    return loadedArray;
}


//calculates scope and updates loaded array into display array , when region is omitted, all data is used.
-(void)recalculateScopeFromLoadedArray:(NSMutableArray*)loadedArray WithRegion:(MKCoordinateRegion)region AndSearch:(NSString*)search IntoArray:(NSMutableArray*)resultArray WithRefresh:(BOOL)refresh
{
    NSLog(@"calling recalculate");
    __block MKMapRect updateRect;
    //    self.canSearch = NO;
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
    
    if (search.length > 0)
    {
        //first find out if its a location
        NSArray* searchterms = [search componentsSeparatedByString:@"+"];
        
        for (NSString* term in searchterms)
        {
            if ([term rangeOfString:@"addr="].location==NSNotFound)
            {
                NSError *error;
                NSManagedObjectContext *context = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                fetchRequest.includesPropertyValues = NO;
                NSEntityDescription *entity = [NSEntityDescription
                                               entityForName:@"FoodItem" inManagedObjectContext:context];
                [fetchRequest setEntity:entity];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title contains %@ OR ANY foodtypes.type = %@", term, term]];
                NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
                NSLog(@"fetched %d",fetchedObjects.count);
                for (FoodItem* item in fetchedObjects) {
                    updateRect = [self updateCrumbsWithFoodItem:item IntoResultArray:resultArray withMap:map andRegion:region andUpdateRect:updateRect];
                }
            }
        }
    }
    for (FoodItem* gsObj in loadedArray)
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
                    updateRect = [self updateCrumbsWithFoodItem:gsObj IntoResultArray:resultArray withMap:map andRegion:region andUpdateRect:updateRect];
                        continue;
                    }
                }
                
//                //find gsobjects which match searches
//                if(([term caseInsensitiveCompare:gsObj.title] == NSOrderedSame || [gsObj.title rangeOfString:term options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound))
//                {
//                    updateRect = [self updateCrumbsWithFoodItem:gsObj IntoResultArray:resultArray withMap:map andRegion:region andUpdateRect:updateRect];
//                    
//                }
//                else
//                {
//                    
//
//
//                }
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
                    
                }
                if (map.overlays.count == 0) {
                    NSLog(@"adding overlay");
                    [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];    
                    NSLog(@"done adding overlay count = %d",map.overlays.count);
                    
                }
                
                //updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:gsObj.cursorColor];
                if ([gsObj.source isEqualToString:@"LADY IRON CHEF"])
                {
                    updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor blueColor]]; //lady iron chef
                }
                else if ([gsObj.source isEqualToString:@"IEATISHOOTIPOST"])
                {
                    updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor redColor]];
                }
                else if ([gsObj.source isEqualToString:@"DANIEL FOOD DIARY"])
                {
                    updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor magentaColor]];
                }
                else if ([gsObj.source isEqualToString:@"KEROPOKMAN"])
                {
                    updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor greenColor]];
                }
                else if ([gsObj.source isEqualToString:@"LOVE SG FOOD"])
                {
                    updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor blackColor]];
                }
                else if ([gsObj.source isEqualToString:@"SGFOODONFOOT"])
                {
                    updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor cyanColor]];
                }
                else
                {
                    updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor darkTextColor]];
                }
                
                
             
            }
            
            if([self coordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) ContainedinRegion:region])
            {
                
                [resultArray addObject:gsObj];
            }
            
        }
    }
    
    if (refresh)
    {
        NSLog(@"drawing map rect");
        dispatch_async(dispatch_get_main_queue(), ^
       {
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
-(MKMapRect)updateCrumbsWithFoodItem:(FoodItem*)gsObj IntoResultArray:(NSMutableArray*)resultArray withMap:(MKMapView*)map andRegion:(MKCoordinateRegion)region andUpdateRect:(MKMapRect)updateRect
{
    if (![resultArray containsObject:gsObj]) {
        if([self coordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) ContainedinRegion:region])
        {
            NSLog(@"adding to result");
            [resultArray addObject:gsObj];
        }
        NSLog(@"adding to scoped");
        [scopedGSObjectArray addObject:gsObj];
        
        if (!((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs)
        {
            ((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs = [[CrumbPath alloc] initWithCenterCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue)];
            [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];
            
        }
        
        if (map.overlays.count == 0) {
            NSLog(@"adding overlay in update crumbs");
            [map addOverlay:((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs];
        }
        if ([gsObj.source isEqualToString:@"LADY IRON CHEF"])
        {
            updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor blueColor]]; //lady iron chef
        }
        else if ([gsObj.source isEqualToString:@"IEATISHOOTIPOST"])
        {
            updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor redColor]];
        }
        else if ([gsObj.source isEqualToString:@"DANIEL FOOD DIARY"])
        {
            updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor magentaColor]];
        }
        else if ([gsObj.source isEqualToString:@"KEROPOKMAN"])
        {
            updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor greenColor]];
        }
        else if ([gsObj.source isEqualToString:@"LOVE SG FOOD"])
        {
            updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor blackColor]];
        }
        else if ([gsObj.source isEqualToString:@"SGFOODONFOOT"])
        {
            updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor cyanColor]];
        }
        else
        {
            updateRect = [((UnderMapViewController*)self.slidingViewController.underRightViewController).crumbs addCoordinate:CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue) withColor:[UIColor darkTextColor]];
        }

        
    }
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
    dispatch_async(GSserialQueue, ^{
        if (userLocation && self.loadedGSObjectArray.count>0) {
            CLLocation* defensiveUserLocation = [userLocation.location copy];
            for (FoodItem* item in self.loadedGSObjectArray) {
                CLLocation *gsLoc = [[CLLocation alloc] initWithLatitude:item.latitude.doubleValue longitude:item.longitude.doubleValue];
                CLLocationDistance meters = [gsLoc distanceFromLocation:defensiveUserLocation];
                [item setDistance_in_meters:[NSNumber numberWithDouble:meters]];
            }
        }
    });

    [Flurry setLatitude:location.coordinate.latitude
              longitude:location.coordinate.longitude horizontalAccuracy:0.001f verticalAccuracy:0.001f];
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
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"RightReveal"]==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Enabled" forKey:@"RightReveal"];
        //show instructions
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
        }
        
    }
    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    for (id annnote in underMapView.annotations) {
        if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
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
    
    NSLog(@"underLeftWillDisAppear");
    
    if (self.selectionChanged) {
        self.selectionChanged=NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
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
            menuViewController.InfoPanelView.hidden = YES;
            menuViewController.shopLabel.hidden = YES;
            menuViewController.locationButtonView.hidden = YES;
            menuViewController.shopImageView.hidden = YES;
            menuViewController.locationButton.hidden = YES;
            menuViewController.resetTopViewButton.hidden = YES;
            [menuViewController.resetTopViewButton removeGestureRecognizer:self.slidingViewController.panGesture];
            [self.view addGestureRecognizer:self.slidingViewController.panGesture];
            menuViewController.allButton.hidden = YES;
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
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"LeftReveal"]==nil) {
                [self hintLeft];
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
                    if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
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
                    [self updateOverlay];
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
        if ([annnote isKindOfClass:[MKUserLocation class]] || [annnote isKindOfClass:[GScursor class]]) {
            //NOOP
        }else{
            [underMapView removeAnnotation:annnote];  // remove any annotations that exist
        }
    }
    FoodItem* gsObj = [self.GSObjectArray objectAtIndex:idx];
    self.selectedGsObject = gsObj;

    [underMapView addAnnotation:gsObj];
    UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
    menuViewController.shopLabel.text = gsObj.title;
    if (gsObj.distance_in_meters.intValue<1000) {
        menuViewController.distanceLabel.text = [NSString stringWithFormat:@"%d m",gsObj.distance_in_meters.intValue];
    }else if (gsObj.distance_in_meters.intValue>1000) {
        menuViewController.distanceLabel.text = [NSString stringWithFormat:@"%.01f km",gsObj.distance_in_meters.floatValue/1000.0f];
    }else if (gsObj.distance_in_meters.intValue>100000) {
        menuViewController.distanceLabel.text = [NSString stringWithFormat:@""];
    }
    
    
    menuViewController.gsObjSelected = gsObj;
    if (gsObj.images.count>0) {
        [menuViewController.shopImageView setImageWithURL:[NSURL URLWithString:((FoodImage*)[[gsObj.images allObjects] objectAtIndex:0]).low_res_image]];
        
    }else{
        [menuViewController.shopImageView setImage:nil];
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft||orientation == UIInterfaceOrientationLandscapeRight) {
        [self.imageTableView  reloadData];
    }
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
    [self animatePin];
    
}
-(void)faceDetector
{
    // Load the picture for face detection
    UIImageView* image = [[UIImageView alloc] initWithImage:
                          [UIImage imageNamed:@"facedetectionpic.jpg"]];
    
    
    // Execute the method used to markFaces in background
    [self markFaces:image];
}

-(void)markFaces:(UIImageView *)facePicture
{
    // draw a CI image with the previously loaded face detection picture
    CIImage* image = [CIImage imageWithCGImage:facePicture.image.CGImage];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    // create an array containing all the detected faces from the detector
    NSArray* features = [detector featuresInImage:image];
    if (features.count >0)
    {
        NSLog(@"face found");
    }
}
#pragma mark - Search Bar Delegates



-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.canSearch) {
        [Flurry logEvent:@"Search_Started" timed:YES];
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
    return NO;
}

-(void)searchViewControllerDidFinishWithSearchString:(NSString *)searchString
{
    
    if (searchString.length>0) {
        [Flurry endTimedEvent:@"Search_Started" withParameters:nil];
    }
    self.searchTextField.text = searchString;
    self.currentSearch = searchString;
    self.tableView.hidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topDidAnchorLeft ) name:ECSlidingViewTopDidAnchorLeft object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underRightWillDisappear) name:ECSlidingViewUnderRightWillDisappear object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underLeftWillAppear) name:ECSlidingViewUnderLeftWillAppear object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(underLeftWillDisappear) name:ECSlidingViewUnderLeftWillDisappear object:nil];
    
    if (searchString.length==0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
        });
        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
        dispatch_async(GSserialQueue, ^{
            [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:@"" IntoArray:self.GSObjectArray WithRefresh:YES];
            NSLog(@"finished recalc");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
                if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
                
                MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                [self updateOverlay];
            });
        });
    }else{
        [self textFieldShouldReturn:self.searchTextField];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [scopedGSObjectArray removeAllObjects];
    if (textField.text.length > 0) {
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        overlay.progress = 1.0;
        [overlay postMessage:[NSString stringWithFormat:@"Current Search: %@",textField.text] animated:YES];
        dispatch_async(GSserialQueue, ^{
            currentSearch = textField.text;
            
            if (currentSearch.length>0) {
                NSArray* searchterms = [currentSearch componentsSeparatedByString:@"+"];
                
                for (NSString* term in searchterms) {
                    if ([term rangeOfString:@"addr="].location!=NSNotFound) {
                        [Flurry logEvent:@"SearchForAddress" timed:NO];
                        //reverse geocode
                        if (!self.geocoder) {
                            self.geocoder = [[CLGeocoder alloc] init];
                        }
                        NSString* searchaddress;
                        searchaddress = [[term stringByReplacingOccurrencesOfString:@"addr=" withString:@""] stringByAppendingString:@" Singapore"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            textField.text = @"";
                            currentSearch = @"";
                            MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                            overlay.animation = MTStatusBarOverlayAnimationFallDown;
                            [overlay postImmediateFinishMessage:@"Cleared" duration:1.0 animated:YES];
                            
                        });
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showWithStatus:@"Searching"];
                        });
                        [self.geocoder geocodeAddressString:searchaddress completionHandler:^(NSArray *placemarks, NSError *error) {
                            if ([placemarks count] > 0) {
                                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                NSLog(@"found geocode at %@",placemark);
                                self.shouldZoomToLocation = [[CLLocation alloc]initWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
                                [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:MKCoordinateRegionMake(self.shouldZoomToLocation.coordinate, MKCoordinateSpanMake(0.003, 0.003)) AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    
                                    [((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView setRegion:MKCoordinateRegionMake(self.shouldZoomToLocation.coordinate, MKCoordinateSpanMake(0.003, 0.003)) animated:YES];
                                    [SVProgressHUD dismiss];
                                    [self.tableView reloadData];
                                    
                                    
                                    if ([self.GSObjectArray count]>0)
                                    {
                                        [self didScrollToEntryAtIndex:0];
                                    }
                                    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                                    [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                                    [self updateOverlay];
                                    
                                });
                                
                                
                            }else{
                                NSLog(@"couldnt find location");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SVProgressHUD dismiss];
                                });
                                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Sorry!" message:[NSString stringWithFormat:@"We couldn't find %@",searchaddress] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                                
                            }
                        }];
                    
                    }
                    else
                    {
                        [Flurry logEvent:@"SearchForFood" timed:NO];
                        MKCoordinateRegion region = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView.region;
                        dispatch_async(GSserialQueue, ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD showWithStatus:@"Searching" maskType:SVProgressHUDMaskTypeGradient];
                            });

                            [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:currentSearch IntoArray:self.GSObjectArray WithRefresh:YES];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"%d gsobjectarray , %d scoped",self.GSObjectArray.count,self.scopedGSObjectArray.count);
                                // if searching for individual stall , assuming not found in current search area
                                if (self.GSObjectArray.count == 0 && self.scopedGSObjectArray.count>0) {
                                    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
                                    FoodItem* gsObj = [scopedGSObjectArray objectAtIndex:scopedGSObjectArray.count-1];
                                    [underMapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(gsObj.latitude.doubleValue, gsObj.longitude.doubleValue), MKCoordinateSpanMake(0.003, 0.003)) animated:YES];
                                    
                                    [self.GSObjectArray removeAllObjects];
                                    [self.GSObjectArray addObjectsFromArray:self.scopedGSObjectArray];
                                }
                                [self.tableView reloadData];
                                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                
                                if (self.scopedGSObjectArray.count > 1) {
                                    MKMapView* underMapView = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
                                    [underMapView setVisibleMapRect:MKMapRectInset([underMapView visibleMapRect], [underMapView visibleMapRect].size.width*0.005, [underMapView visibleMapRect].size.height*0.005) animated:YES];
                                }
                                
                                
                                if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
                                MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                                [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                                [self updateOverlay];
                                [SVProgressHUD dismiss];
                            });
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
        dispatch_async(GSserialQueue, ^{
            [self recalculateScopeFromLoadedArray:self.loadedGSObjectArray WithRegion:region AndSearch:@"" IntoArray:self.GSObjectArray WithRefresh:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"dismiss");
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
                if ([self.GSObjectArray count]>0) {[self didScrollToEntryAtIndex:0];}
                
                MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                [overlay postImmediateFinishMessage:[NSString stringWithFormat:@"Found %d Entries",self.GSObjectArray.count] duration:2.0 animated:YES];
                [self updateOverlay];
            });
        });
        
    }
    return YES;
}
#pragma mark - Table View


-(void)calculateRandom
{
    if (self.random) {
        self.random = !self.random;
        self.randomIndex = rand() % self.GSObjectArray.count;
        [self.tableView reloadData];
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [SVProgressHUD showWithStatus:@"Thinking.."];
                       });
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.random = !self.random;
            self.randomIndex = rand() % self.GSObjectArray.count;
            [self.tableView reloadData];
            if (self.random) {
                [self scrollViewDidEndDecelerating:self.tableView];
            }
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [SVProgressHUD dismiss];
                           });
        });
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.imageTableView) {
        return self.selectedGsObject.images.count;
    }else{
        if ([GSObjectArray count]>0) {
            if (self.random) {
                return 3;
            }
            return [GSObjectArray count]+2;
        }
        return 2;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.imageTableView) {
        return 0;
    }else{
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft||orientation == UIInterfaceOrientationLandscapeRight) {
            return 0;
        }else{
            return 64;
        }
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.imageTableView) {
        return nil;
    }
    else
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft||orientation == UIInterfaceOrientationLandscapeRight) {
            return nil;
        }else{
            UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 64)];
            [headerView setBackgroundColor:[UIColor clearColor]];
            UIView* searchView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 44)];
            [searchView setBackgroundColor:[UIColor whiteColor]];
            UIImageView* searchImage = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 30, 30)];
            [searchImage setImage:[UIImage imageNamed:@"search.png"]];
            [searchView addSubview:searchImage];
            
            if (!self.searchTextField) {
                self.searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(44, 0, 320-10-10-44-44,44)];
                [self.searchTextField setDelegate:self];
                [self.searchTextField setBackgroundColor:[UIColor clearColor]];
                self.searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                self.searchTextField.placeholder = @"What's good nearby?";
                
            }
            [searchView addSubview:self.searchTextField];
            
            UIButton* resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [resetButton setBackgroundColor:[UIColor whiteColor]];
            [resetButton setBackgroundImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
            [resetButton setFrame:CGRectMake(300-44, 0, 44, 44)];
            [resetButton addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
            [resetButton addTarget:self action:@selector(setBgColorForButton:) forControlEvents:UIControlEventTouchDown];
            [searchView addSubview:resetButton];
            [headerView addSubview:searchView];
            
            return headerView;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.imageTableView) {
        return 160;
    }else{
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
        //return 200;
        return ((FoodItem*)[GSObjectArray objectAtIndex:indexPath.row-1]).cell_height.intValue;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.imageTableView) {
        static NSString *FromCellIdentifier = @"FromCell";
        ImageCell* cell = (ImageCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier];
        if (cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ImageCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[UITableViewCell class]])
                {
                    cell = (ImageCell*)currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
        }
        FoodImage* selectedImage = [[self.selectedGsObject.images allObjects] objectAtIndex:indexPath.row];
        [cell.imageView setImageWithURL:[NSURL URLWithString:selectedImage.low_res_image] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
            [cell.imageView setImage:image];
        } failure:nil];
        
        [cell.activityIndicator startAnimating];
        return cell;
    }else{
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
            if (self.GSObjectArray.count > 2) {
                [cell.randomButton addTarget:self action:@selector(calculateRandom) forControlEvents:UIControlEventTouchUpInside];
                cell.randomContainer.hidden = NO;
            }else{
                cell.randomContainer.hidden = YES;
                
            }
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
                endcell.searchImageView.hidden = YES;
                endcell.searchLabel.hidden = YES;
            }else{
                if (self.GSObjectArray.count==0) {
                    endcell.endTableBackgroundView.hidden = NO;
                    endcell.searchImageView.hidden = NO;
                    endcell.searchLabel.hidden = NO;
                }else{
                    endcell.endTableBackgroundView.hidden = YES;
                    endcell.searchImageView.hidden = YES;
                    endcell.searchLabel.hidden = YES;
                }
            }
            return endcell;
        }
        FoodItem* gsObj;
        if (self.random) {
            gsObj = [self.GSObjectArray objectAtIndex:self.randomIndex];
        }else{
            gsObj = [self.GSObjectArray objectAtIndex:indexPath.row-1];
        }
        CGSize s = [gsObj.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        CGSize subTitleSize = [gsObj.sub_title sizeWithFont:kSubtitleFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        NSString *FromCellIdentifier = [NSString stringWithFormat:@"%@,%d,%d",gsObj.source,(int)s.height,(int)subTitleSize.height];
        
        RotatingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier];
        
        if (cell == nil)
        {
            CGSize s = [gsObj.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
            CGSize subTitleSize = [gsObj.sub_title sizeWithFont:kSubtitleFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
            //        CGSize sourceSize = [gsObj.source sizeWithFont:kSourceFont constrainedToSize:CGSizeMake(kCellSubtitleHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
            cell = [[RotatingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FromCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.mainCellView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, cell.bounds.size.width-2*kCellPaddingLeft, gsObj.cell_height.intValue-kCellPaddingTop*2)];
            
            cell.colorBarView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, kCellColorBarWidth, gsObj.cell_height.intValue-kCellPaddingTop*2)];
            
            if ([gsObj.source isEqualToString:@"LADY IRON CHEF"])
            {
                [cell.colorBarView setBackgroundColor:[UIColor blueColor]];

            }
            else if ([gsObj.source isEqualToString:@"IEATISHOOTIPOST"])
            {
                [cell.colorBarView setBackgroundColor:[UIColor redColor]];
            }
            else if ([gsObj.source isEqualToString:@"DANIEL FOOD DIARY"])
            {
                [cell.colorBarView setBackgroundColor:[UIColor magentaColor]];

            }
            else if ([gsObj.source isEqualToString:@"KEROPOKMAN"])
            {
                [cell.colorBarView setBackgroundColor:[UIColor greenColor]];

            }
            else if ([gsObj.source isEqualToString:@"LOVE SG FOOD"])
            {
                [cell.colorBarView setBackgroundColor:[UIColor blackColor]];
            }
            else if ([gsObj.source isEqualToString:@"SGFOODONFOOT"])
            {
                [cell.colorBarView setBackgroundColor:[UIColor cyanColor]];
            }
            else
            {
                [cell.colorBarView setBackgroundColor:[UIColor darkTextColor]];
            }

            
            
            
            
            
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
            cell.subTitleLabel.shadowOffset = CGSizeMake(0.2, 0.2);
            
            
            
            cell.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(cell.bounds.size.width-10-5-40,gsObj.cell_height.intValue-5-30 ,40,30)];
            cell.distanceLabel.backgroundColor = [UIColor clearColor];
            cell.distanceLabel.textColor = [UIColor whiteColor];
            [cell.distanceLabel setFont:kDistanceFont];
            [cell.distanceLabel setTextAlignment:NSTextAlignmentRight];
            [cell.distanceLabel setNumberOfLines:0];
            cell.distanceLabel.shadowColor = [UIColor blackColor];
            cell.distanceLabel.shadowOffset = CGSizeMake(0.2, 0.2);
            
            
            
            cell.distanceIcon = [[UIImageView alloc]initWithFrame:CGRectMake(cell.distanceLabel.frame.origin.x - 10 ,cell.distanceLabel.frame.origin.y  ,10,cell.distanceLabel.frame.size.height)];
            [cell.distanceIcon setImage:[UIImage imageNamed:@"distanceWhite.png"]];
            [cell.distanceIcon setContentMode:UIViewContentModeScaleAspectFit];
            
            cell.distanceColorBarView = [[UIView alloc]initWithFrame:CGRectMake(cell.distanceLabel.frame.origin.x - 10-5, cell.distanceLabel.frame.origin.y, cell.distanceLabel.frame.size.width + 10 + cell.distanceIcon.frame.size.width, cell.distanceLabel.frame.size.height)];
            [cell.distanceColorBarView setBackgroundColor:BLUE_COLOR];
            [cell.distanceColorBarView setAlpha:0.5];
            
            [cell.contentView addSubview:cell.mainCellView];
            [cell.contentView addSubview:cell.distanceColorBarView];
            [cell.contentView addSubview:cell.colorBarView];
            [cell.contentView addSubview:cell.starview];
            [cell.contentView addSubview:cell.titleLabel];
            [cell.contentView addSubview:cell.subTitleLabel];
            [cell.contentView addSubview:cell.sourceLabel];
            [cell.contentView addSubview:cell.distanceIcon];
            [cell.contentView addSubview:cell.distanceLabel];
            
        }
        
        
        cell.titleLabel.text = gsObj.title;
        cell.subTitleLabel.text = [[gsObj.sub_title stringByReplacingOccurrencesOfString:@": " withString:@""]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cell.sourceLabel.text = [NSString stringWithFormat:@"source: %@",gsObj.source];
        if (gsObj.distance_in_meters.intValue<1000) {
            cell.distanceLabel.text = [NSString stringWithFormat:@"%d m",gsObj.distance_in_meters.intValue];
        }else if (gsObj.distance_in_meters.intValue>1000) {
            cell.distanceLabel.text = [NSString stringWithFormat:@"%.01f km",gsObj.distance_in_meters.floatValue/1000.0f];
        }else if (gsObj.distance_in_meters.intValue>100000) {
            cell.distanceLabel.text = [NSString stringWithFormat:@""];
        }
        
        cell.mainCellView.alpha = self.alphaValue;
        cell.mainCellView.backgroundColor = [UIColor blackColor];
        cell.mainCellView.layer.cornerRadius = 0;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.imageTableView) {
        if ([self.imageTableView cellForRowAtIndexPath:indexPath].imageView.image != nil) {
            fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [fullscreenButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
            
            [fullscreenButton setFrame:self.view.bounds];
            [fullscreenButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView* newImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
            FoodImage* selectedImage = [[self.selectedGsObject.images allObjects] objectAtIndex:indexPath.row];
            [newImageView setImageWithURL:[NSURL URLWithString:selectedImage.high_res_image] placeholderImage:[self.imageTableView cellForRowAtIndexPath:indexPath].imageView.image];
            
            [newImageView setContentMode:UIViewContentModeScaleAspectFit];
            [newImageView setUserInteractionEnabled:NO];
            [fullscreenButton addSubview:newImageView];
            [self.view addSubview:fullscreenButton];
        }
    }else{
        if (indexPath.row == 0 || indexPath.row == [self.GSObjectArray count]+1)
        {
            return;
        }
        FoodItem* selectedGSObj;
        
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

-(void)didTouchMapAtCoordinate:(CLLocationCoordinate2D)mapTouchCoordinate
{
    MKMapView* map = ((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView;
    CLLocation* touchLocation = [[CLLocation alloc]initWithLatitude:mapTouchCoordinate.latitude longitude:mapTouchCoordinate.longitude];
    MKZoomScale currentZoomScale = map.bounds.size.width / map.visibleMapRect.size.width;
    UnderMapViewController* menuViewController = ((UnderMapViewController*)self.slidingViewController.underRightViewController);
    
    for (FoodItem* gsObj in self.loadedGSObjectArray)
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
    [sender removeFromSuperview];
}

-(BOOL)shouldAutorotate{
    
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
#warning crashes here if empty
    
    
    if (fullscreenButton) {
        [fullscreenButton removeFromSuperview];
        fullscreenButton = nil;
    }
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
        self.imageTableView.hidden = NO;
        [self.slidingViewController setAnchorLeftPeekAmount:160.0f];
        [self.slidingViewController resetTopView];
        [self.tableView reloadData];
        //        [self underRightWillDisappear];
    }
    else
    {
        self.imageTableView.hidden = YES;
        [self.slidingViewController setAnchorLeftPeekAmount:1.0f];
        [self.slidingViewController resetTopView];
        [self.tableView reloadData];
    }
}
-(void)showMap
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
}


-(void)animatePin
{
    MKMapView* underMapView = ((MKMapView*)((UnderMapViewController*)self.slidingViewController.underRightViewController).mapView);
    for (id annote in underMapView.annotations) {
        if ([annote isKindOfClass:[FoodItem class]]) { //should only have one
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

-(void)hintLeft
{
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGRect slideViewFinalFrame = CGRectMake(15, 0, self.view.bounds.size.width,  self.view.bounds.size.height);
        CGRect slideViewReturnFrame = CGRectMake(00, 0, self.view.bounds.size.width,  self.view.bounds.size.height);
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.slidingViewController.topViewController.view.frame = slideViewFinalFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.slidingViewController.topViewController.view.frame = slideViewReturnFrame;
            } completion:^(BOOL finished) {
                
            }];
        }];
    });
    
}
-(void)hintRight
{
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        CGRect slideViewFinalFrame = CGRectMake(-15, 0, self.view.bounds.size.width,  self.view.bounds.size.height);
        CGRect slideViewReturnFrame = CGRectMake(00, 0, self.view.bounds.size.width,  self.view.bounds.size.height);
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.slidingViewController.topViewController.view.frame = slideViewFinalFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.slidingViewController.topViewController.view.frame = slideViewReturnFrame;
            } completion:^(BOOL finished) {
                
            }];
        }];
    });
    
}
-(void)setBgColorForButton:(UIButton*)sender
{
    NSLog(@"changing background color");
    [sender setBackgroundColor:[UIColor lightGrayColor]];
}
-(void)cancelSearch:(UIButton*)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    });
    NSLog(@"cancelling search");
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender setBackgroundColor:[UIColor whiteColor]];
    });
    
    if (self.searchTextField.text.length >0) {
        self.searchTextField.text = @"";
        [self textFieldShouldReturn:self.searchTextField];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }
}

-(void)getDirectionsToSelectedGSObj
{
    
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

-(void)alphaChanged:(UIStepper*)sender
{
    NSLog(@"stepper alpha changed to %f",sender.value);
    
    self.alphaValue = sender.value;
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setImageTableView:nil];
    [super viewDidUnload];
}
- (NSManagedObjectContext *)dataManagedObjectContext {
    NSManagedObjectContext *managedObjectContext = nil;
    
    NSPersistentStoreCoordinator *coordinator = [((AppDelegate*)[UIApplication sharedApplication].delegate) persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [managedObjectContext setUndoManager:nil];
    }
    return managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel
{
    if (_dataManagedObjectModel != nil) {
        return _dataManagedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FoodItem" withExtension:@"momd"];
    _dataManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _dataManagedObjectModel;
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
                         NSLog(@"Done!");
                     }];
    }else{
        [self.tableView reloadData];
    }
}

@end