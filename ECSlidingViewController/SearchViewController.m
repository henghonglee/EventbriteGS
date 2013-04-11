//
//  SearchViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 24/1/13.
//
//
#import "FoodType.h"
#import "SearchCell.h"
#import "GeoScrollViewController.h"
#import "SearchViewController.h"
#import "Trie.h"
#import "TrieNode.h"
@interface SearchViewController ()

@end

@implementation SearchViewController

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
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rsTableView.scrollsToTop = NO;
    
    self.resultList = [[NSMutableArray alloc]init];
    self.shopResultList = [[NSMutableArray alloc]init];
    self.suggestedFood = [NSMutableDictionary dictionary];
    
    if (!serialQueue)
        serialQueue = dispatch_queue_create("com.example.MyQueue", NULL);
    dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeGradient];
    });

}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:self.searchTF];
    self.view.opaque = YES;
   self.view.backgroundColor = [UIColor clearColor];
    self.searchState = kStateSelectingFood;
    self.finalSearchString = @"";
    [self.underMapView setRegion:self.searchRegion animated:YES];
    
    
    dispatch_async(serialQueue, ^{
        for (FoodPlace* gsobj in self.dataArray) {
            //check if data is within search area
            if([self coordinate:CLLocationCoordinate2DMake(gsobj.latitude.doubleValue, gsobj.longitude.doubleValue) ContainedinRegion:self.searchRegion])
            {
                for (FoodType* foodtype in gsobj.foodtypes) {
                    if ([self.suggestedFood objectForKey:[NSString stringWithFormat:@"type=%@",foodtype.type]]) {
                        [self.suggestedFood setObject:[NSNumber numberWithInt:(((NSNumber*)[self.suggestedFood objectForKey:[NSString stringWithFormat:@"type=%@",foodtype.type]]).intValue + 1)] forKey:[NSString stringWithFormat:@"type=%@",foodtype.type]];
                    }else{
                        [self.suggestedFood setObject:[NSNumber numberWithInt:1] forKey:[NSString stringWithFormat:@"type=%@",foodtype.type ]];
                        
                    }
                    
                }
            }
        }
        [self.resultList addObjectsFromArray:self.suggestedFood.allKeys];
        self.initialArray = [NSArray arrayWithArray:self.suggestedFood.allKeys];
        for (FoodPlace* gsobj in self.dataArray) {
            [self.suggestedFood setObject:[NSString stringWithFormat:@"%.01f km",(gsobj.distance_in_meters.doubleValue)/1000.0f] forKey:gsobj.title];
        }
        [self.resultList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rsTableView reloadData];
            [SVProgressHUD dismiss];
        });
        
    });
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.searchTF becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    free(serialQueue);
    [self.searchTF resignFirstResponder];
    [super viewWillDisappear:animated];
}

