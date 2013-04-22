//
//  FoodPlace.h
//  ECSlidingViewController
//
//  Created by HengHong on 19/4/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
@class FoodImage, FoodItem, FoodRating, FoodType;

@interface FoodPlace : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) NSNumber * cell_height;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * current_rating;
@property (nonatomic, retain) NSNumber * current_user_rated;
@property (nonatomic, retain) NSNumber * distance_in_meters;
@property (nonatomic, retain) NSString * foursquare_venue;
@property (nonatomic, retain) NSNumber * item_id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * rate_count;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSSet *foodtypes;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSSet *ratings;
@end

@interface FoodPlace (CoreDataGeneratedAccessors)

- (void)addFoodtypesObject:(FoodType *)value;
- (void)removeFoodtypesObject:(FoodType *)value;
- (void)addFoodtypes:(NSSet *)values;
- (void)removeFoodtypes:(NSSet *)values;

- (void)addImagesObject:(FoodImage *)value;
- (void)removeImagesObject:(FoodImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addItemsObject:(FoodItem *)value;
- (void)removeItemsObject:(FoodItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addRatingsObject:(FoodRating *)value;
- (void)removeRatingsObject:(FoodRating *)value;
- (void)addRatings:(NSSet *)values;
- (void)removeRatings:(NSSet *)values;

@end
