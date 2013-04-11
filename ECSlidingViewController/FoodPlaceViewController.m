//
//  FoodPlaceViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 30/3/13.
//
//
#import "SVWebViewController.h"
#import "FoodPlaceViewController.h"
#import "FoodPlace.h"
#import "FoodItem.h"
#import "FoodImage.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface FoodPlaceViewController ()

@end

@implementation FoodPlaceViewController

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
    FoodImage* image = [[self.foodplace.images allObjects] objectAtIndex:0];
    
    [self.CoverImage setImageWithURL:[NSURL URLWithString:image.high_res_image] ];
    [self.CoverImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.CoverImage setClipsToBounds:YES];
    self.titleLabel.text = self.foodplace.title;
    
    [self.CoverImage setFrame:CGRectMake(0, 0, 320, 320)];
    [self.reviewTable setBackgroundColor:[UIColor clearColor]];
    [self.reviewTable setFrame:CGRectMake(0, 320-44, 320, self.view.bounds.size.height-320+44)];
    
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark TableViewDelegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foodplace.items.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
    FoodItem* item = [[self.foodplace.items allObjects]objectAtIndex:indexPath.row];
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = item.source;

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FoodItem* selectedGSObj = [[self.foodplace.items allObjects]objectAtIndex:indexPath.row];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",selectedGSObj.link]];
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
    webViewController.gsobj = selectedGSObj;
    //webViewController.currentLocation = self.userLocation;
    [self.navigationController pushViewController:webViewController animated:YES];


}
- (void)viewDidUnload {
    [self setCoverImage:nil];
    [self setTitleLabel:nil];
    [self setReviewTable:nil];
    [super viewDidUnload];
}
@end
