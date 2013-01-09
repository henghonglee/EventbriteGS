#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "DealContentView.h"
#import "DealsViewController.h"
#import "Cell.h"
#import "DealsLayout.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HeaderCell.h"
#import "AFNetworking.h"
#import "UIImage+Resize.h"

#define kMinCouponSize 340.0f
#define kBottomStackHeight 40.0f
#define kOffsetAllowance -70.0f
#define kCouponWidth 280.0f
#define kBottomStackPadding 10.0f
#define kdescriptionheight 30.0f
#define kSeperatorSize 5.0f
#define kLeftRightPadding 10.0f
#define kPaddingBtwElements 5.0f
#define kBottomPadding 10.0f
#define kTopPadding 20.0f
#define kDescriptionFont [UIFont systemFontOfSize:11.0f]
#define kLeftPadding 10.0f
#define kProfileImageSize 30.0f
#define kPaddingBtwElements 5.0f
#define kIndicatorWidthHeight 30.0f
@implementation DealsViewController
@synthesize dealArray,loadedDealArray,gsObject ;
-(void)viewDidLoad
{
    NSLog(@"collectionviewdidload");
    self.collectionView.scrollsToTop = YES;
    self.loadingIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loadingIndicator.frame = CGRectMake(0,0, kBottomStackHeight, kBottomStackHeight);
    self.loadingIndicator.center = CGPointMake(self.collectionView.bounds.size.width/2, self.collectionView.bounds.size.height- kBottomStackHeight/2);
    self.loadingIndicator.hidesWhenStopped = YES;
    NSLog(@"loading indicator frame = %@",NSStringFromCGRect(self.loadingIndicator.frame));
    [self.collectionView addSubview:self.loadingIndicator];
    [self.loadingIndicator startAnimating];
    dealArray = [[NSMutableArray alloc]init];
    
    //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swipeRight:) name:@"popstack" object:nil];
    
    [self.dealArray insertObject:[NSDictionary dictionary] atIndex:0];
    ((DealsLayout*)self.collectionView.collectionViewLayout).cellCount = self.dealArray.count;
    [self.collectionView reloadData];
    
    NSURL* url;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.pouch.sg/v1/deals/recent?deals_only=true&auth_token=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"auth_token"]]];
    NSLog(@"shopdeals url = %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"did return");
        [self processData:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"did fail with error = %@",error);
    }];
    [operation start];
    
    
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.collectionView addGestureRecognizer:tapRecognizer];
    //    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    //    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    //    [self.collectionView addGestureRecognizer:swipeRecognizer];
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"MY_CELL"];
    [self.collectionView registerClass:[HeaderCell class] forCellWithReuseIdentifier:@"HEADER_CELL"];
    
    self.collectionView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}
