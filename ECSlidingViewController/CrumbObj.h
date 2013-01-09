//
//  CrumbObj.h
//  ECSlidingViewController
//
//  Created by HengHong on 7/1/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface CrumbObj : NSObject
@property(nonatomic) MKMapPoint mapPoint;
@property(nonatomic,strong) UIColor* pointColor;

@end
