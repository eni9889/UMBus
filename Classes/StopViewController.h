//
//  StopViewController.h
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "GDataXMLNode.h"
#import "SSMapAnnotation.h"
#import "CSRouteView.h"
#import "TTURLConnection.h"

@interface StopViewController : UIViewController <MKMapViewDelegate> {

	GDataXMLElement *stop;
	IBOutlet MKMapView *myMap;
	MKPlacemark *mPlacemark;
	MKReverseGeocoder *geoCoder;
	NSTimer *myTimer;
	IBOutlet UILabel *timeToStop;
	IBOutlet UILabel *stopTitle;
    NSNumber *routeID;
    NSString *routeName;
    NSData *xmlData;
    
    SSMapAnnotation *busLocation;
    NSMutableData *mapData;
    
    NSMutableDictionary* _routeViews;
}

@property (nonatomic, retain) GDataXMLElement *stop;
@property (nonatomic, retain) IBOutlet MKMapView *myMap;
@property (nonatomic, retain) IBOutlet UILabel *timeToStop;
@property (nonatomic, retain) IBOutlet UILabel *stopTitle;
@property (nonatomic, retain) IBOutlet NSNumber *routeID;
@property (nonatomic, retain) IBOutlet NSString *routeName;
@property (nonatomic, retain) IBOutlet NSMutableData *mapData;

- (id)initWithStop:(GDataXMLElement *)tStop andRouteName:(NSString *)rName andRouteID:(int)rID;
-(void)updateMap:(NSTimer*)timer;
-(void)zoomToFitMapAnnotations:(MKMapView*)mapView;
-(NSMutableDictionary *)minValue:(GDataXMLElement *)tempStop;

@end
