//
//  DataViewController.m
//  UMBus
//
//  Created by Enea Gjoka on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataViewController.h"
#import "XPathQuery.h"
#import "Route.h"
#import "Stop.h"
#import "StopsViewController.h"
#import "GDataXMLNode.h"
#import "SpecialStopViewController.h"

@implementation DataViewController

@synthesize tRoutes,loadingData,localStops,xmlData;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	loadingData = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
	
	// Create and configure the segmented control
	sortToggle = [[UISegmentedControl alloc]
									  initWithItems:[NSArray arrayWithObjects:@"Routes",
													@"Stops", nil]];
	sortToggle.segmentedControlStyle = UISegmentedControlStyleBar;
	sortToggle.selectedSegmentIndex = 1;
	[sortToggle addTarget:self action:@selector(toggleSorting:)
		 forControlEvents:UIControlEventValueChanged];
	    
	[self.navigationItem setTitleView:sortToggle];
    
    [self emptyTable];
	[loadingData startAnimating];
    
    [sortToggle setUserInteractionEnabled:NO];
    
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/public_feed.xml"]
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    
    NSURLConnection *imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self];
    
    if(imageConnection)
    {
        xmlData = [[NSMutableData data] retain];
    }
    
    
	//[NSThread detachNewThreadSelector:@selector(loadStops) toTarget:self withObject:nil];
    
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    [xmlData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    [self loadStops];
    [sortToggle setUserInteractionEnabled:YES];
    [connection release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error

{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [xmlData release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
}


//Action method executes when user touches the button
- (void)toggleSorting:(id)sender{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	if([segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]] == @"Routes")
	{
        [self loadRoutes];
		[self.tableView reloadData];
	}
    else if ([segmentedControl titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]] == @"Stops")
    {
        [self loadStops];
		[self.tableView reloadData];
    }
	
} 

-(void)emptyTable
{
	tRoutes = [[NSMutableArray alloc] init];
	[self.tableView reloadData];
}

-(void)loadStops
{    

    tRoutes = [[NSMutableArray alloc] init];
    NSError *error;
    GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:xmlData 
                                                            options:0 error:&error] retain];
    
    tRoutes = (NSMutableArray*)[[doc nodesForXPath:@"//stop" error:nil] retain];
    
    NSArray *tempArray = [NSArray arrayWithArray:(NSArray *)tRoutes];
    
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    
    for(GDataXMLElement *myRoute in tempArray)
    {
        if([[[myRoute elementsForName:@"toacount"] objectAtIndex:0] intValue] == 0)
        {
            [tRoutes removeObject:myRoute];
        } else
        {
            [temp setObject:myRoute forKey:[[[myRoute elementsForName:@"name2"] objectAtIndex:0] stringValue]];
        }
        
    }
    
    [tRoutes removeAllObjects];
    
    for(NSString *tString in [temp allKeys])
    {
        [tRoutes addObject:[temp objectForKey:tString]];
    }
    
    [tRoutes sortUsingSelector:@selector(compareUsingName:)];
    [doc release];
	[loadingData stopAnimating];
	[self.tableView reloadData];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [button setImage:[UIImage imageNamed:@"iphone-map.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(loadMap:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
    
    [item release];
    [button release];
}

-(void)loadMap:(id)sender
{
    if (localStops == nil) {
        localStops = [[StopsMapViewController alloc] init];
        [localStops setStops:tRoutes];
        [localStops setXmlData:xmlData];
    }
    
    //Flip Animation    
    [self.navigationController pushViewController:localStops animated:YES];

}

-(void)loadRoutes
{
    self.navigationItem.rightBarButtonItem = nil;
    
    tRoutes = [[NSMutableArray alloc] init];    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error;
    GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:xmlData 
                                                            options:0 error:&error] retain];
    tRoutes = (NSMutableArray*)[[doc.rootElement elementsForName:@"route"] retain];
    [tRoutes sortUsingSelector:@selector(compareUsingName:)];
    
    [self.tableView reloadData];
    [doc release];
	[loadingData stopAnimating];
	[self.tableView reloadData];
    [pool release];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	//[[self navigationItem] setTitle:@"UMBus"];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
	if ([tRoutes count] == 0) 
	{
		return 1;
	}
	else {
		return [tRoutes count];
	}

	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	if ([tRoutes count] == 0) {
		
		[[cell textLabel] setText:nil];
		[loadingData setCenter:CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2)];
		[loadingData setHidesWhenStopped:YES];
		[cell addSubview:loadingData];
		[loadingData startAnimating];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	else {
		//[[cell textLabel] setText:[[tRoutes objectAtIndex:indexPath.row] routeName]];
		
        if ([sortToggle selectedSegmentIndex] == 0) {
            [[cell textLabel] setText:[[[[tRoutes objectAtIndex:indexPath.row] elementsForName:@"name"] objectAtIndex:0] stringValue]];
            [[cell detailTextLabel] setText:nil];
        }
        else
        {
            [[cell textLabel] setText:[[[[tRoutes objectAtIndex:indexPath.row] elementsForName:@"name"] objectAtIndex:0] stringValue]];
            [[cell detailTextLabel] setText:[[[[tRoutes objectAtIndex:indexPath.row] elementsForName:@"name2"] objectAtIndex:0] stringValue]];
        }
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

   
    // Configure the cell...
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    if([sortToggle selectedSegmentIndex] == 0)
    {
        StopsViewController *detailViewController = [[StopsViewController alloc] initWithStyle:UITableViewStylePlain];
        [detailViewController setMyRoute:[tRoutes objectAtIndex:indexPath.row] ];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
    else
    {
        NSError *error;
        GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:xmlData 
                                                                options:0 error:&error] retain];
        
        
        SpecialStopViewController *detailViewController = [[SpecialStopViewController alloc] initWithStyle:UITableViewStylePlain];
        
        [detailViewController setStopName:[[[[tRoutes objectAtIndex:indexPath.row] elementsForName:@"name2"] objectAtIndex:0] stringValue]];
        
        NSMutableArray *tempArray = (NSMutableArray*)[doc nodesForXPath:[NSString stringWithFormat:@"//stop[name2='%@']/..",[[[[tRoutes objectAtIndex:indexPath.row] elementsForName:@"name2"] objectAtIndex:0] stringValue]] error:nil];

        //NSLog(@"Arry being passed is: %@", tempArray);
        
        [detailViewController setStops:tempArray];
        
        //Flip Animation
        //detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[self.navigationController presentModalViewController:detailViewController animated:YES];

        
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
    
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {

    [localStops release];
    [sortToggle release];
	[loadingData release];
	[tRoutes release];
    [xmlData release];
    [super dealloc];
}


@end

