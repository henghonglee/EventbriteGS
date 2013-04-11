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
#import "Mobclix.h"
#import "Flurry.h"
#import <BugSense-iOS/BugSenseController.h>
#import "FoodImage.h"
#import "FoodType.h"
#import "FoodRating.h"
#import "FoodItem.h"
#import "AFHTTPClient.h"
#import "GeoScrollViewController.h"
#import "MapSlidingViewController.h"
#import "MapNavViewController.h"
#import <NewRelicAgent/NewRelicAgent.h>
#import "SimpleKeychain.h"
#define VERSION 1.0
#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[NSUserDefaults standardUserDefaults] setObject:@"Enabled" forKey:@"LeftReveal"];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"]==NULL) {
            NSLog(@"didnt find auth token in keychain");
            NSURL *tokenurl = [NSURL URLWithString:@"http://tastebudsapp.herokuapp.com"];
            AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
            [afclient getPath:@"/newGuestUser" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError* error = nil;
                NSDictionary* jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
                if ([[jsonResponse objectForKey:@"success"]isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                    [[NSUserDefaults standardUserDefaults] setObject:[jsonResponse objectForKey:@"auth_token"] forKey:@"auth_token"];
                    [[NSUserDefaults standardUserDefaults] setObject:[[jsonResponse objectForKey:@"user"] objectForKey:@"email"] forKey:@"user_email"];
                    [[NSUserDefaults standardUserDefaults] setObject:[[jsonResponse objectForKey:@"user"] objectForKey:@"id"] forKey:@"user_id"];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            }];
        
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DB = [[paths lastObject] stringByAppendingPathComponent:@"FoodItem.sqlite"];
    if (![fileManager fileExistsAtPath:DB]) {
        NSString *shippedDB = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FoodItem.sqlite"];
        [fileManager copyItemAtPath:shippedDB toPath:DB error:&error];
    }
    [NewRelicAgent startWithApplicationToken:@"AA6d3b18f7d946f4fd29b49f53d8d598b9ff835a19"];
    [Flurry startSession:@"GS58TP8CPRJC55Z7PGV2"];
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"e10888bc"];


    
    
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

    if ([((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController isKindOfClass:[MapSlidingViewController class]]) {
        ((GeoScrollViewController*)((MapSlidingViewController*)((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController).topViewController).tableView.alpha = 0.0f;
    }
    [self doUpdate];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ([((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController isKindOfClass:[MapSlidingViewController class]]) {
        NSLog(@"calling didrefresh table");
        [((GeoScrollViewController*)((MapSlidingViewController*)((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController).topViewController) didRefreshTable:nil];
    }
    

}
- (void) doUpdate
{
    
    [self beginBackgroundUpdateTask];
    
    GSdataSerialQueue = dispatch_queue_create("com.example.GSDataSerialQueue", NULL);
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.includesPropertyValues = NO;
    request.entity = [NSEntityDescription entityForName:@"FoodRating" inManagedObjectContext:[self dataManagedObjectContext]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(uploaded_at >= %@)", [self getGMTDate]];
    NSError *executeFetchError = nil;
    NSArray* foodratings = [[self dataManagedObjectContext] executeFetchRequest:request error:&executeFetchError];
    __block int ratingcount = foodratings.count;
    __block int currentcount = 0;
    if (executeFetchError) {
        NSLog(@"fetch error");
    }else{
        NSLog(@"found raitngs = %@",foodratings);
        for (FoodRating* rating in foodratings) {
            NSLog(@"sending ratings");
            if (rating.score.intValue <= 0) {
                NSURL *tokenurl = [NSURL URLWithString:@"http://tastebudsapp.herokuapp.com/"];
                AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
                [afclient deletePath:[NSString stringWithFormat:@"/ratings/1"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:rating.place_id,@"rating[place_id]",[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"],@"auth_token",nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    dispatch_async(GSdataSerialQueue, ^{
                        NSError* error =nil;
                        NSDictionary* jsonResp = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
                        FoodPlace *foodplace = nil;
                        NSManagedObjectContext* context = [self dataManagedObjectContext];
                        NSFetchRequest *request = [[NSFetchRequest alloc] init];
                        request.includesPropertyValues = NO;
                        request.entity = [NSEntityDescription entityForName:@"FoodPlace" inManagedObjectContext:context];
                        request.predicate = [NSPredicate predicateWithFormat:@"item_id = %d", rating.place_id.intValue];
                        
                        NSError *executeFetchError = nil;
                        NSArray* foodratings = [context executeFetchRequest:request error:&executeFetchError];
                        if (foodratings.count>0) {
                            foodplace = [foodratings objectAtIndex:0];
                        }
                        
                        if (executeFetchError) {
                            
                        } else if (!foodplace) {
                            //found new rating...gotta find out which place it belongs to
                            NSAssert(false, @"should find place");
                        }
                        if ([foodplace.ratings containsObject:rating]) {
                            NSLog(@"removed rating");
                            [foodplace removeRatingsObject:rating];
                        }
                        [context deleteObject:rating];
                        [foodplace setCurrent_rating:[NSNumber numberWithInt:[[[jsonResp objectForKey:@"place"] objectForKey:@"current_rating"] intValue]]];
                        [foodplace setRate_count:[NSNumber numberWithInt:[[[jsonResp objectForKey:@"place"] objectForKey:@"rate_count"] intValue]]];
                        [foodplace setCurrent_user_rated:[NSNumber numberWithBool:NO]];
                        if (![context save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }else{
                            NSLog(@"deleted online rating");
                        }
                        currentcount = currentcount + 1;
                        if (currentcount ==ratingcount) {
                            [self endBackgroundUpdateTask];
                        }
                    });
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    
                    NSLog(@"failed with error =%@",error);
                    currentcount = currentcount + 1;
                    if (currentcount ==ratingcount) {
                        [self endBackgroundUpdateTask];
                    }
                }];

            }else{
                NSURL *tokenurl = [NSURL URLWithString:@"http://tastebudsapp.herokuapp.com/"];
                AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
                [afclient postPath:@"/ratings" parameters:[NSDictionary dictionaryWithObjectsAndKeys:rating.score,@"rating[score]",rating.place_id,@"rating[place_id]",rating.user_id,@"rating[user_id]",[[NSUserDefaults standardUserDefaults]objectForKey:@"auth_token"],@"auth_token",nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    dispatch_async(GSdataSerialQueue, ^{
                        
                        NSError* error =nil;
                        NSDictionary* jsonResp = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
                        NSLog(@"%@",jsonResp);
                        if([[jsonResp objectForKey:@"success"] isEqualToNumber:[NSNumber numberWithBool:true]])
                        {
                            NSDictionary* ratingDictionary = [jsonResp objectForKey:@"rating"];
                            [self addRatingWithRatingDictionary:ratingDictionary withUpdatedDate:[self getGMTDate]];
                        }
                        currentcount = currentcount + 1;
                        if (currentcount ==ratingcount) {
                            [self endBackgroundUpdateTask];
                        }
                        
                    });
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"failed with error =%@",error);
                    currentcount = currentcount + 1;
                    if (currentcount ==ratingcount) {
                        [self endBackgroundUpdateTask];
                    }
                }];
            }
        }
    }

    

}
- (void) beginBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask
{
        NSLog(@"ending background task");
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
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


-(void)addRatingWithRatingDictionary:(NSDictionary*)ratingDictionary withUpdatedDate:(NSDate*)updatedDate
{
    NSError* error =nil;
    FoodRating *foodrating = nil;
    NSManagedObjectContext* context = [self dataManagedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.includesPropertyValues = NO;
    request.entity = [NSEntityDescription entityForName:@"FoodRating" inManagedObjectContext:context];
    
    request.predicate = [NSPredicate predicateWithFormat:@"place_id = %d AND user_id = %d", [[ratingDictionary objectForKey:@"place_id"] intValue],[[ratingDictionary objectForKey:@"user_id"] intValue]];
    
    NSError *executeFetchError = nil;
    NSArray* foodratings = [context executeFetchRequest:request error:&executeFetchError];
    if (foodratings.count>0) {
        foodrating = [foodratings objectAtIndex:0];
    }
    
    if (executeFetchError) {
        
    } else if (!foodrating) {
        //found new rating...gotta find out which place it belongs to
        foodrating = [NSEntityDescription insertNewObjectForEntityForName:@"FoodRating"
                                                   inManagedObjectContext:context];
        
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSDate *serverDate = [format dateFromString:[ratingDictionary objectForKey:@"updated_at"]];
    [foodrating setValue:serverDate forKey:@"updated_at"];
    
    NSLog(@"setting uploaded at date to %@",updatedDate);
    foodrating.uploaded_at = updatedDate;
    foodrating.item_id = [NSNumber numberWithInt:[[ratingDictionary objectForKey:@"id"] intValue]];
    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }else{
        NSLog(@"saved new rating up to the server");
    }
    
    
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


@end
