//
//  FoodPlaceViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 30/3/13.
//
//
#import "MapSearchViewController.h"
#import "ItemMapViewController.h"
#import "HHStarView.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "SVWebViewController.h"
#import "AFHTTPClient.h"
#import "FoodPlaceViewController.h"
#import "FoodPlace.h"
#import "FoodItem.h"
#import "FoodRating.h"
#import "FoodImage.h"
#import "TBAPIClient.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ShopDetailViewController.h"
#define kTitleFont [UIFont fontWithName:@"Raleway-Bold" size:30.0f]
#define kRegFont [UIFont fontWithName:@"Raleway" size:12.0f]

#define kRevTitleFont [UIFont fontWithName:@"Raleway" size:17.0f]
#define kReviewFont [UIFont fontWithName:@"Raleway-Medium" size:25.0f]
#define kMedFont [UIFont fontWithName:@"Raleway-Medium" size:12.0f]
@interface FoodPlaceViewController ()

@end

@implementation FoodPlaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"view did load");
    UIScrollView* mainScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    CGSize labelSize = [self.foodplace.title sizeWithFont:kTitleFont constrainedToSize:CGSizeMake(260, 999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UIView* headerContainerView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, MAX(labelSize.height,60)+80+30+20)];
    self.headerLabel= [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 260, MAX(labelSize.height,60))];
    UIScrollView* headerScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, self.headerLabel.frame.origin.y+MAX(labelSize.height,60)+10, 280, 80)];
    [headerScrollView setTag:3];//3 for headerscrollview
    [headerScrollView setDelegate:self];
    self.headerPageControl= [[UIPageControl alloc]initWithFrame:CGRectMake(10, headerScrollView.frame.origin.y+headerScrollView.frame.size.height+5, 280,10)];
    [self.headerPageControl setNumberOfPages:3];
    [self.headerPageControl setBackgroundColor:[UIColor clearColor]];
    NSString *version = [[UIDevice currentDevice] systemVersion];
    if ([version floatValue]>6.0) {
        [self.headerPageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [self.headerPageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
    }
    [self.headerPageControl setCurrentPage:1];
    
    
    [headerContainerView addSubview:self.headerLabel];
    [headerContainerView addSubview:headerScrollView];
    [headerContainerView addSubview:self.headerPageControl];
    [headerContainerView setBackgroundColor:[UIColor whiteColor]];
    headerContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    headerContainerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    headerContainerView.layer.shadowOpacity = 0.8;
    headerContainerView.layer.shadowRadius = 5;
    UIBezierPath* headerShadowPath = [UIBezierPath bezierPathWithRect:headerContainerView.bounds];
    headerContainerView.layer.shadowPath = headerShadowPath.CGPath;

    [self.headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.headerLabel setFont:kTitleFont];
    [self.headerLabel setNumberOfLines:0];
    [self.headerLabel setText:self.foodplace.title];
    [self.headerLabel setTextAlignment:NSTextAlignmentCenter];
    
    [headerScrollView setBackgroundColor:[UIColor clearColor]];
    [headerScrollView setContentSize:CGSizeMake(headerScrollView.bounds.size.width*3, headerScrollView.bounds.size.height)];
    [headerScrollView setPagingEnabled:YES];
    [headerScrollView setScrollsToTop:NO];
    [headerScrollView setContentOffset:CGPointMake(headerScrollView.bounds.size.width, 0)];
    [headerScrollView setShowsHorizontalScrollIndicator:NO];
    UIImageView* pinView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pin.png"]];
    [pinView setFrame:CGRectMake(560+(280/2),headerScrollView.bounds.size.height/2 , 32, 44)];
    [pinView setCenter:CGPointMake(560+(280/2), headerScrollView.bounds.size.height/2)];

    UIImageView* starBackView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"5starsgray"]];
    [starBackView setAlpha:0.5];
    [starBackView setFrame:CGRectMake(290,20,235-(10*2),38.66f)];
    UIImageView* userStarBackView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"5starsgray"]];
    [userStarBackView setFrame:CGRectMake(10,20,235-(10*2),38.66f)];
    userStarBackView.center = CGPointMake(headerScrollView.bounds.size.width/2, headerScrollView.bounds.size.height/2);
    [userStarBackView setAlpha:0.5];
    
    self.pubStarView = [[HHStarView alloc]initWithFrame:CGRectMake(290,20,280-(10*2),38.66f) andRating:0.0f withLabel:YES animated:YES];
    [self.pubStarView setUserInteractionEnabled:NO];
    [self.pubStarView.label setTextColor:[UIColor blackColor]];
    [self.pubStarView.label setFont:kRegFont];
    [self.pubStarView.sublabel setTextColor:[UIColor blackColor]];
    [self.pubStarView.sublabel setFont:kRegFont];
    [self.pubStarView setFoodplace:self.foodplace];
    
    
    self.userStarView = [[HHStarView alloc]initWithFrame:CGRectMake(10,20,235-(10*2),38.66f) andRating:self.foodplace.current_rating.floatValue withLabel:NO animated:NO];
    self.userStarView.center = CGPointMake(headerScrollView.bounds.size.width/2, headerScrollView.bounds.size.height/2);
    self.userStarView.context = [((AppDelegate*)[UIApplication sharedApplication].delegate) dataManagedObjectContext];
    self.userStarView.GSdataSerialQueue = self.GSdataSerialQueue;
    [self.userStarView setFoodplace:self.foodplace];
    [self.userStarView.sublabel setFont:kRegFont];
    [self.userStarView.label setFont:kRegFont];
    [self.userStarView addObserver:self.pubStarView forKeyPath:@"userRating" options:0 context:nil];
    [self.userStarView addObserver:self forKeyPath:@"userRating" options:0 context:nil];
    
    UITapGestureRecognizer* mapTapGestureRecog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectMap:)];
    [mapTapGestureRecog setNumberOfTapsRequired:1];
    
    MKMapView* mapView  = [[MKMapView alloc]initWithFrame:CGRectMake(560, 0, 280, 80)];
    [mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.foodplace.latitude.doubleValue, self.foodplace.longitude.doubleValue), MKCoordinateSpanMake(0.007, 0.007))];
    [mapView setScrollEnabled:NO];
    [mapView setZoomEnabled:NO];
    mapView.showsUserLocation = YES;
    [mapView.layer setBorderColor:[UIColor blackColor].CGColor];
    [mapView.layer setBorderWidth:2.0f];
    [mapView addGestureRecognizer:mapTapGestureRecog];
    [headerScrollView addSubview:mapView];
    [headerScrollView addSubview:pinView];
    [headerScrollView addSubview:userStarBackView];
    [headerScrollView addSubview:starBackView];
    [headerScrollView addSubview:self.userStarView];
    [headerScrollView addSubview:self.pubStarView];
    if (self.foodplace.current_user_rated.boolValue) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] intValue]];
        NSSet* filteredSet = [self.foodplace.ratings filteredSetUsingPredicate:predicate];
        FoodRating* foundRating = nil;
        if ([filteredSet count] > 0) {
            NSLog(@"found rating");
            foundRating = [[filteredSet allObjects] objectAtIndex:0];
            [self.userStarView removeObserver:self.pubStarView forKeyPath:@"userRating"];
            [self.userStarView starViewSetRating:foundRating.score.intValue isUser:YES];
            [self.userStarView addObserver:self.pubStarView forKeyPath:@"userRating" options:0 context:nil];
            
        }else{
            NSLog(@"diding find rating");
            [self.userStarView removeObserver:self.pubStarView forKeyPath:@"userRating"];
            [self.userStarView starViewSetRating:0 isUser:YES];
            [self.userStarView addObserver:self.pubStarView forKeyPath:@"userRating" options:0 context:nil];
            [self.pubStarView starViewSetRating:self.foodplace.current_rating.intValue isUser:NO];
        }
    }else{
        NSLog(@"user hasnt rated");
        [self.userStarView removeObserver:self.pubStarView forKeyPath:@"userRating"];
        [self.userStarView starViewSetRating:0 isUser:YES];
        [self.userStarView addObserver:self.pubStarView forKeyPath:@"userRating" options:0 context:nil];
        [self.pubStarView starViewSetRating:self.foodplace.current_rating.intValue isUser:NO];
        
    }

    
    UIView* imageContainerView = [[UIView alloc]initWithFrame:CGRectMake(headerContainerView.frame.origin.x, headerContainerView.frame.origin.y+headerContainerView.frame.size.height+10,headerContainerView.frame.size.width, 100)];
    imageContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageContainerView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    imageContainerView.layer.shadowOpacity = 0.8;
    imageContainerView.layer.shadowRadius = 5;

    UIBezierPath* shadowPath = [UIBezierPath bezierPathWithRect:imageContainerView.bounds];
    imageContainerView.layer.shadowPath = shadowPath.CGPath;
    
    
    UIScrollView*imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 10, 280, 80)];
    [imageScrollView setBackgroundColor:[UIColor clearColor]];
    [imageScrollView setContentSize:CGSizeMake(imageScrollView.bounds.size.height*self.foodplace.images.count, imageScrollView.bounds.size.height)];
    [imageScrollView setShowsHorizontalScrollIndicator:NO];
    [imageScrollView setClipsToBounds:YES];
    for (int i=0; i<self.foodplace.images.count; i++) {
        FoodImage* foodimage = [[self.foodplace.images allObjects]objectAtIndex:i];
        UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*80, 0, 80, 80)];
        [imageView setImageWithURL:[NSURL URLWithString:foodimage.high_res_image] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectImage:)];
        [imageTap setNumberOfTapsRequired:1];
        [imageView addGestureRecognizer:imageTap];

        [imageScrollView addSubview:imageView];
    }
    [imageScrollView setPagingEnabled:YES];
    [imageScrollView setScrollsToTop:NO];
    [imageContainerView addSubview:imageScrollView];
    [imageContainerView setBackgroundColor:[UIColor whiteColor]];
    
    [mainScrollView addSubview:headerContainerView];
    [mainScrollView addSubview:imageContainerView];
    [mainScrollView addSubview:self.reviewTable];

    [self.view addSubview:mainScrollView];
    [self.reviewTable setFrame:CGRectMake(0, 0, 300, (self.foodplace.items.count*70) + 44)];

    UIView* reviewTableContainer = [[UIView alloc]initWithFrame:CGRectMake(10, imageContainerView.frame.origin.y+imageContainerView.frame.size.height + 10, 300, (self.foodplace.items.count*70) + 44)];
    [mainScrollView addSubview:reviewTableContainer];
    [reviewTableContainer addSubview:self.reviewTable];

    [reviewTableContainer setBackgroundColor:[UIColor whiteColor]];
    [self.reviewTable setScrollsToTop:NO];
    reviewTableContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    reviewTableContainer.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    reviewTableContainer.layer.shadowOpacity = 0.8;
    reviewTableContainer.layer.shadowRadius = 5;
    UIBezierPath* tableShadowPath = [UIBezierPath bezierPathWithRect:reviewTableContainer.bounds];
    reviewTableContainer.layer.shadowPath = tableShadowPath.CGPath;
    
    [mainScrollView setContentSize:CGSizeMake(self.view.bounds.size.width,reviewTableContainer.frame.origin.y + reviewTableContainer.frame.size.height +60)];
    
    UIImage *actionButton = [[UIImage imageNamed:@"action.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    UIButton* barbuttonitem = [UIButton buttonWithType:UIButtonTypeCustom];
    barbuttonitem.frame = CGRectMake(0.0, 0.0, actionButton.size.width, actionButton.size.height);
    
    [barbuttonitem setBackgroundImage:actionButton forState:UIControlStateNormal];
    [barbuttonitem addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barbutton = [[UIBarButtonItem alloc]initWithCustomView:barbuttonitem];
    self.navigationItem.rightBarButtonItem = barbutton;

    if (self.reach == nil) {
        self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    }
    __weak FoodPlaceViewController* weakself =  self;
    self.reach.reachableBlock = ^(Reachability*reach)
    {
        weakself.reachable = YES;
    };
    
    self.reach.unreachableBlock = ^(Reachability*reach)
    {
        weakself.reachable = NO;
    };

    [self.reach startNotifier];
    
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    @try{
        [self.userStarView addObserver:self.pubStarView forKeyPath:@"userRating" options:0 context:nil];
        [self.userStarView addObserver:self forKeyPath:@"userRating" options:0 context:nil];        
        [self.pubStarView starViewSetRating:self.foodplace.current_rating.intValue isUser:NO isAnimated:YES];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    @try{
        [self.userStarView removeObserver:self forKeyPath:@"userRating"];
        [self.userStarView removeObserver:self.pubStarView forKeyPath:@"userRating"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    @try{
        [self.userStarView removeObserver:self forKeyPath:@"userRating"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
    @try{
        [self.userStarView removeObserver:self.pubStarView forKeyPath:@"userRating"];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showActionSheet
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Get Directions" otherButtonTitles:@"Suggest Location" ,nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    [actionSheet showInView:self.view];
    
    
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
        daddr = [NSString stringWithFormat:@"%f,%f", self.foodplace.latitude.doubleValue,self.foodplace.longitude.doubleValue];
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

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Get Directions"]) {
        [self getDirectionsToSelectedGSObj];
    }else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Suggest Location"]) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone"
                                                                 bundle: nil];
        MapSearchViewController* mapsearch = [mainStoryboard instantiateViewControllerWithIdentifier:@"MapSearch"];
        mapsearch.gsobj = self.foodplace;
        [self.navigationController pushViewController:mapsearch animated:YES];

    }
}


#pragma mark TableViewDelegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foodplace.items.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    UIView* seperator = [[UIView alloc]initWithFrame:CGRectMake(0,headerView.frame.size.height-2, tableView.frame.size.width, 2)];
    [seperator setBackgroundColor:[UIColor darkGrayColor]];
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 00, tableView.frame.size.width-40, 44)];
    [headerView addSubview:headerLabel];
    [headerView addSubview:seperator];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    [headerLabel setTextColor:[UIColor blackColor]];
    [headerLabel setText:@"Reviews"];
    [headerLabel setFont:kReviewFont];

    return headerView;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    FoodItem* item = [[self.foodplace.items allObjects]objectAtIndex:indexPath.row];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    titleLabel.font = kRevTitleFont;
	titleLabel.text = item.title;
	UILabel *subtitleLabel= (UILabel *)[cell viewWithTag:101];
    subtitleLabel.font = kRegFont;
	subtitleLabel.text = item.sub_title;
    UILabel *sourceLabel= (UILabel *)[cell viewWithTag:102];
	sourceLabel.text = item.source;
    sourceLabel.font = kRegFont;        
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    FoodItem* selectedGSObj = [[self.foodplace.items allObjects]objectAtIndex:indexPath.row];
    if (!self.reachable){
            // Not reachable
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone" bundle: nil];
            ShopDetailViewController* shopVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ShopDetail"];
            shopVC.gsObject = selectedGSObj;
            [self.navigationController pushViewController:shopVC animated:YES];
        } else {
            // Reachable
            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",selectedGSObj.link]];
            SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
            webViewController.gsobj = selectedGSObj;
            //webViewController.currentLocation = self.userLocation;
            [self.navigationController pushViewController:webViewController animated:YES];

        }
}

- (void)viewDidUnload {
    [self setReviewTable:nil];
    [super viewDidUnload];
}
-(void)didSelectMap:(id)sender
{
    NSLog(@"did select map");
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone"
                                                             bundle: nil];
    ItemMapViewController* shopVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ItemMap"];
    NSLog(@"make %@",shopVC);
    shopVC.foodplace = self.foodplace;
    shopVC.userLocation= self.userLocation;
    [self.navigationController pushViewController:shopVC animated:YES];

}
-(void)didSelectImage:(id)sender
{
    if (((UIImageView*)((UITapGestureRecognizer*)sender).view).image != nil && ((UIImageView*)((UITapGestureRecognizer*)sender).view).image != [UIImage imageNamed:@"placeholder"]) {
        CGRect startRect = [((UIImageView*)((UITapGestureRecognizer*)sender).view) convertRect:self.view.bounds toView:nil];
        self.fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.fullScreenButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9]];
        [self.fullScreenButton setFrame:CGRectMake(startRect.origin.x, startRect.origin.y-90.0f, 80.0f, 80.0f)];
        UIImageView* newImageView = [[UIImageView alloc]initWithFrame:self.fullScreenButton.bounds];
        [newImageView setImage:((UIImageView*)((UITapGestureRecognizer*)sender).view).image];
        [newImageView setContentMode:UIViewContentModeScaleAspectFit];
        [newImageView setUserInteractionEnabled:NO];
        [self.fullScreenButton addSubview:newImageView];
        [self.view addSubview:self.fullScreenButton];
        [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.fullScreenButton.frame = self.view.bounds;
                         newImageView.frame = self.view.bounds;
                     } 
                     completion:^(BOOL finished){
                         [self.fullScreenButton addTarget:self action:@selector(dismissSelf:) forControlEvents:UIControlEventTouchUpInside];
                         [self hideBackAndActionButtons];
                     }];
    }

}
-(void)dismissSelf:(UIButton*) sender
{
    [self revealBackAndActionButtons];
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
-(void)revealBackAndActionButtons
{
    UIImage *actionButton = [[UIImage imageNamed:@"action.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    UIButton* barbuttonitem = [UIButton buttonWithType:UIButtonTypeCustom];
    barbuttonitem.frame = CGRectMake(0.0, 0.0, actionButton.size.width, actionButton.size.height);
    
    [barbuttonitem setBackgroundImage:actionButton forState:UIControlStateNormal];
    [barbuttonitem addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barbutton = [[UIBarButtonItem alloc]initWithCustomView:barbuttonitem];
    self.navigationItem.rightBarButtonItem = barbutton;
    self.navigationItem.hidesBackButton = NO;

}
-(void)hideBackAndActionButtons
{
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [self.headerPageControl setCurrentPage:scrollView.contentOffset.x/scrollView.bounds.size.width];
    if (self.headerPageControl.currentPage == 2)
    {
        //location

        FoodItem* item = [[self.foodplace.items allObjects] lastObject];
        if (item.location_string.length>0) {
            [self.headerLabel setText:item.location_string];
            [self.headerLabel setFont:kRevTitleFont];
        }        
    }else if (self.headerPageControl.currentPage==1)
    {
        [self.headerLabel setText:self.foodplace.title];
        [self.headerLabel setFont:kTitleFont];
    }else if(self.headerPageControl.currentPage==0)
    {
        if (self.userStarView.userRating<20.0f) {
            [self.headerLabel setText:@"Touch To Rate!"];
        }else if (self.userStarView.userRating>=20.0f && self.userStarView.userRating<40.0f ){
                [self.headerLabel setText:@"Dont Like it."];
        }else if (self.userStarView.userRating>=40.0f && self.userStarView.userRating<60.0f ){
                [self.headerLabel setText:@"Its Average."];
        }else if (self.userStarView.userRating>=60.0f && self.userStarView.userRating<80.0f ){
                [self.headerLabel setText:@"You Like it."];
        }else if (self.userStarView.userRating>=80.0f && self.userStarView.userRating<100.0f ){
                [self.headerLabel setText:@"You Love it!"];
        }else if (self.userStarView.userRating>=100.0f){
            [self.headerLabel setText:@"Super Shiok!"];
        }
        [self.headerLabel setFont:kTitleFont];        
    }
    return;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(self.headerPageControl.currentPage==0)
    {
        if (self.userStarView.userRating<20.0f) {
            [self.headerLabel setText:@"Touch To Rate!"];
        }else if (self.userStarView.userRating>=20.0f && self.userStarView.userRating<40.0f ){
            [self.headerLabel setText:@"Dont Like it."];
        }else if (self.userStarView.userRating>=40.0f && self.userStarView.userRating<60.0f ){
            [self.headerLabel setText:@"Its Average."];
        }else if (self.userStarView.userRating>=60.0f && self.userStarView.userRating<80.0f ){
            [self.headerLabel setText:@"You Like it."];
        }else if (self.userStarView.userRating>=80.0f && self.userStarView.userRating<100.0f ){
            [self.headerLabel setText:@"You Love it!"];
        }else if (self.userStarView.userRating>=100.0f){
            [self.headerLabel setText:@"Super Shiok!"];
        }
        [self.headerLabel setFont:kTitleFont];
    }
}
@end
