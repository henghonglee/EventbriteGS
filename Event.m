//
//  Event.m
//  EventBriteGS
//
//  Created by HengHong on 26/4/13.
//
//

#import "Event.h"
#import <CoreLocation/CoreLocation.h>

@implementation Event

@dynamic logo_url;
@dynamic item_id;
@dynamic category;
@dynamic title;
@dynamic start_date;
@dynamic status;
@dynamic descriptionHTML;
@dynamic capacity;
@dynamic end_date;
@dynamic tags;
@dynamic created;
@dynamic url;
@dynamic modified;
@dynamic repeats;
@dynamic logo_ssl;
@dynamic venue_city;
@dynamic venue_name;
@dynamic venue_country;
@dynamic longitude;
@dynamic latitude;
@dynamic venue_address;
@dynamic venue_postal;
@dynamic cell_height;
- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    
    theCoordinate.latitude =   self.latitude.doubleValue;
    theCoordinate.longitude = self.longitude.doubleValue;
    return theCoordinate;
}

@end
