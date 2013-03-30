//
//  ShopDetailViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 14/11/12.
//
//
#import "FoodType.h"
#import "EditTagsViewController.h"
#import <SDWebImage/SDWebImageManager.h>
#import "ShopDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "UIImage+Resize.h"
#import "FoodItem.h"
#import "FoodDescription.h"
#define kCouponWidth 280.0f
#define kBottomPadding 10.0f
#define kdescriptionheight 30.0f
#define kSeperatorSize 5.0f
#define kLeftRightPadding 10.0f
#define kPaddingBtwElements 5.0f
#define kBottomPadding 10.0f
#define kTopPadding 10.0f
#define kDescriptionFont [UIFont systemFontOfSize:11.0f]
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height > 500 )
@interface ShopDetailViewController ()

@end

@implementation ShopDetailViewController
@synthesize gsObject;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self){
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (IS_IPHONE_5) {
//        self.descriptionWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 524)];
//    }else{
//        self.descriptionWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
//    }
//    self.descriptionWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [self.view addSubview:self.descriptionWebView];


//    [_editView setFrame:CGRectMake(0, self.view.bounds.size.height-100,self.view.bounds.size.width, 100)];
//    float headx, heady;
//    headx = 0;
//    heady = 5;
//    for (FoodType* type in gsObject.foodtypes) {
//        CGSize s = [type.type sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0f] constrainedToSize:CGSizeMake(999, 999) lineBreakMode:NSLineBreakByCharWrapping];
//        if (heady + s.width + 20 + 10 > self.view.bounds.size.width) {
//            //next line
//            heady = heady + 20;
//            headx = 0;
//        }
//        
//        UILabel* typelabel = [[UILabel alloc]initWithFrame:CGRectMake(headx, heady, s.width+20, s.height)];
//        [typelabel setBackgroundColor:[UIColor whiteColor]];
//        [typelabel setTextColor:[UIColor grayColor]];
//        [typelabel setText:type.type];
//        [typelabel setTextAlignment:NSTextAlignmentCenter];
//        [typelabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0f]];
//        headx = headx + s.width+20 + 10;
//        [_editView addSubview:typelabel];
//    }
//    UIButton* editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [editButton setFrame:self.editView.bounds];
//    [editButton addTarget:self action:@selector(editTags) forControlEvents:UIControlEventTouchUpInside];
//    [editButton setBackgroundColor:[UIColor clearColor]];
//    [self.editView addSubview:editButton];
    
    [_descriptionWebView setDelegate:self];

    
    
    
    NSString *cssString = @"<style type='text/css'>img {width:300px; height: auto;} body {font-family:helvetica;}</style>";
    //while range != length
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"WIDTH:(.*?);" options:0 error:nil];
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:
                                  @"HEIGHT:(.*?);" options:0 error:nil];
    NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:
                                  @"width:(.*?);" options:0 error:nil];
    NSRegularExpression *regex4 = [NSRegularExpression regularExpressionWithPattern:
                                   @"height:(.*?);" options:0 error:nil];
    NSRegularExpression *regex5 = [NSRegularExpression regularExpressionWithPattern:
                                   @"(width=\"(.*?\")" options:0 error:nil];
    NSRegularExpression *regex6 = [NSRegularExpression regularExpressionWithPattern:
                                   @"(height=\"(.*?)\")" options:0 error:nil];
    
    NSMutableString *htmlString = [NSMutableString string];

    [htmlString appendFormat:@"<h3>%@</h3>%@%@",gsObject.title,cssString,[gsObject.descriptionHTML.descriptionHTML stringByReplacingOccurrencesOfString:@"''" withString:@"'"]];
    [regex replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"WIDTH: 300px;"];
    [regex2 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"HEIGHT: auto;"];
    [regex3 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"WIDTH: 300px;"];
    [regex4 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"HEIGHT: auto;"];
    [regex5 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@""];
    [regex6 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@""];

    [_descriptionWebView loadHTMLString:htmlString baseURL:nil];

    self.navigationItem.title = gsObject.source;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;

}
-(void)viewWillDisappear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning
{
    NSLog(@"did recieve memory warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {

    [self setEditView:nil];
    [super viewDidUnload];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    NSLog(@"did end decelerating");
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        NSLog(@"reached btm");

        
    }
}

-(void)editTags
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"iPhone"
                                                             bundle: nil];
    EditTagsViewController* editTagVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"EditTags"];
    [editTagVC setSelectedGSObject:gsObject];
    [self.navigationController  pushViewController:editTagVC animated:YES];
}
@end
