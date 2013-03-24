//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController
#import "ShopDetailViewController.h"
#import "Flurry.h"
#import "MapSearchViewController.h"
#import "ShopDetailViewController.h"
#import "CorrectionViewController.h"
#import "SVWebViewController.h"
#import "GeoScrollViewController.h"
#import "MapNavViewController.h"
#import "MobclixAds.h"
#import "MapSlidingViewController.h"
#import "AppDelegate.h"
@interface SVWebViewController () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong, readonly) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong, readonly) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong, readonly) UIActionSheet *pageActionSheet;
@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, strong) NSURL *URL;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
- (void)updateToolbarItems;
- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end


@implementation SVWebViewController
typedef enum {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;
@synthesize availableActions;
@synthesize gsobj;
@synthesize URL, mainWebView;
@synthesize backBarButtonItem, forwardBarButtonItem, refreshBarButtonItem, stopBarButtonItem, actionBarButtonItem, pageActionSheet;
@synthesize adView;
#pragma mark - setters and getters
static dispatch_once_t onceToken;
- (UIBarButtonItem *)backBarButtonItem {
    
    if (!backBarButtonItem) {
        backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClicked:)];
        backBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		backBarButtonItem.width = 18.0f;
    }
    return backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    
    if (!forwardBarButtonItem) {
        forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goForwardClicked:)];
        forwardBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		forwardBarButtonItem.width = 18.0f;
    }
    return forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    
    if (!refreshBarButtonItem) {
        refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    }
    
    return refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    
    if (!stopBarButtonItem) {
        stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    }
    return stopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    
    if (!actionBarButtonItem) {
        actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return actionBarButtonItem;
}

