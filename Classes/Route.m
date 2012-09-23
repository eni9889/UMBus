//
//  Route.m
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Route.h"
#import "Stop.h"
#import "XPathQuery.h"

@implementation Route

@synthesize rName, rStops,rID,rTopOfLoop,rBusRouteColor,routeID;

- (id)initRouteWithName:(NSString *)name andStops:(NSArray *)stops andID:(NSString*)ID andTopofLoop:(NSString*)topofloop andColor:(NSString*)color andRouteId:(NSString *)rutID{
	
	if((self = [super init]))
	{
	
		rName = [name retain];
		rStops = [stops retain];
		rID = [ID retain];
		rTopOfLoop = [topofloop retain];
		rBusRouteColor = [color retain];
		routeID = [rutID retain];
        
        [NSThread detachNewThreadSelector:@selector(getStops) toTarget:self withObject:nil];
	}
	return self;
	
}

-(NSString *)routeName
{
	return rName;
}

-(NSArray *)getStops
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (self.rStops == nil) {
		NSData *resultData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/public_feed.xml"]];
		NSMutableArray *routeStops = [[NSMutableArray alloc] init];
		NSArray *stopsResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stopcount",[rID intValue]]);
		int numStops =[(NSString*)[[stopsResults objectAtIndex:0] valueForKey:@"nodeContent"] intValue];
		
		for (int j=0; j < numStops; j++) {
			
			
			NSArray	*stopsNamesResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stop[%i]/name",[rID intValue],j+1]);
			
			NSMutableArray *stopNames = [[NSMutableArray alloc] init];
			
			[stopNames addObject:[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"]];
			stopsNamesResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stop[%i]/name2",[rID intValue],j+1]);
			[stopNames addObject:[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"]];
			
			stopsNamesResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stop[%i]/latitude",[rID intValue],j+1]);
			//NSLog(@"The value is: %@ and its float is: %f",[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"],[(NSString *)[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"] floatValue]);
			
			float lat = (float)[(NSString *)[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"] floatValue];
			
			stopsNamesResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stop[%i]/longitude",[rID intValue],j+1]);
			float lon = (float)[(NSString *)[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"] floatValue];
			
			
			
			NSString *busColor = [[PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/busroutecolor",[rID intValue]]) objectAtIndex:0] valueForKey:@"nodeContent"];
			
			Stop *tStop = [[Stop alloc] stopWithNames:stopNames andToas:nil andRouteId:[NSString stringWithFormat:@"%i",[rID intValue]] andLat:[NSNumber numberWithFloat:lat] andLong:[NSNumber numberWithFloat:lon] andRouteColor:busColor andRouteName:self.rName];
			
			[routeStops addObject:tStop];
			
		}
		
		self.rStops = [routeStops retain];
	}
	[pool release];
	return self.rStops;
}


@end
