//
//  MenuCell.h
//  ECSlidingViewController
//
//  Created by HengHong on 20/1/13.
//
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *indicator;
@property (weak, nonatomic) IBOutlet UIImageView *vView;
@property (weak, nonatomic) IBOutlet UIView *colorBar;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
