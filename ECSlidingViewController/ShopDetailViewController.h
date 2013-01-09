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

@property (weak, nonatomic) IBOutlet UIWebView *descriptionWebView;
@property (strong,nonatomic) GSObject* gsObject;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end
