//
//  TTURLConnection.h
//  UMBus
//
//  Created by Enea Gjoka on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TTURLConnection : NSURLConnection {
    
    NSHTTPURLResponse* _response;
    NSMutableData* _responseData;
    NSString *identifier;
}

@property(nonatomic,retain) NSHTTPURLResponse* response;
@property(nonatomic,retain) NSMutableData* responseData;
@property(nonatomic,retain) NSString *identifier;

@end
