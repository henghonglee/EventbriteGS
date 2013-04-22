//
//  HHStarView.m
//  startest
//
//  Created by HengHong on 6/12/12.
//  Copyright (c) 2012 HengHong. All rights reserved.
//
#import "AppDelegate.h"
#import "HHStarView.h"
#import "AFHTTPClient.h"
#import "FoodRating.h"
@implementation HHStarView
@synthesize timer;

@synthesize kLabelAllowance;
@synthesize GSdataSerialQueue;
- (id)initWithFrame:(CGRect)frame andRating:(int)rating withLabel:(BOOL)label animated:(BOOL)animated
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.animated = animated;
        _maxrating = rating;
        //*(self.bounds.size.width-frame.size.height-kLabelAllowance);
        if (self.animated) {
            //_rating = 0;
           // timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(increaseRating) userInfo:nil repeats:YES];
        }else{
            _rating = _maxrating;
         
        }
        if (label) {
            self.kLabelAllowance = 45.0f;
            self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width-kLabelAllowance , 0,kLabelAllowance, frame.size.height-15)];
            self.label.font = [UIFont systemFontOfSize:16.0f];
            self.label.text = [NSString stringWithFormat:@"%d%%",rating];
            self.label.textAlignment = NSTextAlignmentRight;
            self.label.textColor = [UIColor whiteColor];
            self.label.backgroundColor = [UIColor clearColor];
            [self addSubview:self.label];
            self.sublabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width-kLabelAllowance , self.bounds.size.height-15,kLabelAllowance, 15)];
            self.sublabel.font = [UIFont systemFontOfSize:11.0f];
            if (self.foodplace.rate_count.intValue == 1) {
                self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
            }else{
                self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
            }
            self.sublabel.textAlignment = NSTextAlignmentRight;
            self.sublabel.textColor = [UIColor whiteColor];
            self.sublabel.backgroundColor = [UIColor clearColor];
            [self addSubview:self.sublabel];
            
            
        }else{
            self.kLabelAllowance = 0.0f;
        }
        
    }
    return self;
}


-(void)increaseRating
{
    
    if (_rating<_maxrating) {
        _rating = _rating + 1;
        if (self.label) 
            self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
        [self setNeedsDisplay];
    }else{
        [timer invalidate];
    }
}
-(void)starViewSetRating:(int)Rating isUser:(BOOL)isUser isAnimated:(BOOL)isanimated
{
    if (isUser) {
        self.userRating= Rating;
        self.rating = self.userRating;
    }else{
        self.maxrating = Rating;
        self.rating=Rating;
        self.userRating = 0.0f;
        if (isanimated) {
            _rating = 0;
            timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(increaseRating) userInfo:nil repeats:YES];
        }else{
            _rating = _maxrating;
            
        }
    }
    if (self.label) {
        self.label.text = [NSString stringWithFormat:@"%d%%",self.maxrating];
        if (self.foodplace.rate_count.intValue == 1) {
            self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
        }else{
            self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
        }
    }
    [self setNeedsDisplay];
}

