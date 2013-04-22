//
//  TBAPIClient.h
//  ECSlidingViewController
//
//  Created by HengHong on 12/4/13.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface TBAPIClient : AFHTTPClient
+ (TBAPIClient *)sharedClient;
@end