- (UIActionSheet *)pageActionSheet {
    
    if(!pageActionSheet) {
        pageActionSheet = [[UIActionSheet alloc] 
                        initWithTitle:self.mainWebView.request.URL.absoluteString
                        delegate:self 
                        cancelButtonTitle:nil   
                        destructiveButtonTitle:nil   
                        otherButtonTitles:nil]; 

        if((self.availableActions & SVWebViewControllerAvailableActionsCopyLink) == SVWebViewControllerAvailableActionsCopyLink)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Copy Link", @"")];
        
        if((self.availableActions & SVWebViewControllerAvailableActionsOpenInSafari) == SVWebViewControllerAvailableActionsOpenInSafari)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
        
        if([MFMailComposeViewController canSendMail] && (self.availableActions & SVWebViewControllerAvailableActionsMailLink) == SVWebViewControllerAvailableActionsMailLink)
            [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Mail Link to this Page", @"")];
        
        [pageActionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
        pageActionSheet.cancelButtonIndex = [self.pageActionSheet numberOfButtons]-1;
    }
    
    return pageActionSheet;
}

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL {
    
    if(self = [super init]) {
        self.URL = pageURL;
        self.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsMailLink;
    }
    
    return self;
}

#pragma mark - View lifecycle
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)loadView {
//    self.topButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    self.topButton.frame = CGRectMake(0, 0, 320,44);
//    self.topButton.hidden = NO;
//    [self.topButton addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
//    [self.topButton setTitle:@"Bring Me There" forState:UIControlStateNormal];
    UIView* view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];

    mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    mainWebView.delegate = self;
    mainWebView.scalesPageToFit = YES;
    [mainWebView.scrollView setDelegate:self];
    [mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    [mainWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

    self.view = view;
    [self.view addGestureRecognizer:swipeGesture];    
    [self.view addSubview:mainWebView];
//    [self.view addSubview:self.topButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
//    ScrollDirection scrollDirection = ScrollDirectionDown;
//    if (self.lastContentOffset > mainWebView.scrollView.contentOffset.y)
//        scrollDirection = ScrollDirectionUp;
//    else if (self.lastContentOffset < mainWebView.scrollView.contentOffset.y)
//        scrollDirection = ScrollDirectionDown;
//    
//    self.lastContentOffset = mainWebView.scrollView.contentOffset.y;
//    if (self.lastContentOffset>44) {
//    
//    // do whatever you need to with scrollDirection here.
//    switch (scrollDirection) {
//        case ScrollDirectionUp:
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
//            break;
//        case ScrollDirectionDown:
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
//            break;
//            
//        default:
//            break;
//            
//    }
//    }else{
//          self.topButton.frame = CGRectMake(00, 0, 320, 44);
//    }
}

- (void)viewDidLoad {
	[super viewDidLoad];
    onceToken = 0;
    self.isLoading = YES;
    UIImage *actionButton = [[UIImage imageNamed:@"action.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    UIButton* barbuttonitem = [UIButton buttonWithType:UIButtonTypeCustom];
    barbuttonitem.frame = CGRectMake(0.0, 0.0, actionButton.size.width, actionButton.size.height);

    [barbuttonitem setBackgroundImage:actionButton forState:UIControlStateNormal];
    [barbuttonitem addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barbutton = [[UIBarButtonItem alloc]initWithCustomView:barbuttonitem];
    self.navigationItem.rightBarButtonItem = barbutton;
    
    self.adView = [[MobclixAdViewiPhone_320x50 alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-114+60.0f, self.view.bounds.size.width, 50.0f)];
    self.adView.hidden = YES;
    [self.adView setDelegate:self];
    [self.adView setClipsToBounds:NO];
    UIButton* closeAdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeAdButton setFrame:CGRectMake(270, -10 , 50, 50)];
    [closeAdButton setBackgroundImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
    [closeAdButton addTarget:self action:@selector(closeAd) forControlEvents:UIControlEventTouchUpInside];
    [self.adView addSubview:closeAdButton];
	[self.view addSubview:self.adView];
}
-(void)adViewDidFinishLoad:(MobclixAdView *)adView
{
    CGRect slideViewFinalFrame = CGRectMake(0,self.view.bounds.size.height-50, self.view.bounds.size.width, 50.0f);
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.adView.frame = slideViewFinalFrame;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
    
}
-(void)closeMessage:(UIButton*)sender
{
        CGRect slideViewFinalFrame = CGRectMake(0,-44.0f, self.view.bounds.size.width, 44.0f);
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             sender.superview.frame = slideViewFinalFrame;
                         }
                         completion:^(BOOL finished){
                             [sender.superview removeFromSuperview];
                             [sender removeFromSuperview];
                         }];
}
-(void)displayMessage
{
    UIView* displayView = [[UIView alloc]initWithFrame:CGRectMake(0,-44.0f, self.view.bounds.size.width, 44.0f)];
    UILabel* displayLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width-30, 44.0f)];
    [displayLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [displayLabel setNumberOfLines:0];
    [displayLabel setText:@"we saved this post so that you can read it offline later"];
    [displayLabel setTextColor:[UIColor whiteColor]];
    [displayLabel setBackgroundColor:[UIColor clearColor]];
    [displayView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(closeMessage:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [displayView addSubview:displayLabel];
    [displayView addSubview:closeButton];
    [displayView setClipsToBounds:NO];
    [displayView setAutoresizesSubviews:YES];
    displayView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.navigationController.view addSubview:displayView];
    CGRect slideViewFinalFrame = CGRectMake(0,0, self.view.bounds.size.width, 44.0f);
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         displayView.frame = slideViewFinalFrame;
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
}
-(void)closeAd
{
    CGRect slideViewFinalFrame = CGRectMake(0,self.view.bounds.size.height+80, self.view.bounds.size.width, 50.0f);
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.adView.frame = slideViewFinalFrame;
                     }
                     completion:^(BOOL finished){
                         [self.adView pauseAdAutoRefresh];
                         [self.adView cancelAd];
                         [self.adView removeFromSuperview];
                         self.adView = nil;
                     }];

}
-(void) showActionSheet
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag as incorrect" otherButtonTitles:@"Read Offline",@"Directions",@"Email To Friend",@"SMS To Friend", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    [actionSheet showInView:self.view];

    
}