-(void)starViewSetRating:(int)Rating isUser:(BOOL)isUser
{
    if (isUser) {
        self.userRating= Rating;
        self.rating = self.userRating;
    }else{
        self.maxrating = Rating;
        self.rating=Rating;
        self.userRating = 0.0f;
    }
    if (self.label) {
        self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
        if (self.foodplace.rate_count.intValue == 1) {
            self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
        }else{
            self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
        }
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    
//    UIImage* image = [UIImage imageNamed:@"5starsgray.png"];
    CGRect newrect = CGRectMake(0, 0, self.bounds.size.width-kLabelAllowance, self.bounds.size.height);
//    [image drawInRect:newrect];
    
    CGContextRef drawcontext = UIGraphicsGetCurrentContext();
    CGContextClipToMask(drawcontext, newrect, [UIImage imageNamed:@"5starflip.png"].CGImage);
    float barWitdhPercentage = (_rating/100.0f) *  (self.bounds.size.width-kLabelAllowance);

    CGContextClipToRect(drawcontext, CGRectMake(0, 0, MIN(self.bounds.size.width,barWitdhPercentage), self.bounds.size.height));
    CGContextSetBlendMode(drawcontext, kCGBlendModeNormal);
    if (self.userRating < 20.0f) {
        [[UIColor yellowColor] setFill];
    }else{
        [[UIColor greenColor] setFill];
    }
    CGContextFillRect(drawcontext, newrect);
}

//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touches moved");
//    if (CGRectContainsPoint(self.bounds, [[[touches allObjects]lastObject] locationInView:self])) {
//        
//        float xpos = [[[touches allObjects]lastObject] locationInView:self].x;
//        int star = MIN(4,xpos/((self.bounds.size.width-kLabelAllowance)/5.0f));
//        self.userRating = (star+1)*20.0f;
//        self.rating = self.userRating;
//        
//        
//        
//        if (self.label) {
//            self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
//        }
//        
//        [self setNeedsDisplay];
//        
//    }
//}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.isSending) {
        return;
    }
    if (CGRectContainsPoint(self.bounds, [[[touches allObjects]lastObject] locationInView:self])) {
        
        float xpos = [[[touches allObjects]lastObject] locationInView:self].x;
        int star = MIN(4,xpos/((self.bounds.size.width-kLabelAllowance)/5.0f));
        self.isSending = YES;
        if (star == 0) {
//            if (self.userRating == 20.0f) {
//                self.userRating = 0.0f;
//                self.rating = self.maxrating;
//            }else{
                self.userRating = (star+1)*20.0f;
                self.rating = self.userRating;
//            }
        }else{
            self.userRating = (star+1)*20.0f;
            self.rating = self.userRating;
        }
        
        if (self.label) {
            self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
            if (self.foodplace.rate_count.intValue == 1) {
                self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
            }else{
                self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
            }
        }
        [self setNeedsDisplay];
        NSDictionary* ratingDict = [NSDictionary dictionaryWithObjectsAndKeys:self.foodplace.item_id,@"place_id",[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] intValue]],@"user_id",[NSNumber numberWithInt:self.userRating],@"score",nil];
        [self addRatingWithDictionary:ratingDict];
        self.isSending = NO;

        
    }
}



-(NSDate*)getGMTDate
{
    NSDate *localDate = [NSDate date];
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    NSTimeInterval gmtTimeInterval = [localDate timeIntervalSinceReferenceDate] - timeZoneOffset;
   return [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];

}



-(void)deleteUserRatingsForStall
{
    if (self.userRating != 0.0f) {
        self.userRating = 0.0f;
        self.rating = self.userRating;
        if (self.label) {
            self.label.text = [NSString stringWithFormat:@"%d%%",self.rating];
            if (self.foodplace.rate_count.intValue == 1) {
                self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
            }else{
                self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
            }
        }
        [self setNeedsDisplay];
        NSDictionary* ratingDict = [NSDictionary dictionaryWithObjectsAndKeys:self.foodplace.item_id,@"place_id",[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] intValue]],@"user_id",[NSNumber numberWithInt:self.userRating],@"score",nil];
        [self addRatingWithDictionary:ratingDict];
        self.isSending = NO;
    }
}

-(void)addRatingWithDictionary:(NSDictionary*)ratingDictionary
{
        NSError* error =nil;
        FoodRating *foodrating = nil;
        NSManagedObjectContext* context = [((AppDelegate* )[UIApplication sharedApplication].delegate) managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.includesPropertyValues = NO;
        request.entity = [NSEntityDescription entityForName:@"FoodRating" inManagedObjectContext:context];
        
        request.predicate = [NSPredicate predicateWithFormat:@"place_id = %d AND user_id = %d", [[ratingDictionary objectForKey:@"place_id"] intValue],[[ratingDictionary objectForKey:@"user_id"] intValue]];
        request.fetchLimit = 1;
        NSError *executeFetchError = nil;
        foodrating = [[context executeFetchRequest:request error:&executeFetchError] lastObject];
        if (executeFetchError) {
        } else if (!foodrating) {
            foodrating = [NSEntityDescription insertNewObjectForEntityForName:@"FoodRating"
                                                       inManagedObjectContext:context];}
        
        NSNumber* prevRating = foodrating.score;
        [foodrating setValue:[self getGMTDate] forKey:@"updated_at"];
        [foodrating setValue:[NSDate distantFuture] forKey:@"uploaded_at"];
        foodrating.place_id = [NSNumber numberWithInt:[[ratingDictionary objectForKey:@"place_id"] intValue]];
        foodrating.user_id = [NSNumber numberWithInt:[[ratingDictionary objectForKey:@"user_id"] intValue]];
        foodrating.score = [NSNumber numberWithInt:[[ratingDictionary objectForKey:@"score"] intValue]];
        
        [self refreshFoodPlaceRatingWithFoodRating:foodrating andContext:context withPrevRating:prevRating];
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }else{
            NSLog(@"saved");
            
        }
        
        
    }


