//
//  SorterCell.h
//  ECSlidingViewController
//
//  Created by HengHong on 13/11/12.
//
//

#import <UIKit/UIKit.h>



@interface SorterCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *sorterBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;


@end
