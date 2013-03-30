//
//  GeoScrollViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//
#import "FoodItem.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "CustomCalloutView.h"
#import "UnderMapViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MTStatusBarOverlay.h"
#import "SearchViewController.h"
#import <CoreImage/CoreImage.h>
typedef enum {
    kScopeTypeLikes,
    kScopeTypeDeals,
    kScopeTypeDistance
} ScopeType;
@interface GeoScrollViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UIScrollViewDelegate,UISearchBarDelegate,UITextFieldDelegate,SearchViewControllerDelegate>
{
        MKMapRect oldRegion;
        NSMutableArray *mapAnnotations;
        MKUserLocation* userLocation;
        NSMutableArray *loadedGSObjectArray;
        NSMutableArray *scopedGSObjectArray;
        ScopeType currentScopeType;
        dispatch_queue_t GSserialQueue;
        dispatch_queue_t GSdataSerialQueue;
}
@property (readonly, strong, nonatomic) NSManagedObjectContext *dataManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *dataManagedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *dataPersistentStoreCoordinator;


@property (weak, nonatomic) IBOutlet UIButton *resetTopViewButton;
@property (nonatomic) BOOL random;
@property (nonatomic) BOOL canSearch;
@property (nonatomic) int randomIndex;
@property (nonatomic) float alphaValue;
@property (nonatomic,strong)UIButton*fullscreenButton;
@property (nonatomic,strong)FoodItem* selectedGsObject;
@property (nonatomic,strong)UITextField* searchTextField;
@property (nonatomic, strong) CLLocation *shouldZoomToLocation;
@property (weak, nonatomic) IBOutlet UITableView *imageTableView;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic) BOOL selectionChanged;
@property (nonatomic,strong) MKUserLocation* userLocation;
@property (nonatomic, strong)NSMutableDictionary* boolhash;
@property (nonatomic,strong) UIView* coverView;
@property (nonatomic,strong) NSString* currentSearch;
@property (nonatomic,strong) NSMutableArray *ongoingRequests;

@property (nonatomic,strong) NSMutableArray *loadedGSObjectArray;
@property (nonatomic,strong) NSMutableArray *GSObjectArray;
@property (nonatomic,strong) NSMutableArray *scopedGSObjectArray;
@property (strong, nonatomic) UITableView *tableView;
-(void)didScrollToEntryAtIndex:(int)idx;
-(void)didReceiveUserLocation:(MKUserLocation*)location;
-(void)LoadData;
-(void)didTouchMapAtCoordinate:(CLLocationCoordinate2D)mapTouchCoordinate;
-(void)hintLeft;
-(void)hintRight;
-(void)getDirectionsToSelectedGSObj;

@end