-(void)swipeRight:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden =YES;
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    self.slidingViewController.underRightViewController = nil;
    self.slidingViewController.anchorLeftPeekAmount     = 0;
    self.slidingViewController.anchorLeftRevealAmount   = 0;
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
}
-(void)processData:(id)JSON
{
    NSLog(@"processing data...");
    for (NSDictionary* dealobject in JSON)
    {
        NSMutableDictionary* mutableDeal = [NSMutableDictionary dictionaryWithDictionary:dealobject];
        [dealArray insertObject:mutableDeal atIndex:[dealArray count]];
    }
    ((DealsLayout*)self.collectionView.collectionViewLayout).cellCount = self.dealArray.count;
    [self.collectionView performBatchUpdates:^{
        NSMutableArray* indexArray = [[NSMutableArray alloc]init];
        for (int i=1; i<[dealArray count]; i++)
        {
            [indexArray addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
        
        [self.collectionView insertItemsAtIndexPaths:indexArray];
    } completion:nil];
    
    ((DealsLayout*)self.collectionView.collectionViewLayout).cellCount = self.dealArray.count;
    ((HeaderCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]).couponCounterView.titleLabel.text = [NSString stringWithFormat:@"%d",dealArray.count-1];
    [self.loadingIndicator stopAnimating];
    
}

#pragma mark SDWebManagerDelegate methods
/*- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url userInfo:(NSDictionary *)info{
 //find out image size and add dealview.
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 float olddivisionratio = image.size.width/600;
 
 CGSize newSize = CGSizeMake(600, image.size.height/olddivisionratio);
 UIImage* newImage = [image resizedImage:newSize interpolationQuality:kCGInterpolationHigh];
 
 
 for (NSMutableDictionary* dealObject in dealArray)
 {
 if([[dealObject objectForKey:@"image_url"]isEqualToString:url.absoluteString])
 {
 float divisionratio = newImage.size.width/300;
 NSNumber* imageHeight = [NSNumber numberWithFloat:newImage.size.height/divisionratio];
 [dealObject setObject:imageHeight forKey:@"imageHeight"];
 [dealObject setObject:newImage forKey:@"image"];
 }
 dispatch_async(dispatch_get_main_queue(), ^{
 [self.collectionView setNeedsDisplay];
 });
 
 }
 });
 
 NSLog(@"recieved image");
 }
 -(void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error forURL:(NSURL *)url userInfo:(NSDictionary *)info
 {
 NSLog(@"failed to get image for deal");
 }
 */



- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    //  ((DealsLayout*)self.collectionView.collectionViewLayout).cellCount = self.dealArray.count;
    return self.dealArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary* selectedDeal = [self.dealArray objectAtIndex:indexPath.row];
    if(indexPath.row ==0){
        HeaderCell* headercell = [cv dequeueReusableCellWithReuseIdentifier:@"HEADER_CELL" forIndexPath:indexPath];
        
        headercell.titleLabel.text = @"title";//self.gsObject.title;
        headercell.likeCounterView.titleLabel.text = @"likecounter";//[NSString stringWithFormat:@"%d",self.gsObject.likes.integerValue];
        headercell.descriptionTextView.text = @"descriptionview";//self.gsObject.description;
        headercell.subtitleLabel.text = @"subtitle";//self.gsObject.subTitle;
        //[headercell.profileImage setImageWithURL:[NSString stringWithFormat:@"http://api.pouch.sg%@",self.gsObject.logourl]];
        //[headercell.cellImage setImageWithURL:[NSString stringWithFormat:@"http://api.pouch.sg%@",self.gsObject.coverurl]];
        //[headercell.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.gsObject.latitude.doubleValue, self.gsObject.longitude.doubleValue), MKCoordinateSpanMake(0.01, 0.01))];
        headercell.addressLabel.text = @"address ";//self.gsObject.addressString;
        headercell.openingLabel.text = @"opening hours";//self.gsObject.openingHoursString;
        headercell.phoneLabel.text = @"phone number ";//self.gsObject.phoneNumber;
        headercell.couponCounterView.titleLabel.text = [NSString stringWithFormat:@"%d",self.dealArray.count-1];
        NSLog(@"returning headercell");
        return headercell;
        
    }else{
        
        Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
        [cell.cellScrollView setDelegate:self];
        cell.descriptionTextView.text = [selectedDeal objectForKey:@"description"];
        
        //[cell.profileImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.pouch.sg%@",self.gsObject.logourl]]];
        [cell.dealImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[selectedDeal objectForKey:@"image_url"]]]];
        [cell.dealImage setContentMode:UIViewContentModeScaleAspectFill];
        cell.dealImage.clipsToBounds = YES;
        //        [cell.dealImage setFrame:CGRectMake(kLeftPadding, kTopPadding+kProfileImageSize*2, self.collectionView.bounds.size.width -2*kLeftPadding, [[selectedDeal objectForKey:@"imageHeight"]floatValue])];
        [cell.dealImage setFrame:CGRectMake(kLeftPadding, kTopPadding+kProfileImageSize*2, self.collectionView.bounds.size.width -2*kLeftPadding,self.collectionView.bounds.size.height-kTopPadding-kProfileImageSize*2-kPaddingBtwElements-kBottomPadding-kBottomStackHeight-kBottomStackPadding)];
        
        [cell.titleLabel setFrame:CGRectMake(kLeftPadding+kProfileImageSize+kPaddingBtwElements*2,7, 320-kLeftPadding-kProfileImageSize-kPaddingBtwElements-kLeftRightPadding*2, kProfileImageSize*2)];
        cell.titleLabel.text = [selectedDeal objectForKey:@"title"];
        
        
        [cell.dealContentView setFrame:CGRectMake(0, 0, self.collectionView.bounds.size.width,self.collectionView.bounds.size.height-kBottomStackHeight-kBottomStackPadding)];
        [cell.cellScrollView setContentSize:CGSizeMake(self.collectionView.bounds.size.width,cell.cellScrollView.bounds.size.height+1)];
        cell.clipsToBounds = NO;
        
        return cell;
        
    }
    
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (![scrollView isKindOfClass:[UICollectionView class]])
    {
        if (scrollView.contentOffset.y < kOffsetAllowance)
        {
            [self.collectionView performBatchUpdates:^{
                for (NSInteger i=0 ; i < self.dealArray.count; i++) {
                    NSIndexPath* path = [NSIndexPath indexPathForItem:i inSection:0];
                    [[self.collectionView cellForItemAtIndexPath:path] setSelected:NO];
                    if ([[self.collectionView cellForItemAtIndexPath:path] isKindOfClass:[Cell class]]) {
                        ((Cell*)[self.collectionView cellForItemAtIndexPath:path]).flipped = NO;
                    }
                }
            }completion:^(BOOL finished) {
                for (UIView* collectionSubview in scrollView.subviews) {
                    if ([collectionSubview isKindOfClass:[UITextView class]]) {
                        collectionSubview.hidden = YES;
                    }
                    else
                    {
                        collectionSubview.hidden = NO;
                    }
                }
                
                [self.collectionView performBatchUpdates:^{
                    [scrollView setContentOffset:CGPointMake(0, 0)];
                    [scrollView setScrollEnabled:NO];
                    [((DealsLayout*)self.collectionView.collectionViewLayout) setKLayoutStateRef:kLayoutStateTable];
                    
                }completion:^(BOOL finished){
                    
                    
                }];
            }];
        }
    }
}
- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint tapPoint = [sender locationInView:self.collectionView];
        NSIndexPath* tappedCellPath;// = [self.collectionView indexPathForItemAtPoint:initialPinchPoint];
        
        //go thru all paths and find their layout attributes, if point is contained in their rect , return true
        for (NSInteger i=0 ; i < self.dealArray.count; i++)
        {
            NSIndexPath* path = [NSIndexPath indexPathForItem:i inSection:0];
            UICollectionViewLayoutAttributes* attr = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:path];
            if (CGRectContainsPoint(attr.frame, tapPoint))
            {
                tappedCellPath = path;
            }
            
        }
        
        if ( [self.collectionView cellForItemAtIndexPath:tappedCellPath].selected == NO && ((DealsLayout*)self.collectionView.collectionViewLayout).kLayoutStateRef == kLayoutStateDetail && self.dealArray.count>2)
        {
            //tapped on unselected and is in detail mode, ideally should go into table mode, but if coupon count is 1 go to detail
            [self.collectionView performBatchUpdates:^{
                
                [[self.collectionView cellForItemAtIndexPath:tappedCellPath] setSelected:NO];
                [((Cell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath]).cellScrollView setScrollEnabled:NO];
                [((Cell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath]).cellScrollView setContentOffset:CGPointMake(0, 0)];
                
                [((DealsLayout*)self.collectionView.collectionViewLayout) setKLayoutStateRef:kLayoutStateTable];}
                                          completion:^(BOOL finished) {
                                              NSLog(@"completed updates");
                                          }];
            return;
        }
        
        if (tappedCellPath!=nil) //if tapped on something
        {
            [self.collectionView performBatchUpdates:^{
                if ( (((Cell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath]).selected ==NO) || (((Cell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath]).selected ==YES && self.dealArray.count==2)) //if tapped cell is not selected to begin with
                {
                    if (self.dealArray.count==2) {
                        [[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] setSelected:![self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].selected];
                        [[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]] setSelected:![self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]].selected];
                        return;
                    }
                    
                    [((DealsLayout*)self.collectionView.collectionViewLayout) setPrevOffset:self.collectionView.contentOffset];
                    
                    for (Cell* coup in self.collectionView.visibleCells) {
                        coup.selected = NO;
                    }
                    Cell* selectedCell = ((Cell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath]);
                    selectedCell.selected = YES;
                    [selectedCell.cellScrollView setScrollEnabled:YES];
                    [((DealsLayout*)self.collectionView.collectionViewLayout) setKLayoutStateRef:kLayoutStateDetail];
                    NSLog(@"shifting to detail");
                }
                else
                {
                    
                    [[self.collectionView cellForItemAtIndexPath:tappedCellPath] setSelected:NO];
                    [((Cell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath]).cellScrollView setScrollEnabled:NO];
                    [((Cell*)[self.collectionView cellForItemAtIndexPath:tappedCellPath]).cellScrollView setContentOffset:CGPointMake(0, 0)];
                    [((DealsLayout*)self.collectionView.collectionViewLayout) setKLayoutStateRef:kLayoutStateTable];
                    NSLog(@"shifting to table");
                    
                    
                }
                
            } completion:^(BOOL finished) {
                NSLog(@"completed updates");
            }];
        }
    }
}
@end
