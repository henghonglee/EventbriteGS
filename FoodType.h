//
//  FoodType.h
//  ECSlidingViewController
//
//  Created by HengHong on 17/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodItem;

@interface FoodType : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) FoodItem *info;

@end
