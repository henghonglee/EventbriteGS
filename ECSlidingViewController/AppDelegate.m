//
//  AppDelegate.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "AppDelegate.h"
#import "Mobclix.h"
#import "Flurry.h"
#import <BugSense-iOS/BugSenseController.h>

#define VERSION 1.0
@implementation AppDelegate

@synthesize window = _window;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Flurry startSession:@"GS58TP8CPRJC55Z7PGV2"];
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"e10888bc"];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userUID"]) {
        //on first launch get a UUID from our servers
        //things we want to know from our users
        // - types of food they click on
        // - how long they read it for
        // - where they are
        // - how long they stay in our app (Flurry)
    }
    
    
    self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    application.applicationSupportsShakeToEdit = YES;
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%0.2f",VERSION]] isEqualToString:@"Enabled"]) {
        
    }else{
        NSLog(@"not enabled");
        [[NSUserDefaults standardUserDefaults] setObject:@"Enabled" forKey:[NSString stringWithFormat:@"%0.2f",VERSION]];
        NSArray* menuItems = [NSArray arrayWithObjects:@"IEATISHOOTIPOST",@"LADY IRON CHEF",@"LOVE SG FOOD",@"SGFOODONFOOT",@"DANIEL FOOD DIARY", nil];
        for (NSString* blog in menuItems)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"Enabled" forKey:blog];
        }
    }
  [self.window makeKeyAndVisible];
    [Mobclix startWithApplicationId:@"DD9EE023-DB44-43A2-BE49-8E8EA51459F5"];
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation.png"] forBarMetrics:UIBarMetricsDefault];
    
    UIImage *backButton = [[UIImage imageNamed:@"back_button.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17, 0, 10)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    UIImage *backButtonLandscape = [[UIImage imageNamed:@"back_button_landscape.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 17, 0, 10)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonLandscape forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:     [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
                                                               UITextAttributeTextColor,
                                                               [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
                                                               UITextAttributeTextShadowColor,
                                                               [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                               UITextAttributeTextShadowOffset,
                                                               [UIFont fontWithName:@"Helvetica-Light" size:13.0f],
                                                               UITextAttributeFont,
                                                               nil]
                                                forState:UIControlStateNormal];

//    [[UIBarButtonItem appearance] setBackgroundImage:actionButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Helvetica-Light" size:17.0f],
      UITextAttributeFont,
      nil]];
    
    
    
    
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

@end
