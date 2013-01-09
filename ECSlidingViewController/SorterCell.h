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
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) FirstTopViewController* parentViewController;
@end