-(void)doSearch
{
    [self.delegate searchViewControllerDidFinishWithSearchString:[self.finalSearchString stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
    [self dismissModalViewControllerAnimated:NO];

}
-(IBAction)cancelSearch:(id)sender
{
    NSLog(@"cancelling search");
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [sender setBackgroundColor:[UIColor whiteColor]];
    });
    
    self.finalSearchString = @"";
    [self.delegate searchViewControllerDidFinishWithSearchString:[self.finalSearchString stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
    [self dismissModalViewControllerAnimated:NO];
      
    
}
-(void)textFieldTextDidChange{
    if ([self.searchTF.text isEqualToString:@""]) {
        NSLog(@"empty string");
        [self.resultList removeAllObjects];
        [self.resultList addObjectsFromArray:self.initialArray];
        [self.shopResultList removeAllObjects];
        [self.rsTableView reloadData];
    }else{
        dispatch_async(serialQueue, ^{
             dispatch_async(dispatch_get_main_queue(), ^{
            [self.resultList removeAllObjects];
            [self.shopResultList removeAllObjects];
            NSString* searchTerm = self.searchTF.text;
            
            for (NSString* suggestedFood in self.suggestedFood.allKeys)
            {
                if(([searchTerm caseInsensitiveCompare:suggestedFood] == NSOrderedSame || [suggestedFood rangeOfString:searchTerm options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound))
                {
                    if ([[self.suggestedFood objectForKey:suggestedFood] isKindOfClass:[NSNumber class]])
                    {
                        if (![self.resultList containsObject:suggestedFood])
                        {
                            [self.resultList addObject:suggestedFood];
                        }
                        
                    }
                    else
                    {
                        if (![self.shopResultList containsObject:suggestedFood])
                        {
                            [self.shopResultList addObject:suggestedFood];
                        }
                    }
                }
            }
                [self.resultList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                [self.rsTableView reloadData];
                [self.rsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            });
        });
    }
}

-(void)searchLocationDataSet
{
    [self.resultList removeAllObjects];
    NSString* searchTerm = self.searchTF.text;

    for (NSString* term in [searchTerm componentsSeparatedByString:@" "]) {

        if (self.resultList.count ==0){
            NSMutableArray* shortlist = [[NSMutableArray alloc]init];
            for (NSString* suggestedLoc in self.suggestedLocations) {
                if(([term caseInsensitiveCompare:suggestedLoc] == NSOrderedSame || [suggestedLoc rangeOfString:term options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound)){

                    [shortlist addObject:suggestedLoc];
                }
            }
            
            [self.resultList addObjectsFromArray:shortlist];
        }else{
            NSMutableArray* shortlist = [[NSMutableArray alloc]init];
            for (NSString* suggestedLoc in self.suggestedLocations) {
                if(([term caseInsensitiveCompare:suggestedLoc] == NSOrderedSame || [suggestedLoc rangeOfString:term options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound)){
                    [shortlist addObject:suggestedLoc];
                }
            }
            
            NSMutableSet* set1 = [NSMutableSet setWithArray:self.resultList];
            NSMutableSet* set2 = [NSMutableSet setWithArray:shortlist];
            [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
            [self.resultList removeAllObjects];
            [self.resultList addObjectsFromArray:[set1 allObjects]];
        }
    }

    
    [self.rsTableView reloadData];

}

-(void)searchFoodDataSet{
    
    
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchTF resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (self.resultList.count>0) {
        [self.delegate searchViewControllerDidFinishWithSearchString:[[self.resultList objectAtIndex:0] stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
    }else if(self.shopResultList.count>0){
        [self.delegate searchViewControllerDidFinishWithSearchString:[[self.shopResultList objectAtIndex:0] stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
    }else{
        [self.delegate searchViewControllerDidFinishWithSearchString:[NSString stringWithFormat:@"addr=%@",[self.searchTF.text stringByReplacingOccurrencesOfString:@"type=" withString:@""]]];
    }
    [self dismissModalViewControllerAnimated:NO];
    return YES;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    SearchCell *cell = (SearchCell*)[tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    UITableViewCell* tableCell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ListingCell"];
    switch (indexPath.section) {
        case 0:
            if (self.resultList.count==0) {
                tableCell.textLabel.text = [NSString stringWithFormat:@"Search addresses for \"%@\" ",self.searchTF.text];
                tableCell.detailTextLabel.text = @"";
                tableCell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0f];
                tableCell.contentView.backgroundColor = [UIColor whiteColor];
                tableCell.contentView.alpha = 0.8;
                return tableCell;
            }
            
            if([self.finalSearchString rangeOfString:[NSString stringWithFormat:@"%@",[self.resultList objectAtIndex:indexPath.row]]].location != NSNotFound)
            {
                cell.indicatorImage.hidden = NO;
            }
            else
            {
                cell.indicatorImage.hidden = YES;
            }
            cell.titleLabel.text = [[self.resultList objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"type=" withString:@""];
            cell.subTitleLabel.text = [NSString stringWithFormat:@"%@ listings",[(NSMutableDictionary*)self.suggestedFood objectForKey:[self.resultList objectAtIndex:indexPath.row]]];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.contentView.alpha = 0.8;
            return cell;
            
            break;
        case 1:
            tableCell.textLabel.text = [self.shopResultList objectAtIndex:indexPath.row];
            tableCell.detailTextLabel.text = [self.suggestedFood objectForKey:[self.shopResultList objectAtIndex:indexPath.row]];            
            tableCell.contentView.backgroundColor = [UIColor whiteColor];
            tableCell.contentView.alpha = 0.8;

            return tableCell;
            break;
        default:
            return tableCell;
            break;
    }
        
    
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (self.resultList.count == 0) {
                return 1;
            }else{
                return [self.resultList count];
            }
            break;
        case 1:
           return [self.shopResultList count];
            break;

        default:
            break;
    }
    return 0 ;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if ([self.resultList count]>0){
                return 40;
            }else{
                return 0;
            }
            break;
        case 1:
            if ([self.shopResultList count]>0)
                return 40;
            break;
        default:
            
            break;
    }
    return 0;
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UIView* lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 11,40)];
    [lineView setBackgroundColor:[UIColor yellowColor]];
    [headerView setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:headerLabel];
    [headerView addSubview:lineView];    
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12.0f]];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.alpha = 1;
    switch (section) {
        case 0:
            [headerLabel setText:@"FOOD TYPES FOUND IN SEARCH AREA"];
            return headerView;
            
            break;
        case 1:
            [headerLabel setText:[NSString stringWithFormat:@"%d LISTINGS FOUND",[self.shopResultList count]]];
            return headerView;
            break;
        default:
            return [UIView new];
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if ((int)self.searchState == kStateSelectingLocation)
        {
            NSLog(@"selected location");
            
            self.finalSearchString = [self.finalSearchString stringByAppendingFormat:@"addr=%@",[[self.resultList objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
            NSLog(@"searchString = %@",self.finalSearchString);
            self.searchTF.text = @"";
            self.searchState = kStateSelectingFood;
            [self.resultList removeAllObjects];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.searchTF becomeFirstResponder];
        }
        else if ((int)self.searchState == kStateSelectingFood)
        {
            if (self.resultList.count==0) {
                [self.delegate searchViewControllerDidFinishWithSearchString:[NSString stringWithFormat:@"addr=%@",[self.searchTF.text stringByReplacingOccurrencesOfString:@"type=" withString:@""]]];
                self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [self dismissModalViewControllerAnimated:YES];
                return;
            }
            
            self.finalSearchString = [[self.resultList objectAtIndex:indexPath.row]stringByReplacingOccurrencesOfString:@"type=" withString:@""];
            [self.delegate searchViewControllerDidFinishWithSearchString:[self.finalSearchString stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
            self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self dismissModalViewControllerAnimated:YES];
            }
        
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ((int)self.searchState == kStateSelectingLocation)
        {
            NSLog(@"selected location");
            
            self.finalSearchString = [self.finalSearchString stringByAppendingFormat:@"addr=%@",[[self.resultList objectAtIndex:indexPath.row]stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
            NSLog(@"searchString = %@",self.finalSearchString);
            self.searchTF.text = @"";
            self.searchState = kStateSelectingFood;
            [self.resultList removeAllObjects];
            [tableView reloadData];
            [self.searchTF becomeFirstResponder];
        }
        else if ((int)self.searchState == kStateSelectingFood)
        {
            self.finalSearchString = [[self.shopResultList objectAtIndex:indexPath.row]stringByReplacingOccurrencesOfString:@"type=" withString:@""];
            [self.delegate searchViewControllerDidFinishWithSearchString:[self.finalSearchString stringByReplacingOccurrencesOfString:@"type=" withString:@""]];
            self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self dismissModalViewControllerAnimated:YES];

        }
    }
    
}
- (void)didReceiveMemoryWarning
{
    NSLog(@"did recieve memory warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setSearchTF:nil];
    [self setRsTableView:nil];
    [self setUnderMapView:nil];
    [super viewDidUnload];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event.subtype == UIEventSubtypeMotionShake )
    {
        NSLog(@"did shake phone in search view controller.. show instructions for search here");
    }
    
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}


//checks if a point is in the region
-(BOOL)coordinate:(CLLocationCoordinate2D)coord ContainedinRegion:(MKCoordinateRegion)region
{
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    if (
        coord.latitude  >= northWestCorner.latitude &&
        coord.latitude  <= southEastCorner.latitude &&
        
        coord.longitude >= northWestCorner.longitude &&
        coord.longitude <= southEastCorner.longitude
        )
    {
        return YES;
    }else {
        return NO;
    }
}

-(IBAction)setBgColorForButton:(UIButton*)sender
{
    NSLog(@"changing background color");
    [sender setBackgroundColor:[UIColor lightGrayColor]];
}

@end
