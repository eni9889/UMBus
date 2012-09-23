//
//  SpecialStopViewController.m
//  UMBus
//
//  Created by Enea Gjoka on 4/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpecialStopViewController.h"
#import "NSString+meltutils.h"

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation SpecialStopViewController

@synthesize stop,sortedArray,stops,stopName,loadingData,mapData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization


    }
    return self;
}

- (void)dealloc
{

    [myTimer invalidate];
	myTimer = nil;
    [loadingData release];
    [sortedArray release];
    [super dealloc];
}

-(void)toggleFav
{
    
    UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:stopName]) {
        
        [tempB setImage:[UIImage imageNamed:@"favL.png"] forState:UIControlStateNormal];
        [tempB addTarget:self action:@selector(toggleFav) forControlEvents:UIControlEventTouchUpInside];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:stopName];
    }
    else
    {
        [tempB setImage:[UIImage imageNamed:@"fav.png"] forState:UIControlStateNormal];
        [tempB addTarget:self action:@selector(toggleFav) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:stopName,stopName, nil] forKey:stopName];
    }
    
    // Create Custom View called myView.
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:tempB];
    self.navigationItem.rightBarButtonItem = customItem;
    [customItem release];
}
-(void)updateInfo:(NSTimer*)timer
{
    [loadingData startAnimating];
    
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/public_feed.xml"]
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    NSURLConnection *imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self];
    
    if(imageConnection)
    {
        mapData = [[NSMutableData data] retain];
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    [mapData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [mapData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSError *error;
    GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:mapData options:0 error:&error] retain];
    
    NSMutableArray *tempArray = (NSMutableArray*)[doc nodesForXPath:[NSString stringWithFormat:@"//stop[name2='%@']/..",[self.navigationItem title]] error:nil];
    
    
    if([tempArray count] > 0)
    {
        [self setStops:tempArray];
    }
    
    myTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateInfo:) userInfo:nil repeats:NO];
    
    
    [connection release];
    
    [mapData release];
    
    [loadingData stopAnimating];
}

- (void)connection:(NSURLConnection *)connection

  didFailWithError:(NSError *)error

