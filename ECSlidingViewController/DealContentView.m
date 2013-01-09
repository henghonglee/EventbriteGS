//
//  DealContentView.m
//  ECSlidingViewController
//
//  Created by HengHong on 5/12/12.
//
//

#import "DealContentView.h"
#import <QuartzCore/QuartzCore.h>
#define kSeperatorSize 5.0f
#define kLeftRightPadding 0.0f
#define kPaddingBtwElements 5.0f
#define kBottomPadding 0.0f
#define kTopPadding 0.0f
@implementation DealContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.layer setShadowOpacity:1.0f];
        [self.layer setShadowRadius:10.f];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 3, self.bounds.size.width, 5)];
        self.layer.shadowPath = path.CGPath;
        
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    [self drawPathWithContext:c];
    CGContextSetRGBFillColor(c, 255.0f/255.0f, 232.0f/255.0f, 105.0f/255.0f, 1.0f);
    CGContextFillPath(c);
    
    
    
}
-(void) drawPathWithContext:(CGContextRef)c
{
    int count = (self.bounds.size.width - (2*kLeftRightPadding)) / kSeperatorSize;
    CGContextMoveToPoint(c, kLeftRightPadding, kSeperatorSize+kTopPadding );//start from below
    for (int i = 1 ; i<count; i++) {
        CGContextAddLineToPoint(c, kSeperatorSize*i+kLeftRightPadding, ((((i-1)%2)*5)+kTopPadding));
    }
    CGContextAddLineToPoint(c, kSeperatorSize*count+kLeftRightPadding, kTopPadding+((count-1)%2)*5);
    
    CGContextAddLineToPoint(c, self.bounds.size.width-kLeftRightPadding, self.bounds.size.height - kSeperatorSize-kBottomPadding);
    for (int i = 1 ; i<count; i++) {
        CGContextAddLineToPoint(c, self.bounds.size.width-(kSeperatorSize*i)-kLeftRightPadding, self.bounds.size.height-kBottomPadding-((i-1)%2)*5);
    }
    CGContextAddLineToPoint(c, self.bounds.size.width-(kSeperatorSize*count)-kLeftRightPadding, self.bounds.size.height-kBottomPadding-((count-1)%2)*5);
    
    CGContextAddLineToPoint(c, kLeftRightPadding, kSeperatorSize+kTopPadding);
    

}
@end
