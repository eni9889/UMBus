//
//  UMBusAppDelegate.h
//  UMBus
//
//  Created by Enea Gjoka on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataViewController;
@class FavoriteStopsViewController;

@interface UMBusAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	UITabBarController *tabController;
	DataViewController *dataView;
    FavoriteStopsViewController *favView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabController;
@property (nonatomic, retain) DataViewController *dataView;
@property (nonatomic, retain) FavoriteStopsViewController *favView;

@end

