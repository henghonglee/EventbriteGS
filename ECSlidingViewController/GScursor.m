//
//  GScursor.m
//  ECSlidingViewController
//
//  Created by HengHong on 13/11/12.
//
//

#import "GScursor.h"

@implementation GScursor
@synthesize latitude,longitude,title,subTitle,likes,description;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}
- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    
    theCoordinate.latitude = latitude.doubleValue;
    theCoordinate.longitude = longitude.doubleValue;
    return theCoordinate;
}

@end
