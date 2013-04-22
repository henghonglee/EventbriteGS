//
//  FoodPlaceViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 30/3/13.
//
//

#import <UIKit/UIKit.h>
#import "FoodPlace.h"
#import "HHStarView.h"
#import "Reachability.h"
@interface FoodPlaceViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) Reachability* reach;
@property dispatch_queue_t GSdataSerialQueue;
@property (nonatomic) BOOL reachable;
@property (nonatomic, strong)FoodPlace* foodplace;
@property (nonatomic, strong)NSManagedObjectContext* dataContext;
@property (weak, nonatomic) UITableView *reviewTable;
@property (nonatomic,strong) UIButton* fullScreenButton;
@property (nonatomic,strong)UIPageControl* headerPageControl;
@property (nonatomic,strong) MKUserLocation* userLocation;
@property (nonatomic,strong) UILabel* headerLabel;
@property (nonatomic,strong) HHStarView* userStarView;
@property (nonatomic,strong) HHStarView* pubStarView;
@end
