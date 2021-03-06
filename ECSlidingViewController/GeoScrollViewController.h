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

#import "UnderMapViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MTStatusBarOverlay.h"
#import <CoreImage/CoreImage.h>


@interface GeoScrollViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UIScrollViewDelegate,UISearchBarDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
        MKMapRect oldRegion;
        NSMutableArray *mapAnnotations;
        MKUserLocation* userLocation;
        NSMutableArray *loadedGSObjectArray;
        NSMutableArray *scopedGSObjectArray;
        dispatch_queue_t GSserialQueue;
        dispatch_queue_t GSdataSerialQueue;
}



@property (strong, nonatomic) NSManagedObjectContext *dataManagedObjectContext;

@property (weak, nonatomic) IBOutlet UIButton *resetTopViewButton;
@property (nonatomic) BOOL random;
@property (nonatomic) BOOL canSearch;
@property (nonatomic) int randomIndex;
@property (nonatomic,strong)UIButton*fullscreenButton;
@property (nonatomic,strong)Event* selectedGsObject;
@property (nonatomic, strong) CLLocation *shouldZoomToLocation;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic) BOOL selectionChanged;
@property (nonatomic,strong) MKUserLocation* userLocation;
@property (nonatomic,strong) NSString* currentSearch;
@property (nonatomic,strong) NSMutableArray *loadedGSObjectArray;
@property (nonatomic,strong) NSMutableArray *GSObjectArray;
@property (nonatomic,strong) NSMutableArray *scopedGSObjectArray;
@property (strong, nonatomic) UITableView *tableView;
-(void)prepareDataForDisplay;
-(void)didScrollToEntryAtIndex:(int)idx;
-(void)didReceiveUserLocation:(MKUserLocation*)location;
-(void)didTouchMapAtCoordinate:(CLLocationCoordinate2D)mapTouchCoordinate;
-(void)getDirectionsToSelectedGSObj;
-(void)didRefreshTable:(id)sender;
@end
