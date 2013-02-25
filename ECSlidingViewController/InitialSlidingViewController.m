//
//  InitialSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/25/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "InitialSlidingViewController.h"
#import "MapNavViewController.h"
@implementation InitialSlidingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIStoryboard *storyboard;
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
  }
  
  self.topViewController = [MapNavViewController sharedInstance];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEvent:) name:@"SHOWMENU" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideMenuEvent:) name:@"HIDEMENU" object:nil];
    
}
- (void)receiveEvent:(NSNotification *)notification {
    
    [super anchorTopViewTo:ECRight];
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"LeftReveal"]==nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"Enabled" forKey:@"LeftReveal"];
    }
}
- (void)receiveHideMenuEvent:(NSNotification *)notification {
    NSLog(@"hiding menu");
}

-(BOOL)shouldAutorotate{
    if (self.underLeftShowing) {
        return NO;
    }else{
        return YES;
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (self.underLeftShowing) {
        return NO;
    }else{
        return YES;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEvent:) name:@"SHOWMENU" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHideMenuEvent:) name:@"HIDEMENU" object:nil];
    }
}


@end
