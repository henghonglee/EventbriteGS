//
//  FoodPlaceViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 30/3/13.
//
//

#import <UIKit/UIKit.h>
#import "FoodPlace.h"
@interface FoodPlaceViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *CoverImage;
@property (nonatomic, strong)FoodPlace* foodplace;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *reviewTable;
@end
