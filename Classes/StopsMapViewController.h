//
//  StopsMapViewController.h
//  UMBus
//
//  Created by Enea Gjoka on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "GDataXMLNode.h"

@interface StopsMapViewController : UIViewController {
    
    IBOutlet MKMapView *myMap;
    NSMutableArray *stops;
    IBOutlet UIButton *closeButton;
    NSData *xmlData;
}

@property (nonatomic, retain) IBOutlet MKMapView *myMap;
@property (nonatomic, retain) NSMutableArray *stops;
@property (nonatomic, retain) NSData *xmlData;

-(void)stopDetail:(id)sender;
-(void)zoomToFitMapAnnotations:(MKMapView*)mapView;
- (IBAction)popMe;

@end
