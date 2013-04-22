//
//  ItemMapViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 18/4/13.
//
//

#import <UIKit/UIKit.h>
#import "FoodPlace.h"
#import <MapKit/MapKit.h>
@interface ItemMapViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) FoodPlace* foodplace;
@property (nonatomic,strong) MKUserLocation* userLocation;
@end
