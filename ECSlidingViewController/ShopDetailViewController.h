//
//  ShopDetailViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 14/11/12.
//
//
#import <SDWebImage/SDWebImageManager.h>
#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "GSObject.h"
@interface ShopDetailViewController : UIViewController

@property (strong, nonatomic) UIWebView *descriptionWebView;
@property (strong,nonatomic) GSObject* gsObject;


@end
