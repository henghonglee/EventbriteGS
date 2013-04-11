// 
//  RefreshView.m
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

#import "RefreshView.h"

@implementation RefreshView

@synthesize refreshDelegate,side;

- (id)initWithFrame:(CGRect)frame andSide:(PullRefreshSide)pullSide{
    
    self = [super initWithFrame:frame];
    
    if (self) {

        side = pullSide;
        
		CALayer *layer = [CALayer layer];
		if (side == PullRefreshLeft) {
            layer.frame = CGRectMake(self.frame.size.width-30.0f-5, 0, 45.0f, self.frame.size.height);
            layer.contents = (id)[UIImage imageNamed:@"arrow"].CGImage;             
        }else{
            layer.frame = CGRectMake(0, 0, 30.0f, self.frame.size.height);
            layer.contents = (id)[UIImage imageNamed:@"arrowleft"].CGImage;            
        }
		layer.contentsGravity = kCAGravityCenter;

        
        
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            
			layer.contentsScale = [[UIScreen mainScreen] scale];
            
		}
		
		[[self layer] addSublayer:layer];
        
		arrowImage=layer;

        // Spinner
        
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		
        view.frame = CGRectMake(32.0f, frame.size.height - 39.5f, 20.0f, 20.0f);
        
        [self addSubview:view];
        
		activityView = view;
		
		[self setState:PullRefreshNormal];
        
    }
    
    return self;
    
}



- (void)setState:(PullRefreshState)refreshState{
    
	switch (refreshState) {
            
        case PullRefreshNormal:
			
			if (state == PullRefreshPulling) {
                
				[CATransaction begin];
				[CATransaction setAnimationDuration:0.18f];
                
				arrowImage.transform = CATransform3DIdentity;
                
				[CATransaction commit];
			}
			
//			statusLabel.text = @"PULL DOWN TO REFRESH...";
            
			[activityView stopAnimating];
            
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            
			arrowImage.hidden = NO;
			arrowImage.transform = CATransform3DIdentity;
            
			[CATransaction commit];
			
			break;
            
		case PullRefreshPulling:
			
//			statusLabel.text = @"RELEASE TO REFRESH...";
            
			[CATransaction begin];
			[CATransaction setAnimationDuration:0.18f];
            
			arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            
			[CATransaction commit];
			
			break;
            
		case PullRefreshLoading:
			
//			statusLabel.text = @"LOADING...";
            
			[activityView startAnimating];
            
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            
			arrowImage.hidden = YES;
            
			[CATransaction commit];
			
			break;
            
		default:
            
			break;
            
	}
	
	state = refreshState;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{


	if (state == PullRefreshLoading) {
        
//		CGFloat offset = MAX(scrollView.contentOffset.x * -1, 0);
//        
//		offset = MIN(offset, 60);
//        
//		scrollView.contentInset = UIEdgeInsetsMake(offset, offset, 0.0f, 0.0f);
		[self setState:PullRefreshNormal];
	} else if (scrollView.isDragging) {
        
		BOOL loading = NO;
        
		if ([scrollView.delegate respondsToSelector:@selector(RefreshTableHeaderDataSourceIsLoading:)]) {
            
			loading = [refreshDelegate dataIsLoading:self];
            
		}
		
		if (state == PullRefreshPulling && scrollView.contentOffset.x < 680.0f && scrollView.contentOffset.x > 0.0f && !loading && side== PullRefreshRight) {
            
			[self setState:PullRefreshNormal];
            
		} else if (state == PullRefreshNormal && scrollView.contentOffset.x > 680.0f && !loading && side== PullRefreshRight) {

			[self setState:PullRefreshPulling];
            
		} else if (state == PullRefreshPulling && scrollView.contentOffset.x > -60.0f && scrollView.contentOffset.x < 0.0f && !loading && side== PullRefreshLeft) {
            [self setState:PullRefreshNormal];
            
        }else if(state == PullRefreshNormal && scrollView.contentOffset.x < -60.0f && !loading && side== PullRefreshLeft) {

			[self setState:PullRefreshPulling];
            
		}
		
		if (scrollView.contentInset.top != 0) {
            
			scrollView.contentInset = UIEdgeInsetsZero;
            
		}
		
	}
	
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    NSLog(@"viewDidEndDragging");
    
	BOOL loading = NO;

	if (scrollView.contentOffset.x <= - 60.0f && !loading && side == PullRefreshLeft) {
        
        NSLog(@"dataIsNotLoading");
        
		if ([refreshDelegate respondsToSelector:@selector(didTriggerRefresh:)]) {
            
            NSLog(@"espondsToSelector:@selector(didTriggerRefresh:)");
			
            [refreshDelegate didTriggerRefresh:self];
            
		}
		
		[self setState:PullRefreshLoading];
	}
    
    if (scrollView.contentOffset.x >= 680.0f && !loading && side == PullRefreshRight) {
        
        NSLog(@"dataIsNotLoading");
        
		if ([refreshDelegate respondsToSelector:@selector(didTriggerRefresh:)]) {
            
            NSLog(@"respondsToSelector:@selector(didTriggerRefresh:)");
			
            [refreshDelegate didTriggerRefresh:self];
            
		}
		
		[self setState:PullRefreshLoading];
	}
	
}

- (void)viewDataDidFinishedLoading:(UIScrollView *)scrollView {
	
    NSLog(@"viewDataDidFinishedLoading");
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
	[UIView commitAnimations];
	
	[self setState:PullRefreshNormal];
    
}

@end