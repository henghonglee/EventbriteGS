//
//  FoodDescription.h
//  ECSlidingViewController
//
//  Created by HengHong on 30/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodItem;

@interface FoodDescription : NSManagedObject

@property (nonatomic, retain) NSString * descriptionHTML;
@property (nonatomic, retain) FoodItem *info;

@end
