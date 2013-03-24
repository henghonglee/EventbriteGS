//
//  FoodImage.h
//  ECSlidingViewController
//
//  Created by HengHong on 17/3/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodItem;

@interface FoodImage : NSManagedObject

@property (nonatomic, retain) NSString * high_res_image;
@property (nonatomic, retain) NSString * low_res_image;
@property (nonatomic, retain) NSString * mid_res_image;
@property (nonatomic, retain) FoodItem *info;

@end
