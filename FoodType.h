//
//  FoodType.h
//  ECSlidingViewController
//
//  Created by HengHong on 19/4/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodItem, FoodPlace;

@interface FoodType : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) FoodItem *info;
@property (nonatomic, retain) FoodPlace *place;

@end
