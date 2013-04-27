//
//  InitialSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/25/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

// Comments: This is the container for mapnav and left menu in case we decide to add one

#import "MapSlidingViewController.h"
@implementation MapSlidingViewController
@synthesize category;
- (void)viewDidLoad {
  [super viewDidLoad];
    category = 6;
  UIStoryboard *storyboard;
    self.view.backgroundColor = [UIColor blackColor];
    storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        [self setAnchorLeftPeekAmount:1.0f];    
  self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"GeoScroll"];
}
-(BOOL)shouldAutorotate{
    return NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return NO;
}



@end
