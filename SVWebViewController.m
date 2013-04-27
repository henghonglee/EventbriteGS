//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController
#import "SVWebViewController.h"
#import "GeoScrollViewController.h"
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
//    UIImage *actionButton = [[UIImage imageNamed:@"action.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
//    UIButton* barbuttonitem = [UIButton buttonWithType:UIButtonTypeCustom];
//    barbuttonitem.frame = CGRectMake(0.0, 0.0, actionButton.size.width, actionButton.size.height);
//
//    [barbuttonitem setBackgroundImage:actionButton forState:UIControlStateNormal];
//    [barbuttonitem addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem* barbutton = [[UIBarButtonItem alloc]initWithCustomView:barbuttonitem];
//    self.navigationItem.rightBarButtonItem = barbutton;

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

-(void) showActionSheet
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Read Offline",@"Email To Friend",@"SMS To Friend", nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    [actionSheet showInView:self.view];

    
}
/*
-(void)clearFaces
{
    dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
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
*/
-(void)goOffline
{
//    UIViewController*viewController = [[UIViewController alloc] init];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
 
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
            [SVProgressHUD showWithStatus:@""];
        });
    }
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
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
        [[self navigationController] setNavigationBarHidden:NO animated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        
    });
}
-(void)viewDidAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];

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




@end
