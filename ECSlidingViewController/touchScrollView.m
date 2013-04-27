//
//  touchScrollView.m
//  ECSlidingViewController
//
//  Created by HengHong on 9/4/13.
//
//

#import "touchScrollView.h"

@implementation touchScrollView
@synthesize pullToRefreshView,pullBottomToRefreshView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        pullToRefreshView = [[RefreshView alloc] initWithFrame:CGRectMake(0.0f-self.bounds.size.width, 0.0f , self.bounds.size.width, self.bounds.size.height) andSide:PullRefreshLeft];
        [pullToRefreshView setRefreshDelegate:self];
        [self addSubview:pullToRefreshView];
        pullBottomToRefreshView = [[RefreshView alloc] initWithFrame:CGRectMake(self.bounds.size.width*3, 0.0f , self.bounds.size.width, self.bounds.size.height)andSide:PullRefreshRight];
        [self setDelegate:self];
        [pullBottomToRefreshView setRefreshDelegate:self];
        [self addSubview:pullBottomToRefreshView];
        
    
    }
    return self;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullBottomToRefreshView scrollViewDidScroll:scrollView];
    [pullToRefreshView scrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.x < 0.0f) {
        [pullToRefreshView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }else if(scrollView.contentOffset.x > 0.0f) {
        [pullBottomToRefreshView scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }

}
- (void)didTriggerRefresh:(RefreshView*)view{
	
    if (view.side == PullRefreshLeft) {
        NSLog(@"didTriggerRefreshLeft");
        if (self.leftRefresh) {
            self.leftRefresh();
        }
        
    }else{
        if (self.rightRefresh) {
            self.rightRefresh();
        }
    }
}
-(BOOL)dataIsLoading:(RefreshView *)view
{
    return NO;
}

- (void)doneLoadingData:(RefreshView*)refreshView{
    
    
	
	
}


//- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event
//{
//   
//    NSLog(@"nextResponder = %@,%@,%@", self.nextResponder,touches,event);
//    
//    [[self nextResponder] touchesEnded:touches withEvent:event];
//}
//- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
//{
//     NSLog(@"nextResponder = %@", self.nextResponder);
//    [[self nextResponder] touchesBegan:touches withEvent:event];
//}
@end
