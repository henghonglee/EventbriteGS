//
//  FoodPlace.h
//  ECSlidingViewController
//
//  Created by HengHong on 30/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodItem;

@interface FoodPlace : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * current_rating;
@property (nonatomic, retain) NSString * foursquare_venue;
@property (nonatomic, retain) NSNumber * item_id;
@property (nonatomic, retain) NSSet *items;
@end

@interface FoodPlace (CoreDataGeneratedAccessors)

- (void)addItemsObject:(FoodItem *)value;
- (void)removeItemsObject:(FoodItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
