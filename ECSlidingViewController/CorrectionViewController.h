//
//  CorrectionViewController.h
//  ECSlidingViewController
//
//  Created by HengHong on 3/2/13.
//
//

#import <UIKit/UIKit.h>
#import "GSObject.h"
@interface CorrectionViewController : UIViewController <UIAlertViewDelegate>
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic,strong) GSObject* gsobj;
@property (nonatomic, strong) UITextField* correctionTextField;
@end
