//
//  RefreshView.h
//
//  Created by Roger Fernandez Guri on 10/23/12.
//  Copyright (c) 2012 rogerfernandezg. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files, to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
    
    PullRefreshPulling = 0,
    PullRefreshNormal,
    PullRefreshLoading,
    
} PullRefreshState;

typedef enum{
    
    PullRefreshRight,
    PullRefreshLeft,
    
}PullRefreshSide;

@class RefreshView;

@protocol RefreshViewDelegate <NSObject>

@required

- (void)didTriggerRefresh:(RefreshView*)view;
- (BOOL)dataIsLoading:(RefreshView*)view;

@end

@interface RefreshView : UIScrollView <UIScrollViewDelegate> {
    
    id <RefreshViewDelegate> refreshDelegate;
    
    PullRefreshState state;
    
    UILabel *lastUpdatedLabel;
    UILabel *statusLabel;
    
    CALayer *arrowImage;
    
    UIActivityIndicatorView *activityView;
    
}

@property(nonatomic,strong) id <RefreshViewDelegate> refreshDelegate;
@property(nonatomic) PullRefreshSide side;
- (id)initWithFrame:(CGRect)frame andSide:(PullRefreshSide)pullSide;
@end