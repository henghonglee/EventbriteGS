#import <UIKit/UIKit.h>
enum{
    kLayoutStateTable,
    kLayoutStateDetail
}kLayoutState;
@interface DealsLayout : UICollectionViewLayout

@property (nonatomic, assign) CGPoint prevOffset;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) NSInteger cellCount;
@property (nonatomic, assign) NSInteger kLayoutStateRef;
@end
