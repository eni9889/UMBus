//
//  Route.h
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Route : NSObject {
	
	NSString *rName;
	NSArray *rStops;
	NSString *rID;
	NSString *rTopOfLoop;
	NSString *rBusRouteColor;
	NSString *routeID;

}

@property (nonatomic, retain) NSString *rName;
@property (nonatomic, retain) NSArray *rStops;
@property (nonatomic, retain) NSString *rID;
@property (nonatomic, retain) NSString *rTopOfLoop;
@property (nonatomic, retain) NSString *rBusRouteColor;
@property (nonatomic, retain) NSString *routeID;

-(NSString *)routeName;
-(NSArray *)getStops;
- (id)initRouteWithName:(NSString *)name andStops:(NSArray *)stops andID:(NSString*)ID andTopofLoop:(NSString*)topofloop andColor:(NSString*)color andRouteId:(NSString *)rutID;

@end
