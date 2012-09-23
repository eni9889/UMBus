//
//  DataViewController.h
//  UMBus
//
//  Created by Enea Gjoka on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopsMapViewController.h"

@class StopsMapViewController;

@interface DataViewController : UITableViewController {

	NSMutableArray *tRoutes;
	UIActivityIndicatorView *loadingData;
    UISegmentedControl *sortToggle;
    NSMutableData *xmlData;
    StopsMapViewController *localStops;
}

@property (nonatomic,retain) NSMutableArray *tRoutes;
@property (nonatomic,retain) UIActivityIndicatorView *loadingData;
@property (nonatomic,retain) StopsMapViewController *localStops;
@property (nonatomic,retain) NSMutableData *xmlData;

-(void)loadRoutes;
-(void)emptyTable;
-(void)loadStops;
@end
