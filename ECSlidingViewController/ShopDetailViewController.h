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
#import "FoodItem.h"
@interface ShopDetailViewController : UIViewController <UIWebViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *descriptionWebView;
@property (strong,nonatomic) FoodItem* gsObject;
@property (weak, nonatomic) IBOutlet UIView *editView;


@end
