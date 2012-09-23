//
//  UMBusAppDelegate.m
//  UMBus
//
//  Created by Enea Gjoka on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UMBusAppDelegate.h"
#import "DataViewController.h"
#import "FavoriteStopsViewController.h"

@implementation UMBusAppDelegate

@synthesize window,tabController,dataView,favView;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	NSMutableArray *theViews = [[NSMutableArray alloc] init];
	self.tabController = [[UITabBarController alloc] init];
	self.tabController.moreNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
    // Override point for customization after application launch.
    dataView = [[DataViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *routeStopNav = [[UINavigationController alloc] initWithRootViewController:dataView];
	routeStopNav.tabBarItem.title = @"UMBus";
    [routeStopNav.tabBarItem setImage:[UIImage imageNamed:@"55-network.png"]];
	[theViews addObject:routeStopNav];
    
    //FavView
    favView = [[FavoriteStopsViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *favStopNav = [[UINavigationController alloc] initWithRootViewController:favView];
	favStopNav.tabBarItem.title = @"Favorites";
    [favStopNav.tabBarItem setImage:[UIImage imageNamed:@"28-star.png"]];
	[theViews addObject:favStopNav];

	tabController.viewControllers = theViews;
	tabController.delegate = self;
	[window addSubview:[tabController view]];
	
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabController release];
    [favView release];
	[dataView release];
    [window release];
    [super dealloc];
}


@end
