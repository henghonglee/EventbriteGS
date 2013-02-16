//
//  CorrectionViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 3/2/13.
//
//

#import "CorrectionViewController.h"
#import "AFHTTPClient.h"
@interface CorrectionViewController ()

@end

@implementation CorrectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.opaque = YES;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
} 

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.correctionTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.correctionTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.view addSubview:self.correctionTextField];
    UIButton* submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submit setFrame:CGRectMake(220, 44, 100, 44)];
    [submit addTarget:self action:@selector(didSubmit:) forControlEvents:UIControlEventTouchUpInside];
    [submit setTitle:@"Submit!" forState:UIControlStateNormal];
    [self.view addSubview:submit];
	// Do any additional setup after loading the view.
}
-(void)didSubmit:(id)sender
{
    if (!self.geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    NSLog(@"trying geocode");
    [self.geocoder geocodeAddressString:self.correctionTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"geocoder returned");
        if ([placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"found geocode at %@",placemark);
            NSString* addressString = @"";
            for (NSString* formattedAddress in [placemark.addressDictionary objectForKey:@"FormattedAddressLines"]) {
                if ([addressString isEqualToString:@""]) {
                    addressString = formattedAddress;
                }else{
                    addressString = [addressString stringByAppendingFormat:@" , %@",formattedAddress];
                }
            }

            //remember and apply at end
            NSURL *tokenurl = [NSURL URLWithString:@"http://tastebudsapp.herokuapp.com"];
            AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
            [afclient putPath:[NSString stringWithFormat:@"/items/%d",self.gsobj.itemId.intValue] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",placemark.location.coordinate.latitude],@"item[latitude]",[NSString stringWithFormat:@"%f",placemark.location.coordinate.longitude],@"item[longitude]",[NSString stringWithFormat:@"%@",addressString],@"item[location]", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:[NSString stringWithFormat:@"%f,%f,%@",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude,[NSString stringWithFormat:@"%@",addressString]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }];
            

        }else{
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Couldn't find a matching location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
