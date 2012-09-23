//
//  Stop.h
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Stop : NSObject {
	
	NSArray *names;
	NSArray *toa;
	NSString *routeID;
	NSNumber *latitude;
	NSNumber *longitude;
	NSString *routeColor;
	NSString *routeName;
    bool Downloading;

}

@property (nonatomic, retain) NSArray *names;
@property (nonatomic, retain) NSArray *toa;
@property (nonatomic, retain) NSString *routeID;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *routeColor;
@property (nonatomic, retain) NSString *routeName;

-(id)stopWithNames:(NSArray *)tNames andToas:(NSArray *)toas andRouteId:(NSString *)rutID andLat:(NSNumber *)lat andLong:(NSNumber *)lon andRouteColor:(NSString *)rColor andRouteName:(NSString *)rName;
-(float)minToa;
-(float)secToa;

@end
