//
//  FoodImage.h
//  ECSlidingViewController
//
//  Created by HengHong on 19/4/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodItem, FoodPlace;

@interface FoodImage : NSManagedObject

@property (nonatomic, retain) NSString * high_res_image;
@property (nonatomic, retain) NSString * low_res_image;
@property (nonatomic, retain) NSString * mid_res_image;
@property (nonatomic, retain) FoodItem *info;
@property (nonatomic, retain) FoodPlace *place;

@end
