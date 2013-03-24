//
//  LoadingViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 22/3/13.
//
//

#import <UIKit/UIKit.h>

@interface LoadingViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *tbLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *instructionScrollView;
@property (nonatomic, strong) NSArray* imageNameArray;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSTimer* timer;
@end
