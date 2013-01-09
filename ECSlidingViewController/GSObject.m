//
//  GSObject.m
//  SDWebImage Demo
//
//  Created by HengHong on 9/11/12.
//  Copyright (c) 2012 Dailymotion. All rights reserved.
//

#import "GSObject.h"

@implementation GSObject
@synthesize cursorColor;
@synthesize source;
@synthesize descriptionhtml;
@synthesize latitude;
@synthesize longitude;
@synthesize title;
@synthesize subTitle;
@synthesize description;
@synthesize coverurl;
@synthesize mainImageLink;
@synthesize mainImage;
@synthesize logourl;
@synthesize shopScore;
@synthesize objectID;
@synthesize cellHeight;
@synthesize likes;
@synthesize dealCount;
@synthesize distanceInMeters;
@synthesize imageArray;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}
- (NSString *)subtitle
{
    return subTitle;
}
- (NSString *)title
{
    return title;
}
- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    
    theCoordinate.latitude = latitude.doubleValue;
    theCoordinate.longitude = longitude.doubleValue;
    return theCoordinate;
}


@end
