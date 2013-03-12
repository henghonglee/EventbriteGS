//
//  ImageCell.h
//  ECSlidingViewController
//
//  Created by HengHong on 4/3/13.
//
//

#import <UIKit/UIKit.h>

@interface ImageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
