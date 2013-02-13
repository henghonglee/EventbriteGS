//
//  InitialSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/25/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MapSlidingViewController.h"
@implementation MapSlidingViewController
@synthesize category;
- (void)viewDidLoad {
  [super viewDidLoad];
    category = 6;
  UIStoryboard *storyboard;
    self.view.backgroundColor = [UIColor blackColor];
//  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
//  } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//    storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
//  }
  
  self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"GeoScroll"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
  return YES;
}



@end
