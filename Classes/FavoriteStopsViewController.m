//
//  FavoriteStopsViewController.m
//  UMBus
//
//  Created by Enea Gjoka on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FavoriteStopsViewController.h"
#import "GDataXMLNode.h"
#import "SpecialStopViewController.h"

@implementation FavoriteStopsViewController
@synthesize favs,xmlData,loadingData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        dataLoaded = false;
        loadingData = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mbus.pts.umich.edu/shared/public_feed.xml"]
                                                      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
        
        NSURLConnection *imageConnection = [[NSURLConnection alloc] initWithRequest:imageRequest delegate:self];
        
        if(imageConnection)
        {
            xmlData = [[NSMutableData data] retain];
        }
    }
    return self;
}

- (void)dealloc
{
    [favs release];
    [loadingData release];
    [xmlData release];
    [super dealloc];
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
    [self.navigationItem setTitle:@"Favorite Stops"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    [xmlData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    dataLoaded = TRUE;
    [self.tableView reloadData];
    [connection release];
    
}

- (void)connection:(NSURLConnection *)connection

  didFailWithError:(NSError *)error

{
    
    // release the connection, and the data object
    [connection release];
    
    // receivedData is declared as a method instance elsewhere
    [xmlData release];
    
    
    // inform the user
    
    NSLog(@"Connection failed! Error - %@ %@",
          
          [error localizedDescription],
          
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
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

    favs = [[NSMutableArray alloc] init];
    NSLog(@"%@", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]);
    
    for (NSString *tmp in [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]) 
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:tmp] respondsToSelector:@selector(objectForKey:)]) 
        {
            [favs addObject:[[NSUserDefaults standardUserDefaults] objectForKey:tmp]];
        }
        
    }
    
    [self.tableView reloadData];
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

    if (dataLoaded) 
    {
        return [favs count];
    }
    else
    {
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (dataLoaded) 
    {
        [[cell textLabel] setText:[[[favs objectAtIndex:indexPath.row] allKeys] objectAtIndex:0]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else
    {
        [[cell textLabel] setText:nil];
		[loadingData setCenter:CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2)];
		[loadingData setHidesWhenStopped:YES];
		[cell addSubview:loadingData];
		[loadingData startAnimating];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (dataLoaded) 
    {
        NSError *error;
        GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:xmlData 
                                                                options:0 error:&error] retain];
        
        
        SpecialStopViewController *detailViewController = [[SpecialStopViewController alloc] initWithStyle:UITableViewStylePlain];
        
        [detailViewController setStopName:[[[favs objectAtIndex:indexPath.row] allKeys] objectAtIndex:0]];
        
        NSMutableArray *tempArray = (NSMutableArray*)[doc nodesForXPath:[NSString stringWithFormat:@"//stop[name2='%@']/..",[[[favs objectAtIndex:indexPath.row] allKeys] objectAtIndex:0]] error:nil];
        
        //NSLog(@"Arry being passed is: %@", tempArray);
        
        [detailViewController setStops:tempArray];
        
        //Flip Animation
        //detailViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //[self.navigationController presentModalViewController:detailViewController animated:YES];
        
        
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
    
}

@end
