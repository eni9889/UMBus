//
//  SpecialStopViewController.h
//  UMBus
//
//  Created by Enea Gjoka on 4/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"

@interface SpecialStopViewController : UITableViewController {
    
    GDataXMLElement *stop;
    NSMutableArray *stops;
    NSMutableArray *sortedArray;
    NSTimer *myTimer;
    NSString *stopName;
    UIActivityIndicatorView *loadingData;
    
     NSMutableData *mapData;
}

@property (nonatomic, retain) GDataXMLElement *stop;
@property (nonatomic, retain) NSMutableArray *stops;
@property (nonatomic, retain) NSMutableArray *sortedArray;
@property (nonatomic, retain) NSString *stopName;
@property (nonatomic,retain) UIActivityIndicatorView *loadingData;
@property (nonatomic, retain) IBOutlet NSMutableData *mapData;

-(void)minValue:(NSMutableArray *)tempStops;

@end
