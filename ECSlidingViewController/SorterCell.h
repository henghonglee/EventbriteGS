//
//  SorterCell.h
//  ECSlidingViewController
//
//  Created by HengHong on 13/11/12.
//
//

#import <UIKit/UIKit.h>
#import "FirstTopViewController.h"


@interface SorterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *sorterBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) FirstTopViewController* parentViewController;
@property (weak, nonatomic) IBOutlet UIView *randomContainer;
@property (weak, nonatomic) IBOutlet UIButton *randomButton;
@end
