//
//  StopViewController.m
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StopViewController.h"
#import "Stop.h"
#import "XPathQuery.h"
#import "HGMapPath.h"
#import "HGMovingAnnotation.h"
#import "HGMovingAnnotationView.h"
#import "CSRouteAnnotation.h"

@implementation StopViewController
@synthesize stop,myMap,timeToStop,stopTitle,routeID,routeName,mapData;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithStop:(GDataXMLElement *)tStop andRouteName:(NSString *)rName andRouteID:(int)rID{
   
    if ((self = [super init])) 
	{
        stop = [tStop retain];
        routeName = [rName retain];
		routeID = [[NSNumber numberWithInt:rID] retain];
        busLocation = [[SSMapAnnotation alloc] init];
        [busLocation setTitle:@"theBus"];
        // dictionary to keep track of route views that get generated. 
        _routeViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//[self updateMap:nil];
    myMap.mapType=MKMapTypeStandard;
	[stopTitle setText:[[[stop elementsForName:@"name"] objectAtIndex:0] stringValue]];
    [[self navigationItem] setTitle:routeName];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.01;
    span.longitudeDelta=0.01;
    
    CLLocationCoordinate2D location=myMap.userLocation.coordinate;
    
    location.latitude = [[[stop elementsForName:@"latitude"] objectAtIndex:0] floatValue];
    location.longitude = [[[stop elementsForName:@"longitude"] objectAtIndex:0] floatValue];
    
    region.span=span;
    region.center=location;
    
    SSMapAnnotation *stopAnn = [[SSMapAnnotation alloc] initWithCoordinate:location title:[[[stop elementsForName:@"name"] objectAtIndex:0] stringValue]];
    [myMap addAnnotation:stopAnn];

    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(updateMap:) userInfo:nil repeats:NO];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://mbus.pts.umich.edu/shared/map_trace_route_%i.xml",[routeID intValue]]]
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    TTURLConnection *imageConnection = [[TTURLConnection alloc] initWithRequest:imageRequest delegate:self];
    [imageConnection setIdentifier:@"mapPath"];
    
	
}


- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
    TTURLConnection* ttConnection = (TTURLConnection*)connection;
    ttConnection.response = response;
    ttConnection.responseData = [NSMutableData dataWithCapacity:[response expectedContentLength]];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    TTURLConnection* ttConnection = (TTURLConnection*)connection;
    [ttConnection.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    TTURLConnection* ttConnection = (TTURLConnection*)connection;
    
    if (ttConnection.response.statusCode == 200 && [[ttConnection identifier] compare:@"mapPath"] == NSOrderedSame)
    {
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:ttConnection.responseData options:0 error:&error];
        NSString *xString = [NSString stringWithFormat:@"//histdata/item"];
        NSArray *tempStop = [[doc nodesForXPath:xString error:&error] retain];
        NSMutableArray* points = [[NSMutableArray alloc] init];
        
        for(GDataXMLElement *temp in tempStop)
        {
            CLLocationDegrees latitude  = [[[temp elementsForName:@"latitude"] objectAtIndex:0] floatValue];
            CLLocationDegrees longitude = [[[temp elementsForName:@"longitude"] objectAtIndex:0] floatValue];
            
            CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
            [points addObject:currentLocation];
            
        }
        
        // first create the route annotation, so it does not draw on top of the other annotations. 
        CSRouteAnnotation* routeAnnotation = [[[CSRouteAnnotation alloc] initWithPoints:points] autorelease];
        [myMap addAnnotation:routeAnnotation];
    }
    else if (ttConnection.response.statusCode == 200 && [[ttConnection identifier] compare:@"mapPathBus"] == NSOrderedSame)
    {
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:ttConnection.responseData options:0 error:&error];
        
        NSString *xString = [NSString stringWithFormat:@"//livefeed/route[name='%@']/stop[name='%@']",routeName,[[[stop elementsForName:@"name"] objectAtIndex:0] stringValue]];
        
        if([[doc nodesForXPath:xString error:&error] count] > 0)
        {
            GDataXMLElement *tempStop = [[[doc nodesForXPath:xString error:&error] objectAtIndex:0] retain];
            xmlData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/location_feed.xml"]];
            NSDictionary *tempDict = [[self minValue:tempStop] retain];
            
            if(tempDict != nil)
            {
                float min = [[tempDict objectForKey:@"value"] floatValue];
                NSString *mID = (NSString*)[tempDict objectForKey:@"mID"];
                
                [timeToStop setText:[NSString stringWithFormat:@"%.02f Minutes Until Next Bus to",min/60.00f]];
                
                [tempStop release];
                //Track the bus
                
                //First get bus data
                doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
                
                //Set up map variables
                MKCoordinateRegion region;
                MKCoordinateSpan span;
                span.latitudeDelta=0.01;
                span.longitudeDelta=0.01;
                CLLocationCoordinate2D location=myMap.userLocation.coordinate;
                
                //Get lat and long from xml
                xString = [NSString stringWithFormat:@"//livefeed/item[id='%@']/latitude",mID];
                float latitude = [[[doc nodesForXPath:xString error:&error] objectAtIndex:0] floatValue];
                
                xString = [NSString stringWithFormat:@"//livefeed/item[id='%@']/longitude",mID];            
                float longitude = [[[doc nodesForXPath:xString error:&error] objectAtIndex:0] floatValue];
                
                //Set all necessary variables up
                location.latitude = latitude;
                location.longitude = longitude;
                region.span=span;
                region.center=location;
                
                if (busLocation.coordinate.latitude != location.latitude && busLocation.coordinate.longitude != location.longitude) {
                    [myMap removeAnnotation:busLocation];
                    [busLocation setCoordinate:location];
                    [myMap addAnnotation:busLocation];
                    
                    [self zoomToFitMapAnnotations:myMap];
                }
                
                
                
                [doc release];
            }
            
            [tempDict release];
        }
        else
        {
            [timeToStop setText:@"No Buses Running or Error"];
        }
        
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateMap:) userInfo:nil repeats:NO];
    }
    
    [ttConnection release];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {  
    TTURLConnection* ttConnection = (TTURLConnection*)connection;
    // Handle the error
    
    [ttConnection release];
    
    NSLog(@"Connection failed! Error - %@ %@",
          
          [error localizedDescription],
          
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
}


-(NSMutableDictionary *)minValue:(GDataXMLElement *)tempStop
{
    NSMutableArray *toas = [[NSMutableArray alloc] init];
    int count = [[[tempStop elementsForName:@"toacount"] objectAtIndex:0] intValue];
    
    for (int i = 0; i < count; i++) 
    {
        float someNum = [[[[tempStop elementsForName:[NSString stringWithFormat:@"toa%i",i+1]] objectAtIndex:0] stringValue] floatValue];
        int mNum = [[[tempStop elementsForName:[NSString stringWithFormat:@"id%i",i+1]] objectAtIndex:0] intValue];
        
            NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:someNum],@"value"
                                      ,[NSNumber numberWithInt:mNum],@"mID",nil];
            [toas addObject:tempDict];
    }
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES ];
    [toas sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
    
    if ([toas count] > 0) 
    {
        return (NSMutableDictionary *)[toas objectAtIndex:0];
    }
    else
    {
        return nil;
    }
    
}

