//
//  Event.h
//  EventBriteGS
//
//  Created by HengHong on 26/4/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface Event : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSString * logo_url;
@property (nonatomic, retain) NSNumber * item_id;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * start_date;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * descriptionHTML;
@property (nonatomic, retain) NSNumber * capacity;
@property (nonatomic, retain) NSDate * end_date;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSDate * modified;
@property (nonatomic, retain) NSNumber * repeats;
@property (nonatomic, retain) NSString * logo_ssl;
@property (nonatomic, retain) NSString * venue_city;
@property (nonatomic, retain) NSString * venue_name;
@property (nonatomic, retain) NSString * venue_country;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * venue_address;
@property (nonatomic, retain) NSString * venue_postal;
@property (nonatomic, retain) NSNumber * cell_height;

@end