-(void)refreshFoodPlaceRatingWithFoodRating:(FoodRating*)foodrating andContext:(NSManagedObjectContext*)context withPrevRating:(NSNumber*)prevRating
{
//    NSError* executeFetchError = nil;
//    FoodPlace *place = nil;
//    NSFetchRequest *placeRequest = [[NSFetchRequest alloc] init];
//    placeRequest.includesPropertyValues = YES;
//    placeRequest.returnsObjectsAsFaults = NO;
//    placeRequest.entity = [NSEntityDescription entityForName:@"FoodPlace" inManagedObjectContext:context];
//    placeRequest.predicate = [NSPredicate predicateWithFormat:@"item_id = %d", foodrating.place_id.intValue];
//    
//    place = [[context executeFetchRequest:placeRequest error:&executeFetchError] lastObject];
//    if (executeFetchError) {
//        
//    } else if (!place) {
//        NSLog(@"got rating without place");
//        NSAssert(false, @"We've got a rating without a food place ... shouldnt happen");
//    }
    
    BOOL placeIsRated = NO;
    for (FoodRating *placeRating in self.foodplace.ratings) {
        if ([placeRating.item_id isEqualToNumber:foodrating.item_id]) {
            NSLog(@"rating already has foodplace");
            placeIsRated = YES;
        }
    }
    if (!placeIsRated) {
        NSLog(@"adding rating to foodplace");
        float currentTotal = self.foodplace.current_rating.floatValue * self.foodplace.rate_count.intValue;
        currentTotal = currentTotal + foodrating.score.intValue;
        
        [self.foodplace addRatingsObject:foodrating];
        
        [self.foodplace setRate_count:[NSNumber numberWithInt:self.foodplace.rate_count.intValue+1]];
        self.foodplace.current_rating = [NSNumber numberWithInt:(currentTotal/self.foodplace.rate_count.intValue)];
        NSLog(@"setting food place current rating to %d", self.foodplace.current_rating.intValue);
        [self.foodplace setCurrent_user_rated:[NSNumber numberWithBool:YES]];
        if (self.label) {
            if (self.foodplace.rate_count.intValue == 1) {
                self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
            }else{
                self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
            }
        }
        [self setNeedsDisplay];
        return;
    }
    //changing ratings
    float currentTotal = self.foodplace.current_rating.floatValue * self.foodplace.rate_count.intValue;
    currentTotal = currentTotal - prevRating.intValue + foodrating.score.intValue;
    
    if (foodrating.score.intValue == 0) {
        [self.foodplace setRate_count:[NSNumber numberWithInt:self.foodplace.rate_count.intValue-1]];
    }
    else if(prevRating.intValue == 0 ) {
        [self.foodplace setRate_count:[NSNumber numberWithInt:self.foodplace.rate_count.intValue+1]];
    }
    self.foodplace.current_rating = [NSNumber numberWithInt:(currentTotal/self.foodplace.rate_count.intValue)];
    NSLog(@"current rating to %d",self.foodplace.current_rating.intValue );
    if (self.label) {
        if (self.foodplace.rate_count.intValue == 1) {
            self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
        }else{
            self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
        }
    }
    [self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"observer for %d",((HHStarView*)object).foodplace.item_id.intValue);
        NSLog(@"observer change rating to %d",((HHStarView*)object).foodplace.current_rating.intValue );
        [self starViewSetRating:((HHStarView*)object).foodplace.current_rating.intValue isUser:NO];
        if (self.label) {
            if (self.foodplace.rate_count.intValue == 1) {
                self.sublabel.text = [NSString stringWithFormat:@"%d vote",self.foodplace.rate_count.intValue];
            }else{
                self.sublabel.text = [NSString stringWithFormat:@"%d votes",self.foodplace.rate_count.intValue];
            }
        }
        [self setNeedsDisplay];
        
    });
    
}
@end
