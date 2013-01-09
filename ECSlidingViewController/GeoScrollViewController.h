//
//  GeoScrollViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "CustomCalloutView.h"
#import "UnderMapViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
typedef enum {
    kScopeTypeLikes,
    kScopeTypeDeals,
    kScopeTypeDistance
} ScopeType;
@interface GeoScrollViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UIScrollViewDelegate,UISearchBarDelegate,UITextFieldDelegate>
{
        MKMapRect oldRegion;
        NSMutableArray *mapAnnotations;
        MKUserLocation* userLocation;
        NSMutableArray *loadedGSObjectArray;
        ScopeType currentScopeType;
}
@property (nonatomic,strong) UIView* coverView;
@property (nonatomic,strong) NSString* currentSearch;
@property (nonatomic,strong) NSMutableArray *loadedGSObjectArray;
@property (nonatomic,strong) NSMutableArray *GSObjectArray;
@property (strong, nonatomic) UITableView *tableView;
-(void)didScrollToEntryAtIndex:(int)idx;
-(void)didReceiveUserLocation:(MKUserLocation*)location;
-(void)LoadData;
@end
