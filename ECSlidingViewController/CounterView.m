//
//  CounterView.m
//  ECSlidingViewController
//
//  Created by HengHong on 8/12/12.
//
//

#import "CounterView.h"
#define kLeftPadding 5.0f
#define kTitleHeight 30.0f
@implementation CounterView
@synthesize titleLabel,subtitleLabel;
- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andSubtitle:(NSString *)subtitle
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kLeftPadding, 0, self.bounds.size.width-kLeftPadding, kTitleHeight)];
        self.subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kLeftPadding, titleLabel.frame.size.height, self.bounds.size.width-kLeftPadding, self.bounds.size.height - titleLabel.frame.size.height)];
        titleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:25.0f];
        subtitleLabel.font = [UIFont systemFontOfSize:13.0f];
        titleLabel.text = title;
        subtitleLabel.text = subtitle;
        
        [self addSubview:titleLabel];
        [self addSubview:subtitleLabel];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat gray[4] = {122.0/255.0, 120.0/255.0,
        121.0/255.0, 0.3};
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 0, 0 );
    CGContextAddLineToPoint(c, self.bounds.size.width, 0 );
    CGContextSetLineWidth(c, 3.0f);
    CGContextAddLineToPoint(c,self.bounds.size.width ,self.bounds.size.height );
    CGContextAddLineToPoint(c,0 ,self.bounds.size.height );
    CGContextSetStrokeColor(c, gray);
    CGContextStrokePath(c);
    [super drawRect:rect];
    
    
}



@end
