//
//  StopsMapViewController.m
//  UMBus
//
//  Created by Enea Gjoka on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StopsMapViewController.h"
#import "SSMapAnnotation.h"
#import "SpecialStopViewController.h"

@implementation StopsMapViewController

@synthesize myMap,stops,xmlData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        stops = [[NSMutableArray alloc] init];
        xmlData = [[NSData alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [xmlData release];
    [myMap release];
    [super dealloc];
}


- (IBAction)popMe
{
    //[self.navigationController popViewControllerAnimated:YES];
    //[self dismissModalViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //[self zoomToFitMapAnnotations:myMap];
    
    /*
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta=0.007;
    span.longitudeDelta=0.007;
    
    CLLocationCoordinate2D location =  myMap.userLocation.location.coordinate;
    
    if (!location.latitude) {
        location = myMap.userLocation.location.coordinate;
    }
    
    region.span=span;
    region.center=location;
    
    [myMap setRegion:region animated:TRUE];
    [myMap regionThatFits:region];
     */
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [myMap setCenterCoordinate: userLocation.location.coordinate
                             animated: YES];
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta=0.007;
    span.longitudeDelta=0.007;
    
    region.span=span;
    region.center=userLocation.location.coordinate;
    
    [myMap setRegion:region animated:TRUE];
    [myMap regionThatFits:region];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:@"Local Stops"];
    
    myMap.mapType=MKMapTypeStandard;
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.01;
    span.longitudeDelta=0.01;
    
    CLLocationCoordinate2D location=myMap.userLocation.coordinate;
    region.span=span;
    region.center=location;
    
    for (GDataXMLElement *stop in stops) {
        if ([[stop elementsForName:@"latitude"] count] > 0  && [[stop elementsForName:@"longitude"] count] > 0) {
            location.latitude = [[[stop elementsForName:@"latitude"] objectAtIndex:0] floatValue];
            location.longitude = [[[stop elementsForName:@"longitude"] objectAtIndex:0] floatValue];
            
            SSMapAnnotation *stopAnn = [[SSMapAnnotation alloc] initWithCoordinate:location title:[[[stop elementsForName:@"name2"] objectAtIndex:0] stringValue]];
            [myMap addAnnotation:stopAnn];
        }
    }
    
    
    
    //[myMap setRegion:region animated:TRUE];
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
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, [(id <MKAnnotation>)annotation coordinate].longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, [(id <MKAnnotation>)annotation coordinate].latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, [(id <MKAnnotation>)annotation coordinate].longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, [(id <MKAnnotation>)annotation coordinate].latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

-(void)stopDetail:(id)sender
{
    NSError *error;
    GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:xmlData 
                                                            options:0 error:&error] retain];
    
    
    SpecialStopViewController *detailViewController = [[SpecialStopViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [detailViewController setStopName:[sender titleForState:UIControlStateNormal]];
    
    NSMutableArray *tempArray = (NSMutableArray*)[doc nodesForXPath:[NSString stringWithFormat:@"//stop[name2='%@']/..",[sender titleForState:UIControlStateNormal]] error:nil];
    
    [detailViewController setStops:tempArray];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    
    MKPinAnnotationView *annotationView; 
    
	
	if ([annotation class] == [MKUserLocation class] ) { 
		NSLog(@"Detected UserLocationAnnotation"); 
        annotationView = (MKPinAnnotationView *)[mapView viewForAnnotation:annotation]; 
	} else { 
        // Do other stuff for custom Annotation 
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
        annotationView.pinColor = MKPinAnnotationColorRed;
        UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [myDetailButton addTarget:self action:@selector(stopDetail:) forControlEvents:UIControlEventTouchUpInside];
        myDetailButton.frame = CGRectMake(0, 0, 23, 23);
        [myDetailButton setTitle:[annotation title] forState:UIControlStateNormal];
        // Set the button as the callout view
        annotationView.rightCalloutAccessoryView = myDetailButton;
        
        annotationView.canShowCallout = YES;
        annotationView.calloutOffset = CGPointMake(-5, 5);
    }
	return annotationView;
}


-(void)setStops:(NSMutableArray *)tStops
{
    stops = [tStops retain];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