-(void)clearFaces
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"Loading"];
    });
   
    NSLog(@"looking for face in %@ images .. ",gsobj.title);
    for (int i=0; i<gsobj.imageArray.count; i++) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        [manager downloadWithURL:[NSURL URLWithString:[gsobj.imageArray objectAtIndex:i]]
                        delegate:self
                         options:0
                         success:^(UIImage *image, BOOL cached) {
                             NSLog(@"got image, processing now...");
                             if (i == gsobj.imageArray.count-1) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [SVProgressHUD dismiss];
                                 });
                             }
                             CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
                             CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                                       context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
                             NSArray* features = [detector featuresInImage:ciimage];
                             
                             if (features.count >0)
                             {
                                 NSLog(@"face found for %@ at %d",gsobj.title,gsobj.itemId.intValue);
                                 NSURL *tokenurl = [NSURL URLWithString:@"http://tastebudsapp.herokuapp.com"];
                                 AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
                                 [afclient putPath:[NSString stringWithFormat:@"/items/%d",gsobj.itemId.intValue] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",i],@"delete", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     NSLog(@"afhttp update success");
                                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                     NSLog(@"afhttp update failed");
                                 }];
                                 
                             }else{
                                 NSLog(@"didnt find any faces, exiting..%@",gsobj.title);
                             }
                             
                         } failure:nil];
    }

}
-(void)getDirections
{
    NSString* saddr = @"Current+Locaton";
    if([[UIApplication sharedApplication] canOpenURL:
        [NSURL URLWithString:@"comgooglemaps://"]]){
        saddr = [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude];
        NSLog(@"");
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&zoom=14&directionsmode=driving",saddr,[gsobj.locationString stringByReplacingOccurrencesOfString:@" " withString:@"+"]]]];
    }else{
        
        NSString* urlStr;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=6) {
            //iOS 6+, Should use map.apple.com. Current Location doesn't work in iOS 6 . Must provide the coordinate.
            if ((self.currentLocation.coordinate.latitude != kCLLocationCoordinate2DInvalid.latitude) && (self.currentLocation.coordinate.longitude != kCLLocationCoordinate2DInvalid.longitude)) {
                //Valid location.
                saddr = [NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude];
                urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@", saddr, [gsobj.locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            } else {
                //Invalid location. Location Service disabled.
                urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%@", [gsobj.locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        } else {
            // < iOS 6. Use maps.google.com
            urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@", saddr, [gsobj.locationString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
    }
    
    
}
-(void)goOffline
{
//    UIViewController*viewController = [[UIViewController alloc] init];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Directions"]) {
        [self getDirections];
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Suggest Changes"]) {
        [Flurry logEvent:@"Suggest_Changes" timed:NO];
        MapSearchViewController* viewController = [[UIStoryboard storyboardWithName:@"iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"MapSearch"];
        viewController.gsobj = self.gsobj;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Stall Closed"]) {
        NSURL *tokenurl = [NSURL URLWithString:@"http://tastebudsapp.herokuapp.com"];
        AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
        [afclient putPath:[NSString stringWithFormat:@"/items/%d",self.gsobj.itemId.intValue] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"item[is_post]", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
        
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Read Offline"]) {
        //[self clearFaces];
        [self showShopDetailView];
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Email To Friend"]) {
        [Flurry logEvent:@"EmailtoFriend" timed:NO];                                    
        NSURL *tokenurl = [NSURL URLWithString:@"https://api-ssl.bitly.com"];
        AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
        [afclient getPath:[NSString stringWithFormat:@"/v3/shorten?access_token=53cab9bedd220deabf7b15a8882cb6164471075c&longUrl=%@",[gsobj.link stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] parameters:[NSDictionary dictionaryWithObjectsAndKeys:nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSError* error = nil;
            NSDictionary *item = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            
            MFMailComposeViewController*controller = [[MFMailComposeViewController alloc] init];
            if([MFMailComposeViewController canSendMail])
            {
                [controller setSubject:@"TasteBuds"];
                [controller setMessageBody:[NSString stringWithFormat:@"Hey, lets go try this place %@ \n\n Shared using Tastebuds for iOS: Get the app at %@",[[item objectForKey:@"data"] objectForKey:@"url"],@"<itunes link>"]isHTML:NO];

                controller.mailComposeDelegate = self;
                [self presentModalViewController:controller animated:YES];
            }
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"SMS To Friend"]) {
        [Flurry logEvent:@"SMStoFriend" timed:NO];

        NSURL *tokenurl = [NSURL URLWithString:@"https://api-ssl.bitly.com"];
        AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
        [afclient getPath:[NSString stringWithFormat:@"/v3/shorten?access_token=53cab9bedd220deabf7b15a8882cb6164471075c&longUrl=%@",[gsobj.link stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] parameters:[NSDictionary dictionaryWithObjectsAndKeys:nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {


            NSError* error = nil;
            NSDictionary *item = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];

                    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                    if([MFMessageComposeViewController canSendText])
                    {
                        controller.body = [NSString stringWithFormat:@"Hey, lets go try this place %@ \n\n Shared using Tastebuds for iOS: Get the app at %@",[[item objectForKey:@"data"] objectForKey:@"url"],@"<itunes link>"];
                        controller.recipients = @[];
                        controller.messageComposeDelegate = self;
                        [self presentModalViewController:controller animated:YES];
                    }
            
         
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];

        
        
    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{

}
-(void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}
-(void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}



- (void)viewDidUnload {
    [super viewDidUnload];
    mainWebView = nil;
    backBarButtonItem = nil;
    forwardBarButtonItem = nil;
    refreshBarButtonItem = nil;
    stopBarButtonItem = nil;
    actionBarButtonItem = nil;
    pageActionSheet = nil;
    self.adView.delegate = nil;
	self.adView = nil;
}
-(void)backButtonAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    if (self.isLoading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading"];
        });
    }
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
//    UIButton* barbutton = [UIButton buttonWithType:UIButtonTypeCustom];

//    [barbutton setBackgroundImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
//    [barbutton setFrame:CGRectMake(-10, 0, 60, 44)];
//    barbutton.clipsToBounds = NO;
//    [barbutton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:barbutton];
	[super viewWillAppear:animated];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
  //      [self.navigationController setToolbarHidden:NO animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        [[self navigationController] setNavigationBarHidden:YES animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    [self.adView pauseAdAutoRefresh];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        
    });
}
-(void)viewDidAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.adView resumeAdAutoRefresh];
}
- (void)viewDidDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)dealloc
{
    [self.adView cancelAd];
	self.adView.delegate = nil;
	self.adView = nil;
    [mainWebView stopLoading];
 	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    mainWebView.delegate = nil;
}

#pragma mark - Toolbar

- (void)updateToolbarItems {
   }

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    webViewLoads_++;
    self.isLoading = YES;
//    [self updateToolbarItems];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webView == mainWebView) {
        webViewLoads_--;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        if (webViewLoads_ > 0) {
            return;
        }
        self.isLoading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_once(&onceToken, ^{
               // [self displayMessage];
            });
            
        });
    }
