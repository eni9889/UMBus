//
//  FavoriteStopsViewController.h
//  UMBus
//
//  Created by Enea Gjoka on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavoriteStopsViewController : UITableViewController {
    
    NSMutableArray *favs;
    NSMutableData *xmlData;
    BOOL dataLoaded;
    UIActivityIndicatorView *loadingData;
}

@property (nonatomic, retain) NSMutableArray *favs;
@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic,retain) UIActivityIndicatorView *loadingData;

@end