-(void)updateMap:(NSTimer*)timer
{
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/public_feed.xml"]
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    TTURLConnection *imageConnection = [[TTURLConnection alloc] initWithRequest:imageRequest delegate:self];
    [imageConnection setIdentifier:@"mapPathBus"];
    
}


-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for( NSObject *annotation in mapView.annotations)
    {
        
        
        if(![annotation isKindOfClass:[CSRouteAnnotation class]] &&  [[(id<MKAnnotation>)annotation title] compare:@"movBusRoute"] != NSOrderedSame)
        {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [(id <MKAnnotation>)annotation coordinate].longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [(id <MKAnnotation>)annotation coordinate].latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [(id <MKAnnotation>)annotation coordinate].longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [(id <MKAnnotation>)annotation coordinate].latitude);
        }
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	myTimer = nil;
}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	// turn off the view of the route as the map is chaning regions. This prevents
	// the line from being displayed at an incorrect positoin on the map during the
	// transition. 
	for(NSObject* key in [_routeViews allKeys])
	{
		CSRouteView* routeView = [_routeViews objectForKey:key];
		routeView.hidden = YES;
	}
	
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	// re-enable and re-poosition the route display. 
	for(NSObject* key in [_routeViews allKeys])
	{
		CSRouteView* routeView = [_routeViews objectForKey:key];
		routeView.hidden = NO;
		[routeView regionChanged];
	}
	
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
    MKAnnotationView* annotationView = nil;
    
    if([annotation isKindOfClass:[CSRouteAnnotation class]])
	{
		CSRouteAnnotation* routeAnnotation = (CSRouteAnnotation*) annotation;
		
		annotationView = [_routeViews objectForKey:routeAnnotation.routeID];
		
		if(nil == annotationView)
		{
			CSRouteView* routeView = [[[CSRouteView alloc] initWithFrame:CGRectMake(0, 0, myMap.frame.size.width, myMap.frame.size.height)] autorelease];
            
			routeView.annotation = routeAnnotation;
			routeView.mapView = myMap;
			
			[_routeViews setObject:routeView forKey:routeAnnotation.routeID];
			
			annotationView = routeView;
		}
	}
    else if([annotation coordinate].latitude == [[[stop elementsForName:@"latitude"] objectAtIndex:0] floatValue] && [annotation coordinate].longitude == [[[stop elementsForName:@"longitude"] objectAtIndex:0] floatValue])
    {
        MKPinAnnotationView *pinViewStop = [[MKPinAnnotationView alloc]
                                        initWithAnnotation:annotation reuseIdentifier:@"stopPin"];
        //[pinView setDraggable:YES];
        //[pinViewStop setAnimatesDrop:YES];
        [pinViewStop setPinColor:MKPinAnnotationColorRed];
        pinViewStop.canShowCallout = YES;
        return pinViewStop;
   
	}
    else if([[annotation title] compare:@"theBus"] == NSOrderedSame)
    {
        MKAnnotationView *pinView = [[MKAnnotationView alloc]
                                 initWithAnnotation:annotation reuseIdentifier:@"movBus"];
    
        [pinView setImage:[UIImage imageNamed:@"mbus.png" ]];
    
        return pinView;
    }
    else
    {
        MKAnnotationView *pinView = [[MKAnnotationView alloc]
                                     initWithAnnotation:annotation reuseIdentifier:@"movBusRoute"];
        
        [pinView setImage:[UIImage imageNamed:@"symbol-moving-annotation" ]];
        
        return pinView;
    }

    return annotationView;
    
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (void)dealloc {
    [_routeViews release];
    [myTimer invalidate]; 
	myTimer = nil;
    [myTimer release];
    [routeID release];
    [xmlData release];
    [super dealloc];
}


@end
