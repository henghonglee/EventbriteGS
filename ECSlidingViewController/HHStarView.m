//
//  HHStarView.m
//  startest
//
//  Created by HengHong on 6/12/12.
//  Copyright (c) 2012 HengHong. All rights reserved.
//

#import "HHStarView.h"
@implementation HHStarView
@synthesize timer;
#define kLabelAllowance 15.0f
- (id)initWithFrame:(CGRect)frame andRating:(float)rating animated:(BOOL)animated
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        _maxrating = rating*(self.bounds.size.width-frame.size.height-kLabelAllowance);
        if (animated) {
            _rating = 0;
            timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(increaseRating) userInfo:nil repeats:YES];
        }else{
            _rating = _maxrating;
        }
        
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width-frame.size.height-kLabelAllowance , 0, frame.size.height+kLabelAllowance, frame.size.height)];
        self.label.font = [UIFont systemFontOfSize:11.0f];
        self.label.text = [NSString stringWithFormat:@"%.0f%%",rating*100];
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
    }
    return self;
}
-(void)rating:(float)rating withAnimation:(BOOL)animated
{
    _maxrating = rating*(self.bounds.size.width-self.bounds.size.height-kLabelAllowance);
    if (animated) {
        _rating = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(increaseRating) userInfo:nil repeats:YES];
    }else{
        _rating = _maxrating;
        
    }
    self.label.text = [NSString stringWithFormat:@"%.0f%%",rating*100];
    [self setNeedsDisplay];
}

-(void)increaseRating
{
   
    if (_rating<_maxrating) {
        _rating = _rating + 2;
        [self setNeedsDisplay];
    }else{
        [timer invalidate];
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIImage* image = [UIImage imageNamed:@"5starsgray.png"];
    CGRect newrect = CGRectMake(0, 0, self.bounds.size.width-self.bounds.size.height-kLabelAllowance, self.bounds.size.height);
    [image drawInRect:newrect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, newrect, [UIImage imageNamed:@"5starflip.png"].CGImage);
    CGContextClipToRect(context, CGRectMake(0, 0, MIN(self.bounds.size.width,_rating), self.bounds.size.height));
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [[UIColor yellowColor] setFill];
    CGContextFillRect(context, newrect);
}


@end
