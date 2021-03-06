//
//  MapNavViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 10/12/12.
//
//


// Comments: This is the toplayer container for the undermapviewcontroller and geoscrollviewcontroller

#import "MapNavViewController.h"
#import "ECSlidingViewController.h"
@interface MapNavViewController ()

@end

@implementation MapNavViewController
+(MapNavViewController *)sharedInstance
{
    UIStoryboard *storyboard;
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
//    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
//    }
    
    static MapNavViewController *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [storyboard instantiateViewControllerWithIdentifier:@"MapTop"];
    });
    
    return sharedInstance;
}
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
    self.view.backgroundColor = [UIColor clearColor];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
//    if (![self.slidingViewController.underLeftViewController isKindOfClass:[UINavigationController class]]) {
//        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
//    }
}
-(BOOL)shouldAutorotate{
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{

    return NO;
}
- (void)didReceiveMemoryWarning
{
    NSLog(@"did recieve memory warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
