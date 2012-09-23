//
//  TTURLConnection.m
//  UMBus
//
//  Created by Enea Gjoka on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TTURLConnection.h"


@implementation TTURLConnection

@synthesize response = _response, responseData = _responseData, identifier;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    NSAssert(self != nil, @"self is nil!");
    
    // Initialize the ivars before initializing with the request
    // because the connection is asynchronous and may start
    // calling the delegates before we even return from this
    // function.
    
    self.response = nil;
    self.responseData = nil;
    self.identifier = nil;
    
    self = [super initWithRequest:request delegate:delegate];
    return self;
}

- (void)dealloc {
    [self.response release];
    [self.responseData release];
    [self.identifier release];
    [super dealloc];
}

@end
