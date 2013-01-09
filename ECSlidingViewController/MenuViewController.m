#import "MenuViewController.h"
#import "MapNavViewController.h"


#import "MapSlidingViewController.h"
#import "GeoScrollViewController.h"
@interface MenuViewController()
@property (nonatomic, strong) NSArray *menuItems;
@end

@implementation MenuViewController
@synthesize menuItems;

- (void)awakeFromNib
{
  self.menuItems = [NSArray arrayWithObjects:@"Map", nil];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
    self.menuTableView.scrollsToTop = NO;
  [self.slidingViewController setAnchorRightRevealAmount:280.0f];
  self.slidingViewController.underLeftWidthLayout = ECFullWidth;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
  return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"MenuItemCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
  }
  
  cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    MapNavViewController* viewController = [MapNavViewController sharedInstance];
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = viewController;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
            [((GeoScrollViewController*)((MapSlidingViewController*)((MapNavViewController*)self.slidingViewController.topViewController).topViewController).topViewController) viewWillAppear:YES];
        }];
        
    
    
    
 
}

@end
