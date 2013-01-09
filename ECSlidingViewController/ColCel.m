//
//  ColCel.m
//  ECSlidingViewController
//
//  Created by HengHong on 28/11/12.
//
//

#import "ColCel.h"

@implementation ColCel
@synthesize foodImageView = _foodImageView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _foodImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [_foodImageView setContentMode:UIViewContentModeScaleAspectFill];
        self.clipsToBounds = YES;

        UIActivityIndicatorView* loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [loadingView setFrame:CGRectMake(0, 0, 50, 50)];
        loadingView.center = CGPointMake(self.bounds.size.width/2,self.bounds.size.height/2);
        [self addSubview:loadingView];
        [loadingView startAnimating];
        [self addSubview:_foodImageView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
