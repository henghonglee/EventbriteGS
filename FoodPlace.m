//
//  FoodPlace.m
//  ECSlidingViewController
//
//  Created by HengHong on 19/4/13.
//
//

#import "FoodPlace.h"
#import "FoodImage.h"
#import "FoodItem.h"
#import "FoodRating.h"
#import "FoodType.h"
#import <CoreLocation/CoreLocation.h>

@implementation FoodPlace

@dynamic cell_height;
@dynamic created_at;
@dynamic current_rating;
@dynamic current_user_rated;
@dynamic distance_in_meters;
@dynamic foursquare_venue;
@dynamic item_id;
@dynamic latitude;
@dynamic longitude;
@dynamic rate_count;
@dynamic title;
@dynamic updated_at;
@dynamic foodtypes;
@dynamic images;
@dynamic items;
@dynamic ratings;
- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    
    theCoordinate.latitude =   self.latitude.doubleValue;
    theCoordinate.longitude = self.longitude.doubleValue;
    return theCoordinate;
}
@end
