//
//  ViewController.m
//  LocalSearchExample
//
//  Created by Jeffrey Sambells on 2013-01-28.
//  Copyright (c) 2013 Jeffrey Sambells. All rights reserved.
//

#import "MapSearchViewController.h"
#import "AFHTTPClient.h"
@interface MapSearchViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@end

@implementation MapSearchViewController {
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

#pragma mark - View Lifecycle
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchDisplayController setDelegate:self];
    [self.ibSearchBar setDelegate:self];
    [self.ibSearchBar setPlaceholder:@"Suggest New Location"];
    // Zoom the map to current location.
//    [self.ibMapView setShowsUserLocation:YES];
//    [self.ibMapView setUserInteractionEnabled:YES];
//    [self.ibMapView setUserTrackingMode:MKUserTrackingModeFollow];
}

#pragma mark - Search Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
//    request.region = self.ibMapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
    
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];

    MKMapItem *item = results.mapItems[indexPath.row];
//    [self.ibMapView addAnnotation:item.placemark];
//    [self.ibMapView selectAnnotation:item.placemark animated:YES];
//    
//    [self.ibMapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
//
//    [self.ibMapView setUserTrackingMode:MKUserTrackingModeNone];
    NSLog(@"found geocode at %@",item.placemark);
    NSString* addressString = @"";
    for (NSString* formattedAddress in [item.placemark.addressDictionary objectForKey:@"FormattedAddressLines"]) {
        if ([addressString isEqualToString:@""]) {
            addressString = formattedAddress;
        }else{
            addressString = [addressString stringByAppendingFormat:@" , %@",formattedAddress];
        }
    }

    
    
    NSURL *tokenurl = [NSURL URLWithString:@"http://tastebudsapp.herokuapp.com"];
    AFHTTPClient* afclient = [[AFHTTPClient alloc]initWithBaseURL:tokenurl];
    [afclient putPath:[NSString stringWithFormat:@"/items/%d",self.gsobj.item_id.intValue] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",item.placemark.location.coordinate.latitude],@"item[latitude]",[NSString stringWithFormat:@"%f",item.placemark.location.coordinate.longitude],@"item[longitude]",[NSString stringWithFormat:@"%@",addressString],@"item[location]", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Success!" message:[NSString stringWithFormat:@"%f,%f,%@",item.placemark.location.coordinate.latitude,item.placemark.location.coordinate.longitude,[NSString stringWithFormat:@"%@",addressString]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@",error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    

}

@end
