//
//  MIRevealCellDemoTableViewController.m
//  MIRevealTableViewCell
//
//  Created by Masaru Ichikawa on 2012/08/14.
//  Copyright (c) 2012年 Masaru Ichikawa. All rights reserved.
//

#import "MIRevealCellDemoTableViewController.h"
#import "MIRevealTableViewCell.h"

@interface MIRevealCellDemoTableViewController ()<MIRevealTableViewCellDelegate>

@property (nonatomic, retain) MIRevealTableViewCell *activeCell;

@end

@implementation MIRevealCellDemoTableViewController

@synthesize activeCell = _activeCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.activeCell = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.activeCell = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MIRevealTableViewCell *cell = (MIRevealTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MIRevealTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        UILabel *frontLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        frontLabel.text = @"Front view";
        frontLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UILabel *backLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        backLabel.text = @"Back view";
        backLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backLabel.backgroundColor = [UIColor blueColor];
        cell.frontContentView.backgroundColor = [UIColor whiteColor];
        cell.backContentView.backgroundColor = [UIColor blueColor];
        [cell.frontContentView addSubview:frontLabel];
        [cell.backContentView addSubview:backLabel];
        cell.revealCellDelegate = self;
    }
    cell.swipeEnabled = indexPath.row % 2 == 0;
    
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - scroll view delegate 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.activeCell hideBackContentViewAnimated:YES];
}

#pragma mark - reveal cell delegate

- (void)revealTableViewCellDidBeginTouchesCell:(MIRevealTableViewCell*)cell {
    if (cell != self.activeCell) {
        [self.activeCell hideBackContentViewAnimated:YES];
        self.activeCell = nil;
    }    
}

- (void)revealTableViewCellDidShowBackContentView:(MIRevealTableViewCell*)cell {
    self.activeCell = cell;
}

- (void)revealTableViewCellDidHideBackContentView:(MIRevealTableViewCell*)cell {
    self.activeCell = nil;
}


@end
