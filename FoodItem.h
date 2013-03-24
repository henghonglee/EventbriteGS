//
//  FoodItem.h
//  ECSlidingViewController
//
//  Created by HengHong on 17/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodDescription, FoodImage, FoodType;

@interface FoodItem : NSManagedObject

@property (nonatomic, retain) NSNumber * cell_height;
@property (nonatomic, retain) NSNumber * distance_in_meters;
@property (nonatomic, retain) NSString * foursquare_venue;
@property (nonatomic, retain) NSNumber * is_post;
@property (nonatomic, retain) NSNumber * item_id;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * location_string;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * sub_title;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) FoodDescription *descriptionHTML;
@property (nonatomic, retain) NSSet *foodtypes;
@property (nonatomic, retain) NSSet *images;
@end

@interface FoodItem (CoreDataGeneratedAccessors)

- (void)addFoodtypesObject:(FoodType *)value;
- (void)removeFoodtypesObject:(FoodType *)value;
- (void)addFoodtypes:(NSSet *)values;
- (void)removeFoodtypes:(NSSet *)values;

- (void)addImagesObject:(FoodImage *)value;
- (void)removeImagesObject:(FoodImage *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
