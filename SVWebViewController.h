//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <MessageUI/MessageUI.h>
#import "Event.h"
#import "SVModalWebViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface SVWebViewController : UIViewController <UIActionSheetDelegate,UIScrollViewDelegate,MFMessageComposeViewControllerDelegate>
{

    int webViewLoads_;
}
- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

@property (nonatomic, strong) Event* gsobj;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic)float lastContentOffset;
@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;
@property (nonatomic,strong) UIButton* topButton;
@end
