#import "MenuViewController.h"
#import "MapNavViewController.h"
#import "MenuCell.h"

#import "MapSlidingViewController.h"
#import "GeoScrollViewController.h"
#define BLUE_COLOR [UIColor colorWithRed:83.0f/255.0f green:213.0f/255.0f blue:253.0f/255.0f alpha:1.0f]
#define yellow [UIColor colorWithRed:254.0f/255.0f green:252.0f/255.0f blue:53.0f/255.0f alpha:1.0f]

@interface MenuViewController()
@property (nonatomic, strong) NSMutableArray *menuItems;
@end

@implementation MenuViewController
@synthesize menuItems;

- (void)awakeFromNib
{
    self.menuItems = [NSMutableArray arrayWithObjects:@"BLOGS",@"CONTACT US",nil];
}

  
- (void)viewDidLoad
{
  [super viewDidLoad];
    //@"DANIEL'S FOOD DIARY",@"KEROPOKMAN",
    self.isBlogsRevealed = YES;
    self.arrayToAdd = [NSArray arrayWithObjects:@"IEATISHOOTIPOST",@"LADY IRON CHEF",@"LOVE SG FOOD",@"SGFOODONFOOT",@"DANIEL FOOD DIARY", nil];
    self.menuTableView.scrollsToTop = NO;
    self.menuTableView.backgroundColor = [UIColor clearColor];
    self.menuTableView.bounces = NO;
  [self.slidingViewController setAnchorRightRevealAmount:280.0f];
  self.slidingViewController.underLeftWidthLayout = ECFullWidth;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
  return self.menuItems.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 260, 60)];
    [headerLabel setText:@"Tastebuds"];
    [headerLabel setFont:[UIFont fontWithName:@"Miss Claude" size:55.0f]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel  setTextAlignment:NSTextAlignmentCenter];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.shadowOffset = CGSizeMake(1, 1);
    [headerView addSubview:headerLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromCellIdentifier = @"FromCell";
    MenuCell* cell = (MenuCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MenuCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (MenuCell*)currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
   
    
    cell.bgView.backgroundColor = yellow;
    cell.bgView.alpha = 0.7;
    cell.titleLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    
    if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"LADY IRON CHEF"]) {
        cell.colorBar.backgroundColor = [UIColor blueColor];

    }else if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"IEATISHOOTIPOST"]) {
        cell.colorBar.backgroundColor = [UIColor redColor];

    }else if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"DANIEL FOOD DIARY"]) {
        cell.colorBar.backgroundColor = [UIColor magentaColor];

    }else if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"KEROPOKMAN"]) {
        cell.colorBar.backgroundColor = [UIColor greenColor];

    }else if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"LOVE SG FOOD"]) {
        cell.colorBar.backgroundColor = [UIColor blackColor];

    }else if ([[self.menuItems objectAtIndex:indexPath.row] isEqualToString:@"SGFOODONFOOT"]) {
        cell.colorBar.backgroundColor = [UIColor cyanColor];

    }else{

        cell.colorBar.backgroundColor = [UIColor magentaColor];

    }
    if ([self.arrayToAdd containsObject:[self.menuItems objectAtIndex:indexPath.row]])
    {
        //for blogs in array to add
        
        if([[[NSUserDefaults standardUserDefaults] objectForKey:[self.menuItems objectAtIndex:indexPath.row]] isEqualToString:@"Enabled"])
        {
            cell.colorBar.hidden = NO;
            cell.bgView.backgroundColor = BLUE_COLOR;
            cell.titleLabel.textColor = [UIColor blackColor];
        }else{
            cell.colorBar.hidden = YES;
            cell.titleLabel.textColor = [UIColor whiteColor];
            cell.bgView.backgroundColor = [UIColor grayColor];
        }
        cell.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0f];

    }
    else
    {
        if ([cell.titleLabel.text isEqualToString:@"BLOGS"]) {
            cell.vView.hidden = NO;

        }
        if ([cell.titleLabel.text isEqualToString:@"CONTACT US"]) {
//            cell.vView.hidden = NO;
//            cell.vView.image = [UIImage imageNamed:@"plus.png"];

        }
        cell.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18.0f];
        cell.bgView.backgroundColor = [UIColor whiteColor];
//        cell.indicator.hidden = YES;
        cell.bgView.alpha = 0.7;
        cell.colorBar.hidden = YES;
        cell.countLabel.hidden = YES;
    }

    
    
    
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0) {

        if (!self.isBlogsRevealed) {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:0
                             animations:^{
                                 ((MenuCell*)[tableView cellForRowAtIndexPath:indexPath]).vView.transform = CGAffineTransformMakeRotation(M_PI);
                             }
                             completion:^(BOOL finished){
                                 NSLog(@"Done!");
                             }];

            NSMutableArray* indexPaths = [[NSMutableArray alloc]init];
            for (NSString* blog in self.arrayToAdd) {
                [self.menuItems insertObject:blog atIndex:indexPath.row+1];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.menuItems.count-2 inSection:0];
                [indexPaths addObject:indexPath];
            }
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            self.isBlogsRevealed = YES;
        }else{
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options:0
                             animations:^{
                                 ((MenuCell*)[tableView cellForRowAtIndexPath:indexPath]).vView.transform = CGAffineTransformMakeRotation(0);
                             }
                             completion:^(BOOL finished){
                                 NSLog(@"Done!");
                             }];

            NSMutableArray* indexPaths = [[NSMutableArray alloc]init];
            while (self.menuItems.count > 2)
            {
                [self.menuItems removeObjectAtIndex:indexPath.row+1];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.menuItems.count-1 inSection:0];
                [indexPaths addObject:indexPath];
            }
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];

            self.isBlogsRevealed = NO;
            }
    }else{
        if([[[NSUserDefaults standardUserDefaults] objectForKey:[self.menuItems objectAtIndex:indexPath.row]] isEqualToString:@"Enabled"])
        {
            ((GeoScrollViewController*)((MapSlidingViewController*)((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController).topViewController).selectionChanged = YES;
            NSLog(@"setting no for %@",[self.menuItems objectAtIndex:indexPath.row]);
            [[NSUserDefaults standardUserDefaults] setObject:@"Disabled" forKey:[self.menuItems objectAtIndex:indexPath.row]];
        }else{
            ((GeoScrollViewController*)((MapSlidingViewController*)((MapNavViewController*)[MapNavViewController sharedInstance]).topViewController).topViewController).selectionChanged = YES;
            NSLog(@"setting YES for %@",[self.menuItems objectAtIndex:indexPath.row]);
            [[NSUserDefaults standardUserDefaults] setObject:@"Enabled" forKey:[self.menuItems objectAtIndex:indexPath.row]];
        }
        [[NSUserDefaults standardUserDefaults]synchronize];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }


 
}
-(BOOL)shouldAutorotate{
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

@end
