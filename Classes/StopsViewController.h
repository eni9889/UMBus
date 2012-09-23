//
//  StopsViewController.h
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMBusAppDelegate.h"
#import "Route.h"
#import "GDataXMLNode.h"

@interface StopsViewController : UITableViewController {
	
	NSArray *stops;
	NSTimer *myTimer;
	GDataXMLElement *myRoute;
	UIActivityIndicatorView *loadingData;
}

@property (nonatomic, retain) NSArray *stops;
@property (nonatomic, retain) GDataXMLElement *myRoute;
-(NSMutableDictionary *)minValue:(GDataXMLElement *)tempStop;
@end
