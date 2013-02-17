//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <MessageUI/MessageUI.h>

#import "SVModalWebViewController.h"
#import "GSObject.h"
@interface SVWebViewController : UIViewController <UIActionSheetDelegate>

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;
@property (nonatomic, strong) GSObject* gsobj;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;

@end
