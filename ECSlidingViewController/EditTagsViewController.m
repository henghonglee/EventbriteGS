//
//  EditTagsViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 19/3/13.
//
//

#import "EditTagsViewController.h"

@interface EditTagsViewController ()

@end

@implementation EditTagsViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)awakeFromNib {
    
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.tagTableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString* path = [[NSBundle mainBundle] pathForResource:@"foodtypes"
                                                     ofType:@"txt"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    self.foodtypes = [[NSMutableArray alloc]init];
    [self.foodtypes addObjectsFromArray:[content componentsSeparatedByString:@"\n"]];
    

    [self.tagTableView reloadData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"did recieve memory warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    return self.foodtypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)ttableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [ttableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.foodtypes objectAtIndex:indexPath.row];
    if([self.selectedGSObject.foodTypeArray containsObject:[self.foodtypes objectAtIndex:indexPath.row]])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.selectedGSObject.foodTypeArray containsObject:[self.foodtypes objectAtIndex:indexPath.row]]) {
        [self.selectedGSObject.foodTypeArray removeObject:[self.foodtypes objectAtIndex:indexPath.row]];
    }else{
        [self.selectedGSObject.foodTypeArray addObject:[self.foodtypes objectAtIndex:indexPath.row]];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (void)viewDidUnload {
    [self setTagTableView:nil];
    [super viewDidUnload];
}
@end
