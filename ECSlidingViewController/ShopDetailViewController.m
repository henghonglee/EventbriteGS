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

- (void)viewDidLoad
{
    [super viewDidLoad];
            NSLog(@"viewdidload");
    _subtitleLabel.text = gsObject.subTitle;
    _titleLabel.text = gsObject.title;
    NSString *cssString = @"<style type='text/css'>img {width:300px; height: auto;}</style>";
    NSString *htmlString = [NSString stringWithFormat:@"%@%@",cssString,gsObject.descriptionhtml];
    [_descriptionWebView loadHTMLString:htmlString baseURL:nil];
    self.navigationItem.title = gsObject.source;
        
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;

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
