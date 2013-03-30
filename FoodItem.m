//
//  FoodItem.m
//  ECSlidingViewController
//
//  Created by HengHong on 30/3/13.
//
//

#import "FoodItem.h"
#import "FoodDescription.h"
#import "FoodImage.h"
#import "FoodType.h"
#import <CoreLocation/CoreLocation.h>

@implementation FoodItem

@dynamic cell_height;
@dynamic created_at;
@dynamic distance_in_meters;
@dynamic foursquare_venue;
@dynamic is_post;
@dynamic item_id;
@dynamic latitude;
@dynamic link;
@dynamic location_string;
@dynamic longitude;
@dynamic source;
@dynamic sub_title;
@dynamic title;
@dynamic updated_at;
@dynamic descriptionHTML;
@dynamic foodtypes;
@dynamic images;
@dynamic place;

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    
    theCoordinate.latitude =   self.latitude.doubleValue;
    theCoordinate.longitude = self.longitude.doubleValue;
    return theCoordinate;
}
@end