//    [self updateToolbarItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"stopped loading");    
    webViewLoads_--;
//    [self updateToolbarItems];
}

#pragma mark - Target actions

- (void)goBackClicked:(UIBarButtonItem *)sender {
    [mainWebView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender {
    [mainWebView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender {
    [mainWebView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender {
    [mainWebView stopLoading];
//	[self updateToolbarItems];
}

- (void)actionButtonClicked:(id)sender {
    
    if(pageActionSheet)
        return;
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.pageActionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
    else
        [self.pageActionSheet showFromToolbar:self.navigationController.toolbar];
    
}

- (void)doneButtonClicked:(id)sender {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    [self dismissModalViewControllerAnimated:YES];
#else
    [self dismissViewControllerAnimated:YES completion:NULL];
#endif
}

#pragma mark -
#pragma mark UIActionSheetDelegate

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
//    
//	if([title isEqualToString:NSLocalizedString(@"Open in Safari", @"")])
//        [[UIApplication sharedApplication] openURL:self.mainWebView.request.URL];
//    
//    if([title isEqualToString:NSLocalizedString(@"Copy Link", @"")]) {
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        pasteboard.string = self.mainWebView.request.URL.absoluteString;
//    }
//    
//    else if([title isEqualToString:NSLocalizedString(@"Mail Link to this Page", @"")]) {
//        
//		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
//        
//		mailViewController.mailComposeDelegate = self;
//        [mailViewController setSubject:[self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
//  		[mailViewController setMessageBody:self.mainWebView.request.URL.absoluteString isHTML:NO];
//		mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
//        
//#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
//		[self presentModalViewController:mailViewController animated:YES];
//#else
//        [self presentViewController:mailViewController animated:YES completion:NULL];
//#endif
//	}
//    
//    pageActionSheet = nil;
//}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
	[self dismissModalViewControllerAnimated:YES];
#else
    [self dismissViewControllerAnimated:YES completion:NULL];
#endif
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
	[self dismissModalViewControllerAnimated:YES];
#else
    [self dismissViewControllerAnimated:YES completion:NULL];
#endif
}


-(void)showShopDetailView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone"
                                                             bundle: nil];
    ShopDetailViewController* shopVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"ShopDetail"];
    shopVC.gsObject = self.gsobj;
    [self.navigationController pushViewController:shopVC animated:YES];
}

@end