{
    
    // release the connection, and the data object
    [connection release];
    
    // receivedData is declared as a method instance elsewhere
    [mapData release];
    
    
    // inform the user
    
    NSLog(@"Connection failed! Error - %@ %@",
          
          [error localizedDescription],
          
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
}


-(void)minValue:(NSMutableArray *)tempStops
{
    NSMutableArray *MAINsortedArray = [[NSMutableArray alloc] init];
    NSError *error;
    
    for(GDataXMLElement *tempStop in tempStops)
    {
        NSString *color= [[[tempStop elementsForName:@"busroutecolor"] objectAtIndex:0] stringValue];
        NSString *routeName = [[[tempStop elementsForName:@"name"] objectAtIndex:0] stringValue];
        int topNode = [[[tempStop elementsForName:@"topofloop"] objectAtIndex:0] intValue];
        NSMutableArray *tempSortedArray = [[NSMutableArray alloc] init];
        
        NSArray *routeTemp = [tempStop nodesForXPath:[NSString stringWithFormat:@"//route[name='%@']/stop",routeName] error:&error];
        
        NSArray *routeStops = [tempStop nodesForXPath:[NSString stringWithFormat:@"//route[name='%@']/stop[name2='%@']",routeName,stopName] error:&error];
        
                
        for(GDataXMLElement *tempS in routeStops)
        {
            int pos = 0;
            for (GDataXMLElement *stopTop in routeTemp) 
            {
                if([[[[stopTop elementsForName:@"name2"] objectAtIndex:0] stringValue] caseInsensitiveCompare:stopName] == NSOrderedSame)
                {
                    break;
                }
                pos++;
            }
                        
            int count = [[[tempS elementsForName:@"toacount"] objectAtIndex:0] intValue];
            
            for (int i = 0; i < count; i++) 
            {
                float someNum = [[[[tempS elementsForName:[NSString stringWithFormat:@"toa%i",i+1]] objectAtIndex:0] stringValue] floatValue];
                
                [tempSortedArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:someNum],@"value",color,@"color",routeName,@"route",[NSNumber numberWithInt:pos],@"pos",[NSNumber numberWithInt:topNode],@"top", nil]];
                
            }
        }
        
        NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES ];
        [tempSortedArray sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
        
        for(int i=0; i < [tempSortedArray count] && i < 2;i++)
        {
            [MAINsortedArray addObject:[tempSortedArray objectAtIndex:i]];
        }
        
        /*
        int count = [[[tempStop elementsForName:@"toacount"] objectAtIndex:0] intValue];
        for (int i = 0; i < count && i < 2; i++) 
        {
            float someNum = [[[[tempStop elementsForName:[NSString stringWithFormat:@"toa%i",i+1]] objectAtIndex:0] stringValue] floatValue];

            
            NSString *xString = [NSString stringWithFormat:@"//livefeed/item[id=%i]/busroutecolor",[[[tempStop elementsForName:[NSString stringWithFormat:@"id%i",i+1]] objectAtIndex:0] intValue] ];
            
            NSString *color= @"ffffff";
            NSString *routeName = @"N/A";
            
            if([[doc nodesForXPath:xString error:&error] count] > 0)
            {
                color = [[[doc nodesForXPath:xString error:&error] objectAtIndex:0] stringValue];
            }
            xString = [NSString stringWithFormat:@"//livefeed/item[id=%i]/route",[[[tempStop elementsForName:[NSString stringWithFormat:@"id%i",i+1]] objectAtIndex:0] intValue] ];
           
            int count = 0;
            int topNode = 0;
            
            if([[doc nodesForXPath:xString error:&error] count] > 0)
            {
                routeName = [[[doc nodesForXPath:xString error:&error] objectAtIndex:0] stringValue];
                
                //NSLog(@"The toa is :%f for route %@",someNum,routeName);
                
                xmlData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/public_feed.xml"]];
                GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:&error];
                
                if([[doc nodesForXPath:[NSString stringWithFormat:@"/livefeed//route[name='%@']/stopcount",routeName] error:nil] count] != 0)
                {
                    int stopCount = [[[doc nodesForXPath:[NSString stringWithFormat:@"/livefeed//route[name='%@']/stopcount",routeName] error:nil] objectAtIndex:0] intValue];
                    topNode = [[[doc nodesForXPath:[NSString stringWithFormat:@"/livefeed//route[name='%@']/topofloop",routeName] error:nil] objectAtIndex:0] intValue];
                    
                    for(int i = 1; i <= stopCount; i++)
                    {
                        NSArray *nodes = [doc nodesForXPath:[NSString stringWithFormat:@"//route[name='%@']/stop[%i]/name2",routeName,i] error:nil];
                        if([nodes count] != 0)
                        {
                            NSString *tempStopName = [[nodes objectAtIndex:0] stringValue];
                            
                            NSString *otherName = [[[tempStop elementsForName:@"name2"] objectAtIndex:0] stringValue];
                            
                            if ( [tempStopName caseInsensitiveCompare:otherName] == NSOrderedSame ) {
                                
                                count = i-1;
                            }
                        }
                    }
                }
            }
                        
            [sortedArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:someNum],@"value",color,@"color",routeName,@"route",[NSNumber numberWithInt:count],@"pos",[NSNumber numberWithInt:topNode],@"top", nil]];
            
            
        }
        */
    }
    
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:YES ];
    [MAINsortedArray sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
    
    sortedArray = [MAINsortedArray retain];;
     
    [self.tableView reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (44.0 + 19.0);
}

-(void)setStops:(NSMutableArray *)tStops
{
    stops = [tStops retain];
    [self minValue:stops];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[self navigationItem] setTitle:stopName];
    myTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateInfo:) userInfo:nil repeats:NO];
    
    loadingData = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingData hidesWhenStopped];
    
    
    UIButton *tempB = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:stopName]) {
        
        [tempB setImage:[UIImage imageNamed:@"fav.png"] forState:UIControlStateNormal];
        [tempB addTarget:self action:@selector(toggleFav) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [tempB setImage:[UIImage imageNamed:@"favL.png"] forState:UIControlStateNormal];
        [tempB addTarget:self action:@selector(toggleFav) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Create Custom View called myView.
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:tempB];
    self.navigationItem.rightBarButtonItem = customItem;
    [customItem release];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [ sortedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    float time = [[[sortedArray objectAtIndex:indexPath.row] objectForKey:@"value"] floatValue]/60.00f;
    NSString *routeLabel = [NSString stringWithFormat:@"%@", [[sortedArray objectAtIndex:indexPath.row] objectForKey:@"route"] ];
    NSString *tLabel = [NSString stringWithFormat:@"Ariving in %.02f min", time];
    
    if (time>0 && time <= 1) 
    {
        tLabel = [NSString stringWithFormat:@"Arriving in less than a minute",routeLabel];
    }
    
    
    [[cell textLabel] setText:routeLabel];
    
    if([[[sortedArray objectAtIndex:indexPath.row] objectForKey:@"pos"] intValue] < [[[sortedArray objectAtIndex:indexPath.row] objectForKey:@"top"] intValue])
    {
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@\nDirection: OUT",tLabel]];
    }
    else
    {
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@\nDirection: IN",tLabel]];
    }
    
    UIColor *tColor = [[[sortedArray objectAtIndex:indexPath.row] objectForKey:@"color"] toUIColor];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    [[cell textLabel] setTextColor:tColor];
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    
    //[[cell textLabel] setBackgroundColor:tColor];
    //[[cell detailTextLabel] setBackgroundColor:tColor];
    //[[cell contentView] setBackgroundColor:tColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
