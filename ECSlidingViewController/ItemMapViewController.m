//
//  ItemMapViewController.m
//  ECSlidingViewController
//
//  Created by HengHong on 18/4/13.
//
//

#import "ItemMapViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface ItemMapViewController ()

@end

@implementation ItemMapViewController

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
    [self.mapView addAnnotation:self.foodplace];
    UIImage *actionButton = [[UIImage imageNamed:@"action.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    UIButton* barbuttonitem = [UIButton buttonWithType:UIButtonTypeCustom];
    barbuttonitem.frame = CGRectMake(0.0, 0.0, actionButton.size.width, actionButton.size.height);
    
    [barbuttonitem setBackgroundImage:actionButton forState:UIControlStateNormal];
    [barbuttonitem addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barbutton = [[UIBarButtonItem alloc]initWithCustomView:barbuttonitem];
    self.navigationItem.rightBarButtonItem = barbutton;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.foodplace.latitude.doubleValue, self.foodplace.longitude.doubleValue), MKCoordinateSpanMake(0.007, 0.007))];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark MKMapViewDelegate

-(void)mapView:(MKMapView *)retMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
   
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[FoodPlace class]]){
        static NSString* pinIdentifier = @"pinIdentifierString";
        MKAnnotationView* pinView =(MKAnnotationView *)
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        if (!pinView)
        {
            MKAnnotationView *customPinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                           reuseIdentifier:pinIdentifier];
            
            
            customPinView.image = [UIImage imageNamed:@"pin.png"];
            customPinView.layer.anchorPoint = CGPointMake(0.5, 1.0);
            customPinView.centerOffset = CGPointMake(0,0);
            customPinView.canShowCallout = NO;
            [customPinView setUserInteractionEnabled:YES];
            customPinView.clipsToBounds = NO;
            return customPinView;
            
        }
        else
        {
            pinView.annotation = annotation;
            
        }
        return pinView;
    }
    
    return nil;
}




-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView
didAddAnnotationViews:(NSArray *)annotationViews
{
    
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    
}
-(void) showActionSheet
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Get Directions" otherButtonTitles: nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    [actionSheet showInView:self.view];
    
    
}
-(void)getDirectionsToSelectedGSObj
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Directions" message:@"This will open maps app on your phone" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    alert.delegate = self;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self showDirectionsViaRedirect];
    }
    else
    {
    }
}
-(void)showDirectionsViaRedirect{
    NSString* saddr = @"Current+Locaton";
    NSString* daddr = @"";
    
    if([[UIApplication sharedApplication] canOpenURL:
        [NSURL URLWithString:@"comgooglemaps://"]]){
        saddr = [NSString stringWithFormat:@"%f,%f", self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude];
        daddr = [NSString stringWithFormat:@"%f,%f", self.foodplace.latitude.doubleValue,self.foodplace.longitude.doubleValue];
        NSLog(@"");
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&zoom=14&directionsmode=driving",saddr,daddr]]];
    }else{
        
        NSString* urlStr;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >=6) {
            //iOS 6+, Should use map.apple.com. Current Location doesn't work in iOS 6 . Must provide the coordinate.
            if ((self.userLocation.coordinate.latitude != kCLLocationCoordinate2DInvalid.latitude) && (self.userLocation.coordinate.longitude != kCLLocationCoordinate2DInvalid.longitude)) {
                //Valid location.
                saddr = [NSString stringWithFormat:@"%f,%f", self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude];
                urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?saddr=%@&daddr=%@", saddr, daddr];
            } else {
                //Invalid location. Location Service disabled.
                urlStr = [NSString stringWithFormat:@"http://maps.apple.com/maps?daddr=%@", daddr];
            }
        } else {
            // < iOS 6. Use maps.google.com
            urlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@&daddr=%@", saddr,daddr];
        }
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        
    }
    
    
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Get Directions"]) {
        [self getDirectionsToSelectedGSObj];
    }
}


@end
