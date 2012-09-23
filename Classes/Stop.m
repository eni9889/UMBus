//
//  Stop.m
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Stop.h"
#import "XPathQuery.h"
#import "SSMapAnnotation.h"

@implementation Stop

@synthesize names,toa,routeID,latitude,longitude,routeColor,routeName;

-(id)stopWithNames:(NSArray *)tNames andToas:(NSArray *)toas andRouteId:(NSString *)rutID andLat:(NSNumber *)lat andLong:(NSNumber *)lon andRouteColor:(NSString *)rColor andRouteName:(NSString *)rName
{
	if((self = [super init]))
	{	
		names = [tNames retain];
		toa = [toas retain];
		routeID = [rutID retain];
		//NSLog(@"My lat is: %f", [lat floatValue]);
		latitude = [[NSNumber numberWithFloat:[lat floatValue]] retain];
		longitude = [[NSNumber numberWithFloat:[lon floatValue]] retain];
		routeColor = [rColor retain];
		routeName = [rName retain];
        Downloading = TRUE;
        [NSThread detachNewThreadSelector:@selector(getToas) toTarget:self withObject:nil];
	}
	return self;
}

-(void)getToas
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if(toa == nil)
    {
        NSData *resultData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/public_feed.xml"]];
        NSArray *stopsNamesResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stop[name='%@']/toacount",[routeID intValue],[names objectAtIndex:0]]);
        int toacount = [[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"] intValue];
        float min = 0.0f;
        
        NSMutableArray *allStopToas = [[NSMutableArray alloc] init];
        
        if (toacount > 0) 
        {
            stopsNamesResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stop[name='%@']/toa%i",[routeID intValue],[names objectAtIndex:0],1]);
            min = [(NSString *)[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"] floatValue];
            
            for(int x = 0; x < toacount; x++)
            {
                stopsNamesResults = PerformXMLXPathQuery(resultData, [NSString stringWithFormat:@"//livefeed/route[id=%i]/stop[name='%@']/toa%i",[routeID intValue],[names objectAtIndex:0],x+1]);
                float toaTemp = [(NSString *)[[stopsNamesResults objectAtIndex:0] valueForKey:@"nodeContent"] floatValue];
                
                [allStopToas addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:toaTemp], @"value", 
                                        [NSString stringWithFormat:@"id%i",x+1], @"id",nil]];
            }
        }
        
        toa = [allStopToas retain];
    }
    [pool release];
}

-(float)minToa
{
    [self getToas];
	NSMutableArray *tempArry = (NSMutableArray *)toa;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES ];
    [tempArry sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
    
    
	float min = [[[tempArry objectAtIndex:0] objectForKey:@"value"] floatValue];
	
	return min;
}

-(float)secToa
{
    [self getToas];
    NSMutableArray *tempArry = (NSMutableArray *)toa;
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES ];
    [tempArry sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
    float min = 0;
    if ([tempArry count] > 1) {
        min = [[[tempArry objectAtIndex:1] objectForKey:@"value"] floatValue];
    }

	return min;

}
@end
