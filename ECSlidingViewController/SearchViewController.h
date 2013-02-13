//
//  SearchViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 24/1/13.
//
//

#import <UIKit/UIKit.h>
#import "Trie.h"
@protocol SearchViewControllerDelegate;

@interface SearchViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    dispatch_queue_t serialQueue;
}

typedef enum {
    kStateSelectingLocation = 0,
    kStateSelectingFood = 1
}SearchState;
@property (nonatomic, assign) id<SearchViewControllerDelegate> delegate;
@property (nonatomic) int searchState;
@property (nonatomic , strong) NSString* finalSearchString;
@property (weak, nonatomic) IBOutlet UITableView *rsTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (nonatomic) MKCoordinateRegion searchRegion;
@property (nonatomic,strong)NSArray* initialArray;
@property (nonatomic,strong)NSMutableArray* resultList;
@property (nonatomic,strong)NSMutableArray* shopResultList;
@property (nonatomic,strong)NSMutableArray* dataArray;
@property (nonatomic,strong)NSArray* suggestedLocations;
@property (weak, nonatomic) IBOutlet MKMapView *underMapView;
@property (nonatomic,strong)NSMutableDictionary* suggestedFood;
@end
@protocol SearchViewControllerDelegate <NSObject>

- (void)searchViewControllerDidFinishWithSearchString:(NSString*)searchString;

@end