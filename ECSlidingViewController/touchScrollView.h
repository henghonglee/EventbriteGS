//
//  touchScrollView.h
//  ECSlidingViewController
//
//  Created by HengHong on 9/4/13.
//
//

#import <UIKit/UIKit.h>
#import "RefreshView.h"
typedef void (^refreshBlock)();

@interface touchScrollView : UIScrollView <UIScrollViewDelegate , RefreshViewDelegate>


@property(readwrite, copy) refreshBlock rightRefresh;
@property(readwrite, copy) refreshBlock leftRefresh;
@property (nonatomic, strong)RefreshView* pullBottomToRefreshView;
@property (nonatomic, strong)RefreshView* pullToRefreshView;
@end
