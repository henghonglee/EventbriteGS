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
#import "FoodImage.h"
#import "FoodType.h"
#import "FoodItem.h"
#define VERSION 1.0
@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DB = [[paths lastObject] stringByAppendingPathComponent:@"FoodItem.sqlite"];
    if (![fileManager fileExistsAtPath:DB]) {
        NSString *shippedDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FoodItem.sqlite"];
        [fileManager copyItemAtPath:shippedDB toPath:DB error:&error];
    }
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
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        NSLog(@"got managed context with notification enabled");
    }
    
    return _managedObjectContext;
}
- (void)_mocDidSaveNotification:(NSNotification *)notification
{
    NSLog(@"did get notification");
    NSManagedObjectContext *savedContext = [notification object];
    
    // ignore change notifications for the main MOC
    if (_managedObjectContext == savedContext)
    {
        NSLog(@"same context.. ignoring");
        return;
    }
    
    if (_managedObjectContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator)
    {
        // that's another database
        NSLog(@"different database..ignoring");
        return;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"here");
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}
// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FoodItem" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FoodItem.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
@end
