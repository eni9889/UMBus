//
//  StopsViewController.m
//  UMBus
//
//  Created by Enea Gjoka on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StopsViewController.h"
#import "Stop.h"
#import "StopViewController.h"

@implementation StopsViewController


#pragma mark -
#pragma mark Initialization

@synthesize stops,myRoute;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        stops = [[NSMutableArray alloc] init];
		myRoute = [[Route alloc] init];
		loadingData = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}



#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
-(void)updateStops
{	
	
	UMBusAppDelegate* delegate = (UMBusAppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate applicationDidBecomeActive:[UIApplication sharedApplication]];
	[self.tableView reloadData];
}
*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	[[self navigationItem] setTitle:[NSString stringWithFormat:@"%@ Stops",[[[myRoute elementsForName:@"name"] objectAtIndex:0] stringValue] ]];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)updateStops
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//stops = [myRoute getStops];
	[self.tableView reloadData];
	[loadingData stopAnimating];
	[pool release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([[myRoute elementsForName:@"stop"] count] == 0) 
	{
		return 1;
	}
	else {
		return [[myRoute elementsForName:@"stop"] count];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (44.0 + 19.0);
}

-(NSMutableDictionary *)minValue:(GDataXMLElement *)tempStop
{
    NSMutableDictionary *bestStops = [[NSMutableDictionary alloc] init];
    [bestStops setValue:[NSNumber numberWithFloat:0.0f] forKey:@"first"];
    [bestStops setValue:[NSNumber numberWithFloat:0.0f] forKey:@"second"];
    
    NSMutableArray *toas = [[NSMutableArray alloc] init];
    int count = [[[[tempStop elementsForName:@"toacount"] objectAtIndex:0] stringValue] intValue];
    for (int i = 0; i < count; i++) 
    {
        float someNum = [[[[tempStop elementsForName:[NSString stringWithFormat:@"toa%i",i+1]] objectAtIndex:0] stringValue] floatValue];
        [toas addObject:[NSNumber numberWithFloat:someNum]];
    }
    
    toas = (NSMutableArray*)[(NSArray*)toas sortedArrayUsingSelector:@selector(compare:)];
    if([toas count] > 0)
    {
        [bestStops setValue:[toas objectAtIndex:0] forKey:@"first"];
    }
    if([toas count] > 1)
    {
        [bestStops setValue:[toas objectAtIndex:1] forKey:@"second"];
    }
    return bestStops;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if ([[myRoute elementsForName:@"stop"] count] == 0 ) {
		
		[[cell textLabel] setText:nil];
		[loadingData setCenter:CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2)];
		[loadingData setHidesWhenStopped:YES];
		[cell addSubview:loadingData];
		[loadingData startAnimating];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	else {
    
    
        NSString * tempName = [[[[[myRoute elementsForName:@"stop"] objectAtIndex:indexPath.row] elementsForName:@"name"] objectAtIndex:0] stringValue];
        NSMutableDictionary *minValues = [self minValue:[[myRoute elementsForName:@"stop"] objectAtIndex:indexPath.row]];
        [[cell textLabel] setText:tempName];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"Next Bus In: %.02f min\n2nd Bus In: %.02f min",[[minValues objectForKey:@"first"] floatValue]/60.00f,[[minValues objectForKey:@"second"] floatValue]/60.00f]];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    
    NSString *routeName = [[[myRoute elementsForName:@"name"] objectAtIndex:0] stringValue];
    int RouteId = [[[myRoute elementsForName:@"id"] objectAtIndex:0] intValue];
    
    StopViewController *detailViewController = [[StopViewController alloc] initWithStop:[[myRoute elementsForName:@"stop"] objectAtIndex:indexPath.row]  andRouteName:routeName andRouteID:RouteId];
    [routeName release];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
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
    [super dealloc];
}


@end

