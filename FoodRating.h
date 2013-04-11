//
//  FoodRating.h
//  ECSlidingViewController
//
//  Created by HengHong on 3/4/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FoodRating : NSManagedObject

@property (nonatomic, retain) NSNumber * item_id;
@property (nonatomic, retain) NSNumber * place_id;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSDate * uploaded_at;

@end
