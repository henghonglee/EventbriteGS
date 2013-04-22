//
//  RateLabel.m
//  ECSlidingViewController
//
//  Created by HengHong on 20/4/13.
//
//

#import "RateLabel.h"
#import "HHStarView.h"
@implementation RateLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(HHStarView*)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userRating"]) {
            
        if (object.userRating<20.0f) {
            [self setText:@"Touch To Rate!"];
        }else if (object.userRating>=20.0f && object.userRating<40.0f ){
            [self setText:@"Dont Like it."];
        }else if (object.userRating>=40.0f && object.userRating<60.0f ){
            [self setText:@"Its Average."];
        }else if (object.userRating>=60.0f && object.userRating<80.0f ){
            [self setText:@"You Like it."];
        }else if (object.userRating>=80.0f && object.userRating<100.0f ){
            [self setText:@"You Love it!"];
        }else if (object.userRating>=100.0f){
            [self setText:@"Super Shiok!"];
        }
    }
}
@end
