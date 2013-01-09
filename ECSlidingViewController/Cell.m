

#import "Cell.h"
#import <QuartzCore/QuartzCore.h>
#import "DealContentView.h"
#define kBottomStackHeight 40.0f
#define kLeftPadding 10.0f
#define kTopPadding 20.0f
#define kProfileImageSize 30.0f
#define kButtonSize 30.0f
#define kPaddingBtwElements 10.0f
@implementation Cell
@synthesize descriptionLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.cellScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.cellScrollView.clipsToBounds = NO;
        self.cellScrollView.scrollEnabled = NO;
        
        self.descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(kLeftPadding,
                                                                               kTopPadding,
                                                                               self.bounds.size.width-kLeftPadding*2,
                                                                               self.bounds.size.height-2*kTopPadding - kBottomStackHeight-kButtonSize)];
        self.descriptionTextView.editable = NO;
        self.descriptionTextView.font = [UIFont systemFontOfSize:15.0f];
        self.descriptionTextView.backgroundColor = [UIColor clearColor];
        self.descriptionTextView.hidden = YES;
        
        self.dealContentView = [[DealContentView alloc]initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                self.bounds.size.width,
                                                                                self.bounds.size.height)];
        
        
        self.flipButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        self.flipButton.frame = CGRectMake(self.bounds.size.width-kLeftPadding-kButtonSize,
                                           self.descriptionTextView.frame.size.height+kTopPadding,
                                           kButtonSize,
                                           kButtonSize);
        [self.flipButton addTarget:self action:@selector(toggleFlipped:) forControlEvents:UIControlEventTouchUpInside];
        
        self.dealImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        
        
        self.profileImage = [[UIImageView alloc]initWithFrame:CGRectMake(kLeftPadding,
                                                                         kTopPadding,
                                                                         kProfileImageSize,
                                                                         kProfileImageSize)];

        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [self.titleLabel setNumberOfLines:0];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:self.cellScrollView];
        [self.cellScrollView addSubview:_dealContentView];
        [self.cellScrollView addSubview:self.descriptionTextView];
        [self.cellScrollView addSubview:self.dealImage];
        [self.cellScrollView addSubview:self.profileImage];
        [self.cellScrollView addSubview:self.titleLabel];
        [self.cellScrollView addSubview:self.flipButton];
    }
    return self;
}
-(void)toggleFlipped:(id)sender
{
    [UIView transitionWithView:self.contentView duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        if (!self.flipped) {
            self.flipped = YES;
            for (UIView* collectionSubview in self.cellScrollView.subviews) {
                if ([collectionSubview isKindOfClass:[UITextView class]]||[collectionSubview isKindOfClass:[UIButton class]]) {
                    collectionSubview.hidden = NO;
                }else if (![collectionSubview isKindOfClass:[DealContentView class]]) {
                    collectionSubview.hidden = YES;
                }else{
                    
                }
                
            }
        }else{
            self.flipped = NO;
            for (UIView* collectionSubview in self.cellScrollView.subviews) {
                if ([collectionSubview isKindOfClass:[UITextView class]]) {
                    collectionSubview.hidden = YES;
                }
                else
                {
                    collectionSubview.hidden = NO;
                }
            }
        }
        
    } completion:nil];
}

@end
