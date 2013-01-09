//
//  GScursor.h
//  ECSlidingViewController
//
//  Created by HengHong on 13/11/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface GScursor : NSObject <MKAnnotation>
{
    NSString *title;
    NSString *subTitle;
    NSString *description;
    NSNumber *latitude;
    NSNumber *longitude;
}
@property (nonatomic, strong)  NSNumber *likes;
@property (nonatomic, strong)  NSNumber *latitude;
@property (nonatomic, strong)  NSNumber *longitude;
@property (nonatomic, strong)  NSString*title;
@property (nonatomic, strong)  NSString*subTitle;
@property (nonatomic, strong)  NSString*description;
@end
