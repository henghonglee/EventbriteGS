//
//  GSObject.h
//  SDWebImage Demo
//
//  Created by HengHong on 9/11/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface GSObject : NSObject <MKAnnotation>
{
    NSString *title;
    NSString *subTitle;
    NSString *description;
    NSString *descriptionhtml;
    NSString *coverurl;
    NSString *mainImageLink;
    NSString *mainImage;
    NSString *objectID;
    NSString* logourl;
    NSString* source;
    NSNumber* distanceInMeters;
    NSNumber *likes;
    NSNumber *shopScore;
    NSNumber *cellHeight;
    NSNumber *latitude;
    NSNumber *longitude;
    UIColor* cursorColor;
    NSArray* imageArray;
    
}
@property (nonatomic, strong)  NSString* source;
@property (nonatomic, strong)  NSString* descriptionhtml;
@property (nonatomic, strong)  UIColor* cursorColor;
@property (nonatomic, strong)  NSArray* imageArray;
@property (nonatomic, strong)  NSNumber* distanceInMeters;
@property (nonatomic, strong)  NSNumber *likes;
@property (nonatomic, strong)  NSNumber *shopScore;
@property (nonatomic, strong)  NSNumber *latitude;
@property (nonatomic, strong)  NSNumber *longitude;
@property (nonatomic, strong)  NSNumber *cellHeight;
@property (nonatomic, strong)  NSNumber *dealCount;
@property (nonatomic, strong)  NSString*title;
@property (nonatomic, strong)  NSString*logourl;
@property (nonatomic, strong)  NSString*subTitle;
@property (nonatomic, strong)  NSString*description;
@property (nonatomic, strong)  NSString*coverurl;
@property (nonatomic, strong)  NSString*mainImageLink;
@property (nonatomic, strong)  NSString*mainImage;
@property (nonatomic, strong)  NSString*objectID;
@property (nonatomic, strong)  NSString*addressString;
@property (nonatomic, strong)  NSString *openingHoursString;
@property (nonatomic, strong)  NSNumber *wereHere;
@property (nonatomic, strong)  NSString *phoneNumber;
//@property (nonatomic, strong)  NSString*addressString;

@end
