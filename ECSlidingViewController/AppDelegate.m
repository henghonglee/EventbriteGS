//
//  AppDelegate.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//
#import "MapSlidingViewController.h"
#import "MapNavViewController.h"
#import "AppDelegate.h"
#import "AFHTTPClient.h"
#import "GeoScrollViewController.h"
#import "MapSlidingViewController.h"
#import "MapNavViewController.h"
#import "TBAPIClient.h"

#define VERSION 1.0
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
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
    NSString *DB = [[paths lastObject] stringByAppendingPathComponent:@"Event.sqlite"];
    if (![fileManager fileExistsAtPath:DB]) {
        NSString *shippedDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Event.sqlite"];
        [fileManager copyItemAtPath:shippedDB toPath:DB error:&error];
    }


    
    
    self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self.window makeKeyAndVisible];
    
    
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
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



}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController isKindOfClass:[MapSlidingViewController class]]) {
        NSLog(@"calling didrefresh table");
        [((GeoScrollViewController*)((MapSlidingViewController*)((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController).topViewController) didRefreshTable:nil];
    }
    

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
        [_managedObjectContext setUndoManager:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        NSLog(@"got managed context with notification enabled");
    }
    
    return _managedObjectContext;
}
- (void)_mocDidSaveNotification:(NSNotification *)notification
{
 
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
        NSLog(@"merging...");
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Event" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Event.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

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



-(NSDate*)getGMTDate
{
    NSDate *localDate = [NSDate date];
    NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    NSTimeInterval gmtTimeInterval = [localDate timeIntervalSinceReferenceDate] - timeZoneOffset;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    
}
- (NSManagedObjectContext *)dataManagedObjectContext
{
    
    if (_dataManagedObjectContext != nil) {
        return _dataManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [((AppDelegate*)[UIApplication sharedApplication].delegate) persistentStoreCoordinator];
    if (coordinator != nil) {
        _dataManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [_dataManagedObjectContext setPersistentStoreCoordinator:coordinator];
        [_dataManagedObjectContext setUndoManager:nil];
        
    }
    
    return _dataManagedObjectContext;
}
- (NSManagedObjectContext *)uploadManagedObjectContext
{
    
    if (_uploadManagedObjectContext != nil) {
        return _uploadManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [((AppDelegate*)[UIApplication sharedApplication].delegate) persistentStoreCoordinator];
    if (coordinator != nil) {
        _uploadManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [_uploadManagedObjectContext setPersistentStoreCoordinator:coordinator];
        [_uploadManagedObjectContext setUndoManager:nil];
        
    }
    
    return _uploadManagedObjectContext;
}
- (NSManagedObjectContext *)placeManagedObjectContext
{
    
    if (_placeManagedObjectContext != nil) {
        return _placeManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [((AppDelegate*)[UIApplication sharedApplication].delegate) persistentStoreCoordinator];
    if (coordinator != nil) {
        _placeManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [_placeManagedObjectContext setPersistentStoreCoordinator:coordinator];
        [_placeManagedObjectContext setUndoManager:nil];
        
    }
    
    return _placeManagedObjectContext;
}


@end
