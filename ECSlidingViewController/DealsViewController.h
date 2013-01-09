

#import <UIKit/UIKit.h>
#import "GSObject.h"
#import <SDWebImage/SDWebImageManager.h>
@interface DealsViewController : UICollectionViewController <SDWebImageManagerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UIActivityIndicatorView* loadingIndicator;
@property (nonatomic,strong) GSObject* gsObject;
@property (nonatomic, strong) NSMutableArray* dealArray;
@property (nonatomic, strong) NSMutableArray* loadedDealArray;
@property (nonatomic, assign) CGPoint prevOffset;
@end
