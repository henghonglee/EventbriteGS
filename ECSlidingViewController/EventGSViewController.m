//
//  EventGSViewController.m
//  Tastebuds
//
//  Created by HengHong on 25/4/13.
//
//
#import "AFNetworking.h"
#import "AFHTTPClient.h"
#import "EventGSViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#import "SorterCell.h"
#import "EndTableCell.h"
#import "RotatingTableCell.h"
#import "touchScrollView.h"

#define sqlUpdateDate @"2013-04-25T08:23:30Z"
#define kMainFont     [UIFont systemFontOfSize:27.0f]
#define kSubtitleFont [UIFont systemFontOfSize:15.0f]
#define kSourceFont [UIFont systemFontOfSize:12.0f]
#define kDistanceFont [UIFont systemFontOfSize:12.0f]
#define kCellHeightConstraint 240
#define kCellSubtitleHeightConstraint 200
#define kCellPaddingLeft 10
#define kCellPaddingTop 5
#define kCellColorBarWidth 11
#define kStarLeftPadding 37
#define kStarTopPadding 10+2
#define kStarHeight 14.75
#define kCellCornerRad 0.0
@interface EventGSViewController ()

@end

@implementation EventGSViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRefreshTable:(id)sender
{
    //retrieve food places and rating
    
    dispatch_async(GSdataSerialQueue, ^{
        [self getEventBriteEvents];
    });
    dispatch_async(GSdataSerialQueue, ^{
        [self prepareData];
    });
    dispatch_async(GSdataSerialQueue, ^{
        [self prepareDataForDisplay];
        self.canSearch = YES;
    });
    
}
-(void)prepareData
{
    NSError *error;
    NSManagedObjectContext *context = [((AppDelegate*)[UIApplication sharedApplication].delegate) managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.returnsObjectsAsFaults = YES;
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event" inManagedObjectContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"start_date > %@",[NSDate date]];
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    [self.loadedGSObjectArray removeAllObjects];
    NSLog(@"fetched = %d objects ",fetchedObjects.count);
    [self.loadedGSObjectArray addObjectsFromArray:fetchedObjects];
    
}
-(void)prepareDataForDisplay
{
    [super prepareDataForDisplay];
}

-(void)getEventBriteEvents
{


    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.eventbrite.com/json/event_search?app_key=IYCRWB5UMZJS6BLRL6&city=San+Francisco&within=1000&within_unit=K&date_modified=Today&count_only=1"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:600.0f];
    NSLog(@"url = %@",url);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFJSONRequestOperation *countoperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* eventsArray = [JSON objectForKey:@"events"];
        NSDictionary* eventSummary = [eventsArray lastObject];
        NSDictionary* summary = [eventSummary objectForKey:@"summary"];
        NSInteger eventcount = [[summary objectForKey:@"total_items"]integerValue];
        NSLog(@"event page count - %d",((int)ceil(eventcount/100.0f)));
        int eventPageCount = ((int)ceil(eventcount/100.0f));

        NSURL *pageRetrieveUrl;
        NSURL *lastPageRetrieveUrl;
        for (int pageNumber=1; pageNumber<eventPageCount+1; pageNumber++) {
            pageRetrieveUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.eventbrite.com/json/event_search?app_key=IYCRWB5UMZJS6BLRL6&city=San+Francisco&within=1000&within_unit=K&max=100&date_modified=Today&page=%d",pageNumber]];
            if (pageNumber == eventPageCount) {
                lastPageRetrieveUrl = pageRetrieveUrl;
            }
            NSLog(@"pageRetrieveUrl = %@",pageRetrieveUrl);
            NSURLRequest *pagerequest = [NSURLRequest requestWithURL:pageRetrieveUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:600.0f];
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:pagerequest success:^(NSURLRequest *pagedrequest, NSHTTPURLResponse *response, id JSON) {
                
                NSArray* eventsArray = [JSON objectForKey:@"events"];
                if (eventsArray.count>0) {
                    //first entry in array is always summary , lets print it out
                    //NSLog(@"Request completed with summary = %@",[eventsArray objectAtIndex:0]);
                }
                dispatch_async(GSdataSerialQueue, ^{
                    NSError *error;
                    NSString* pred;
                    NSManagedObjectContext* context = [((AppDelegate*)[UIApplication sharedApplication].delegate) dataManagedObjectContext];
                    NSError *executeFetchError = nil;
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    NSMutableArray* coreDataEventsArray = [[NSMutableArray alloc]init];
                   
                        
                        for (int j=1; j< eventsArray.count; j++) {

                        if (pred.length==0) {
                            pred = [NSString stringWithFormat:@"item_id == %d", [[[[eventsArray objectAtIndex:j] objectForKey:@"event"] objectForKey:@"id"] intValue]];
                        }else{
                            pred = [pred stringByAppendingFormat:@" OR item_id == %d", [[[[eventsArray objectAtIndex:j] objectForKey:@"event"] objectForKey:@"id" ] intValue]];
                        }
                            request.includesPropertyValues = YES;
                            request.entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:context];
                            request.predicate = [NSPredicate predicateWithFormat:pred];
                            [coreDataEventsArray addObjectsFromArray:[context executeFetchRequest:request error:&executeFetchError]];
                            pred = @"";
                        }
                    NSLog(@"coreDataEventsArray count = %d",coreDataEventsArray.count);
                    for (int e=1; e<eventsArray.count; e++) {
                        NSDictionary* eventItem = [[eventsArray objectAtIndex:e] objectForKey:@"event"];
                        
                        Event *event = nil;
                        NSArray* filteredArray = [coreDataEventsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"item_id == %d", [[eventItem objectForKey:@"id"] intValue]]];
                        
                        if (filteredArray.count > 0) {
                            event = [filteredArray lastObject];
                            
                        }else {
                            event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                                      inManagedObjectContext:context];
                        }
                        
                        
                        
                        
                        
                        NSDateFormatter *format = [[NSDateFormatter alloc] init];
                        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        [event setValue:[format dateFromString:[eventItem objectForKey:@"created"]] forKey:@"created"];
                        [event setValue:[format dateFromString:[eventItem objectForKey:@"modified"]] forKey:@"modified"];
                        [event setValue:[format dateFromString:[eventItem objectForKey:@"end_date"]] forKey:@"end_date"];
                        [event setValue:[format dateFromString:[eventItem objectForKey:@"start_date"]] forKey:@"start_date"];
                        
                        [event setValue:[NSNumber numberWithInt:[[eventItem objectForKey:@"id"] intValue]] forKey:@"item_id"];
                        [event setValue:[NSNumber numberWithInt:[[eventItem objectForKey:@"capacity"] intValue]] forKey:@"capacity"];
                        
                        [event setValue:[eventItem objectForKey:@"logo"] forKey:@"logo_url"];
                        [event setValue:[eventItem objectForKey:@"category"] forKey:@"category"];
                        [event setValue:[eventItem objectForKey:@"title"] forKey:@"title"];
                        [event setValue:[eventItem objectForKey:@"status"] forKey:@"status"];
                        [event setValue:[eventItem objectForKey:@"description"] forKey:@"descriptionHTML"];
                        [event setValue:[eventItem objectForKey:@"tags"] forKey:@"tags"];
                        [event setValue:[eventItem objectForKey:@"logo_ssl"] forKey:@"logo_ssl"];
                        [event setValue:[eventItem objectForKey:@"url"] forKey:@"url"];
                        
                        [event setValue:[NSNumber numberWithBool:[[eventItem objectForKey:@"repeats"] boolValue]] forKey:@"repeats"];
                        
                        NSDictionary* eventVenue = [eventItem objectForKey:@"venue"];
                        double lat = [[eventVenue objectForKey:@"latitude"] doubleValue];
                        double lon = [[eventVenue objectForKey:@"longitude"] doubleValue];
                        [event setValue:[eventVenue objectForKey:@"address"] forKey:@"venue_address"];                        
                        [event setValue:[eventVenue objectForKey:@"city"] forKey:@"venue_city"];
                        [event setValue:[eventVenue objectForKey:@"country"] forKey:@"venue_country"];
                        [event setValue:[NSNumber numberWithDouble:lat] forKey:@"latitude"];
                        [event setValue:[NSNumber numberWithDouble:lon] forKey:@"longitude"];
                        [event setValue:[eventVenue objectForKey:@"name"] forKey:@"venue_name"];
                        [event setValue:[eventVenue objectForKey:@"postal"] forKey:@"venue_postal"];
                        
                        CGSize s = [event.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
                        event.cell_height = [NSNumber numberWithInt:0];
                        event.cell_height = [NSNumber numberWithInt:(event.cell_height.intValue + 10)];
                        event.cell_height = [NSNumber numberWithInt:(event.cell_height.intValue + MAX(30,s.height))];
                        event.cell_height = [NSNumber numberWithInt:(event.cell_height.intValue + 5)];
                        event.cell_height = [NSNumber numberWithInt:(event.cell_height.intValue + 5)];
                        event.cell_height = [NSNumber numberWithInt:(event.cell_height.intValue + 30)];
                        
                        [event setValue:[NSNumber numberWithInt:(event.cell_height.intValue + 10)]forKey:@"cell_height"];
                        
                    }


                        if (![context save:&error]) {
                            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                        }else{
                            NSLog(@"saved");
                        }

                    [coreDataEventsArray removeAllObjects];
                    coreDataEventsArray = nil;
                });
                
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"Page request failed with error = %@",error);
            }];
            [operation start];
            
        }
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"count op failed with error = %@",error);
    }];
    [countoperation start];
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft||orientation == UIInterfaceOrientationLandscapeRight) {
            return nil;
        }else{
            UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 64)];
            [headerView setBackgroundColor:[UIColor clearColor]];
            UIView* searchView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 300, 44)];
            [searchView setBackgroundColor:[UIColor clearColor]];
            
            UIButton* mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [mapButton setBackgroundColor:[UIColor whiteColor]];
            [mapButton setBackgroundImage:[UIImage imageNamed:@"BarMap@2x.png"] forState:UIControlStateNormal];
            [mapButton setFrame:CGRectMake(300-44, 0, 44, 44)];
            [mapButton addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
            [mapButton addTarget:self action:@selector(setBgColorForButton:) forControlEvents:UIControlEventTouchDown];
            [mapButton addTarget:self action:@selector(clearBgColorForButton:) forControlEvents:UIControlEventTouchDragExit];
            
            [searchView addSubview:mapButton];
            
            [headerView addSubview:searchView];
            
            return headerView;
        }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        static NSString *SorterCellIdentifier = @"SorterCell";
        SorterCell* cell = (SorterCell*) [tableView dequeueReusableCellWithIdentifier:SorterCellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SorterCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (SorterCell*)currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                }
            }
        }
        cell.sorterBackgroundView.layer.cornerRadius = 0;
        return cell;
        
    }
    if((self.random && indexPath.row==2) ||(!self.random && indexPath.row == [self.GSObjectArray count]+1)){
        static NSString *EndCellIdentifier = @"EndTableCell";
        EndTableCell* endcell = (EndTableCell*) [tableView dequeueReusableCellWithIdentifier:EndCellIdentifier];
        if (endcell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EndTableCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    endcell = (EndTableCell*)currentObject;
                    endcell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
        }
        endcell.endTableBackgroundView.layer.cornerRadius = 0;
        if([SVProgressHUD isVisible])
        {
            endcell.endTableBackgroundView.hidden = YES;
            endcell.searchImageView.hidden = YES;
            endcell.searchLabel.hidden = YES;
        }else{
            if (self.GSObjectArray.count==0) {
                endcell.endTableBackgroundView.hidden = NO;
                endcell.searchImageView.hidden = NO;
                endcell.searchLabel.hidden = NO;
            }else{
                endcell.endTableBackgroundView.hidden = YES;
                endcell.searchImageView.hidden = YES;
                endcell.searchLabel.hidden = YES;
            }
        }
        return endcell;
    }
    
    Event* gsObj;
    if (self.random) {
        gsObj = [self.GSObjectArray objectAtIndex:self.randomIndex];
    }else{
        gsObj = [self.GSObjectArray objectAtIndex:indexPath.row-1];
    }
    
    NSString *FromCellIdentifier = [NSString stringWithFormat:@"%d",gsObj.cell_height.intValue];
    RotatingTableCell *cell = [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier];
    
    if (cell == nil)
    {
        CGSize s = [gsObj.title sizeWithFont:kMainFont constrainedToSize:CGSizeMake(kCellHeightConstraint, 999) lineBreakMode:NSLineBreakByWordWrapping];
        cell = [[RotatingTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FromCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.mainContainer = [[touchScrollView alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, gsObj.cell_height.intValue)];
        
        [cell.mainContainer setScrollsToTop:NO];
        [cell.mainContainer setContentSize:CGSizeMake(960, gsObj.cell_height.intValue)];
        [cell.mainContainer setContentOffset:CGPointMake(320, 0)];
        [cell.mainContainer setPagingEnabled:YES];
        [cell.mainContainer setBackgroundColor:[UIColor clearColor]];
        [cell.mainContainer setShowsHorizontalScrollIndicator:NO];
        
        cell.imagesView = [[UIView alloc]initWithFrame:CGRectMake(640, 0, cell.bounds.size.width, gsObj.cell_height.intValue)];
        [cell.imagesView setBackgroundColor:[UIColor clearColor]];
        cell.mainImagesBackgroundCellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, gsObj.cell_height.intValue)];
        cell.mainImagesCellView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, cell.bounds.size.width-2*kCellPaddingLeft, gsObj.cell_height.intValue-kCellPaddingTop*2)];
        
        
        float imagewh = (gsObj.cell_height.intValue-kCellPaddingTop*2);
        
            UIImageView* buttonImage = [[UIImageView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, 300, imagewh)];
            [buttonImage setContentMode:UIViewContentModeScaleAspectFit];
            [buttonImage setClipsToBounds:YES];
            [cell.mainImagesBackgroundCellView addSubview:buttonImage];
            [cell.buttonImagesArray addObject:buttonImage];
        
        cell.currentImageIndex =0 ;
        
        
        cell.ratingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, gsObj.cell_height.intValue)];
        [cell.ratingView setBackgroundColor:[UIColor clearColor]];
        
        cell.mainRatingBackgroundCellView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.bounds.size.width, gsObj.cell_height.intValue)];
        cell.mainRatingCellView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, cell.bounds.size.width-2*kCellPaddingLeft, gsObj.cell_height.intValue-kCellPaddingTop*2)];
        
        cell.sourceLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 280, gsObj.cell_height.intValue-30)];
        cell.sourceLabel.backgroundColor = [UIColor clearColor];
        cell.sourceLabel.textColor = [UIColor whiteColor];
        [cell.sourceLabel setFont:kSubtitleFont];
        [cell.sourceLabel setNumberOfLines:0];
        cell.sourceLabel.shadowColor = [UIColor blackColor];
        cell.sourceLabel.shadowOffset = CGSizeMake(1,1);

        [cell.mainTitleView setBackgroundColor:[UIColor clearColor]];
        
        cell.mainCellView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, cell.bounds.size.width-2*kCellPaddingLeft, gsObj.cell_height.intValue-kCellPaddingTop*2)];
        
        cell.colorBarView = [[UIView alloc]initWithFrame:CGRectMake(kCellPaddingLeft, kCellPaddingTop, kCellColorBarWidth, gsObj.cell_height.intValue-kCellPaddingTop*2)];
        [cell.colorBarView setBackgroundColor:[UIColor orangeColor]];
        
        
        
        cell.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kStarLeftPadding,10,kCellHeightConstraint,s.height)];
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.titleLabel.textColor = [UIColor whiteColor];
        [cell.titleLabel setFont:kMainFont];
        [cell.titleLabel setNumberOfLines:0];
        cell.titleLabel.shadowColor = [UIColor blackColor];
        cell.titleLabel.shadowOffset = CGSizeMake(1,1);
        
        cell.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kStarLeftPadding,cell.titleLabel.frame.origin.y+cell.titleLabel.frame.size.height+5,kCellHeightConstraint,20)];
        cell.subTitleLabel.backgroundColor = [UIColor clearColor];
        cell.subTitleLabel.textColor = [UIColor whiteColor];
        [cell.subTitleLabel setFont:kSubtitleFont];
        [cell.subTitleLabel setNumberOfLines:0];
        cell.subTitleLabel.shadowColor = [UIColor blackColor];
        cell.subTitleLabel.shadowOffset = CGSizeMake(1,1);
        
        cell.mainTitleView = [[UIView alloc]initWithFrame:CGRectMake(320, 0, cell.bounds.size.width, gsObj.cell_height.intValue)];
        
        
        
        
        
        [cell.contentView addSubview:cell.mainContainer];
        
        [cell.mainContainer addSubview:cell.imagesView];
        [cell.imagesView addSubview:cell.mainImagesBackgroundCellView];
        [cell.mainImagesBackgroundCellView addSubview:cell.mainImagesCellView];
        [cell.mainImagesBackgroundCellView sendSubviewToBack:cell.mainImagesCellView];
        
        [cell.mainContainer addSubview:cell.ratingView];
        [cell.ratingView addSubview:cell.mainRatingBackgroundCellView];
        [cell.mainRatingBackgroundCellView addSubview:cell.mainRatingCellView];
        [cell.mainRatingBackgroundCellView addSubview:cell.sourceLabel];
        
        
        
        [cell.mainContainer addSubview:cell.mainTitleView];
        [cell.mainTitleView addSubview:cell.mainCellView];
        
        [cell.mainTitleView addSubview:cell.colorBarView];
        
        [cell.mainTitleView addSubview:cell.titleLabel];
        
        
        [cell.mainTitleView addSubview:cell.subTitleLabel];
        
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCell:)];
        [tap setNumberOfTapsRequired:1];
        [cell.mainTitleView addGestureRecognizer:tap];
    }
    if (gsObj.logo_ssl.length>0) {
            [((UIImageView*)[cell.buttonImagesArray objectAtIndex:0]) setImageWithURL:[NSURL URLWithString:gsObj.logo_ssl] placeholderImage:nil];
            ((UIImageView*)[cell.buttonImagesArray objectAtIndex:0]).userInteractionEnabled = YES;
            UITapGestureRecognizer* imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectImage:)];
            [imageTap setNumberOfTapsRequired:1];
            [((UIImageView*)[cell.buttonImagesArray objectAtIndex:0]) addGestureRecognizer:imageTap];
        
    }else{
        for (int i=0; i<cell.buttonImagesArray.count; i++) {
            [((UIImageView*)[cell.buttonImagesArray objectAtIndex:i]) setImage:nil];
        }
    }
    [cell.mainContainer setTag:indexPath.row];
    cell.titleLabel.text = gsObj.title;
    [cell.sourceLabel setText:[NSString stringWithFormat:@"Address: %@, %@ , %@, %@",gsObj.venue_name,gsObj.venue_address,gsObj.venue_city,gsObj.venue_country]];

    NSDate *lastDate = gsObj.start_date;
    NSDate *todaysDate = [NSDate date];
    NSTimeInterval lastDiff = [lastDate timeIntervalSinceNow];
    NSTimeInterval todaysDiff = [todaysDate timeIntervalSinceNow];
    NSTimeInterval dateDiff = lastDiff - todaysDiff;
    
    [cell.subTitleLabel setText:[NSString stringWithFormat:@"Starts in %d days", ((int)floor(dateDiff/86400.0f))]];
    
    
    
    
    
    cell.mainImagesCellView.alpha = 0.3f;
    cell.mainImagesCellView.backgroundColor = [UIColor blackColor];
    
    cell.mainRatingCellView.alpha = 0.3f;
    cell.mainRatingCellView.backgroundColor = [UIColor blackColor];
    
    cell.mainCellView.alpha = 0.3f;
    cell.mainCellView.backgroundColor = [UIColor blackColor];
    
    cell.mainCellView.layer.cornerRadius = 0;
    
    
    
    return cell;
    
    
    
}
@end
