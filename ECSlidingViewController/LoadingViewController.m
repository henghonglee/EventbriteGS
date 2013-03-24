//
//  LoadingViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 22/3/13.
//
//

#import "LoadingViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageNameArray = [NSArray arrayWithObjects:@"bakuteh.jpg",@"chillycrab.jpg", nil];
    [self.tbLabel setText:@"Tastebuds"];
    [self.tbLabel setFont:[UIFont fontWithName:@"Miss Claude" size:75.0f]];
    [self.instructionScrollView setClipsToBounds:NO];
    [self.instructionScrollView setPagingEnabled:YES];
    [self.instructionScrollView setContentSize:CGSizeMake(300, 930)];
    [self.instructionScrollView setShowsVerticalScrollIndicator:NO];
    [self.instructionScrollView setDelegate:self];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
	// Do any additional setup after loading the view.
}
-(void)changeImage
{
    if (self.instructionScrollView.frame.origin.y < -919) {
    int r = arc4random() % self.imageNameArray.count;
    UIImage * toImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[self.imageNameArray objectAtIndex:r]]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.view
                          duration:1.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.imageView.image = toImage;
                        } completion:NULL];
        
    });
    }
    
}

- (IBAction)continueButton:(id)sender {
    
    self.instructionScrollView.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (self.timer) {
//        [self.timer invalidate];
//        self.timer = nil;
//    }
//}
- (IBAction)instructionButton:(id)sender {

    if (self.instructionScrollView.frame.origin.y < -919) {
        [self.timer setFireDate:[NSDate distantFuture]];
        self.tbLabel.hidden = YES;
        CGRect slideViewFinalFrame = CGRectMake(10, 53, 300, 310);
        [UIView animateWithDuration:0.7
                              delay:0.2
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.instructionScrollView.frame = slideViewFinalFrame;
                         }
                         completion:^(BOOL finished){
                             
                             
                         }];
    }else{

        CGRect slideViewFinalFrame = CGRectMake(10, -950, 300, 310);
        self.tbLabel.hidden = NO;
        self.tbLabel.alpha = 0;
        [UIView animateWithDuration:0.7
                              delay:0.2
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.instructionScrollView.frame = slideViewFinalFrame;
                         }
                         completion:^(BOOL finished){
                             [self.instructionScrollView setContentOffset:CGPointMake(0, 0)];
                             [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                         self.tbLabel.alpha = 1;
                                 

                             } completion:^(BOOL finished) {
                                 [self.timer setFireDate:[[NSDate date] addTimeInterval:5]];
                              
                             }];
                         }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate
{
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}
- (void)viewDidUnload {
    [self setTbLabel:nil];
    [self setInstructionScrollView:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
