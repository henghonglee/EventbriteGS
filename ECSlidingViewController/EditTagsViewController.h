//
//  EditTagsViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 19/3/13.
//
//

#import <UIKit/UIKit.h>
#import "GSObject.h"
@interface EditTagsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) GSObject* selectedGSObject;
@property (nonatomic,strong) NSMutableArray* foodtypes;
@property (weak, nonatomic) IBOutlet UITableView *tagTableView;

@end
