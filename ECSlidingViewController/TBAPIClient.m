//
//  TBAPIClient.m
//  ECSlidingViewController
//
//  Created by HengHong on 12/4/13.
//
//

#import "TBAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kAFAppDotNetAPIBaseURLString = @"http://tastebudsapp.herokuapp.com/";
//static NSString * const kAFAppDotNetAPIBaseURLString = @"http://192.168.1.9:3000/";
@implementation TBAPIClient

+ (TBAPIClient *)sharedClient {
    static TBAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TBAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAppDotNetAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    //[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	//[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    //[self setDefaultSSLPinningMode:AF];
    
    return self;
}

@end