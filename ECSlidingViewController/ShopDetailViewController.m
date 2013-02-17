//
//  ShopDetailViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 14/11/12.
//
//
#import <SDWebImage/SDWebImageManager.h>
#import "ShopDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "AFNetworking.h"
#import "UIImage+Resize.h"

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
    if (IS_IPHONE_5) {
        self.descriptionWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 524)];
    }else{
        self.descriptionWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 416)];
    }
    [self.view addSubview:self.descriptionWebView];
    NSString *cssString = @"<style type='text/css'>img {width:300px; height: auto;}</style>";
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
    [htmlString appendFormat:@"<h3>%@</h3>%@%@",gsObject.title,cssString,gsObject.descriptionhtml];
    [regex replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"WIDTH: 300px;"];
    [regex2 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"HEIGHT: auto;"];
    [regex3 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"WIDTH: 300px;"];
    [regex4 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@"HEIGHT: auto;"];
    [regex5 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@""];
    [regex6 replaceMatchesInString:htmlString options:0 range:NSMakeRange(0, [htmlString length]) withTemplate:@""];

    NSLog(@"html string = %@",htmlString);
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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [super viewDidUnload];
}
//
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return [gsObject.imageArray count];
//}
//- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
//    return 1;
//}
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ColCel *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gsobject" forIndexPath:indexPath];
//    [cell.foodImageView setImageWithURL:[NSURL URLWithString:((NSString*)[gsObject.imageArray objectAtIndex:indexPath.row])]];
//    return cell;
//}


@end
