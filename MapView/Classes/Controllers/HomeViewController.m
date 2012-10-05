//
//  HomeViewController.m
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "BookmarksViewController.h"
#import "Annotation.h"
#import "DetailsViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)navigate:(NSString *)urlString
{
    _currentURLString = urlString;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_currentURLString]];
    [_webView loadRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Search"];
    _clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearButtonPressed)];
    _clearButton.enabled = NO;
    item.leftBarButtonItem = _clearButton;
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed)];
    item.rightBarButtonItem = _doneButton;
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, -44, self.view.frame.size.width, 44)];
    _navBar.items = @[item];
    _navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_navBar];
    
    // --
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height -  88)];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    _overlayView = [[UIView alloc] initWithFrame:_mapView.frame];
    _overlayView.backgroundColor = [UIColor blackColor];
    _overlayView.alpha = 0.7;
    _overlayView.autoresizingMask = _mapView.autoresizingMask;
    _overlayView.hidden = YES;
    [self.view addSubview:_overlayView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = _overlayView.bounds;
    cancelButton.autoresizingMask = _overlayView.autoresizingMask;
    [cancelButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchDown];
    [_overlayView addSubview:cancelButton];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    _searchBar.placeholder = @"Search or Address";
    _searchBar.showsBookmarkButton = YES;
    
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    
    // --
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [self.view addSubview:_toolBar];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    MKUserTrackingBarButtonItem *mapButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:_mapView];
    
    _curlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPageCurl target:self action:@selector(curlButtonPressed)];
    
    UIBarButtonItem *spacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Standard", @"Satellite", @"Hybrid"]];
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self
                         action:@selector(segmentedControlChanged:)
               forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentedButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    
    _toolBar.items = @[mapButtonItem, spacing, segmentedButton, spacing];
    
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.hidden = YES;
    [self.view addSubview:_webView];
    /*
     Annotation *annotation = [[Annotation alloc] init];
     annotation.coordinate = CLLocationCoordinate2DMake(37.771008, -122.41175);
     annotation.title = @"Test";
     [_mapView addAnnotation:annotation];*/
    _annotations = [[NSMutableArray alloc] init];
    
    _geocoder = [[CLGeocoder alloc] init];
}

- (void)zoomToAnnotationsBounds:(NSArray *)annotations
{
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (Annotation *annotation in annotations) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        if (annotationLat == 0 && annotationLong == 0) continue;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    // If your markers were 40 in height and 20 in width, this would zoom the map to fit them perfectly. Note that there is a bug in mkmapview's set region which means it will snap the map to the nearest whole zoom level, so you will rarely get a perfect fit. But this will ensure a minimum padding.
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 10.0, 40.0, 10.0);
    CLLocationCoordinate2D relativeFromCoord = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D rightCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D bottomCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D leftCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.mapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

- (void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude
{
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    if (region.span.latitudeDelta < 0.019863)
        region.span.latitudeDelta = 0.019863;
    
    if (region.span.longitudeDelta < 0.019863)
        region.span.longitudeDelta = 0.019863;
    
    [_mapView setRegion:region animated:NO];
}

- (void)cancelSearch
{
    [_searchBar resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        _navBar.y = -44;
        _searchBar.y = 0;
        _overlayView.alpha = 0;
    } completion:^(BOOL finished) {
        _overlayView.hidden = YES;
    }];
}

#pragma mark -
#pragma mark Button actions

- (void)curlButtonPressed
{
    SettingsViewController *controller = [[SettingsViewController alloc] init];
    controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)clearButtonPressed
{
    _searchBar.text = @"";
    [self searchBar:_searchBar textDidChange:@""];
}

- (void)doneButtonPressed
{
    [self cancelSearch];
}

- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    _mapView.mapType = sender.selectedSegmentIndex;
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _overlayView.alpha = 0;
    _overlayView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        _navBar.y = 0;
        _searchBar.y = 44;
        _overlayView.alpha = 0.8;
    }];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText == nil || [searchText isEqualToString:@""]) {
        _clearButton.enabled = NO;
        _doneButton.title = @"Done";
    } else {
        _clearButton.enabled = YES;
        _doneButton.title = @"Cancel";
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[BookmarksViewController alloc] init]];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_geocoder geocodeAddressString:searchBar.text inRegion:nil completionHandler:^(NSArray *placemarks, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred." message:@"No results found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        [_mapView removeAnnotations:_annotations];
        [_annotations removeAllObjects];
        
        for (CLPlacemark *placemark in placemarks) {
            Annotation *annotation = [[Annotation alloc] init];
            annotation.coordinate = placemark.location.coordinate;
            annotation.title = [placemark.areasOfInterest componentsJoinedByString:@", "];
            if (!annotation.title || [annotation.title isEqualToString:@""]) {
                annotation.title = placemark.description;
            } else {
                annotation.subtitle = placemark.description;
            }
            [_annotations addObject:annotation];
            [_mapView addAnnotation:annotation];
        }
        [self zoomToAnnotationsBounds:_annotations];
    }];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {
        if (currentAnnotation != mapView.userLocation) {
            [mapView selectAnnotation:currentAnnotation animated:YES];
            break;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    if (annotation == mapView.userLocation) return nil;
    
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    
    
    MKPinAnnotationView* customPinView = [[MKPinAnnotationView alloc]
                                           initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
    customPinView.pinColor = MKPinAnnotationColorRed;
    customPinView.animatesDrop = YES;
    customPinView.canShowCallout = YES;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    rightButton.tag = 1;
    customPinView.rightCalloutAccessoryView = rightButton;
    
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.tag = 0;
    [leftButton setFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton setImage:[UIImage imageNamed:@"Pin_Icon_View"] forState:UIControlStateNormal];
    leftButton.enabled = NO;
    customPinView.rightCalloutAccessoryView = rightButton;
    customPinView.leftCalloutAccessoryView = leftButton;
    
    return customPinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (view.annotation == mapView.userLocation)
        return;
    if (control.tag == 0) {
        [self navigate:@"https://maps.gstatic.com/m/streetview/?panoid=9u_xK2zj2al6IBB78x5eTw"];
        _webView.hidden = NO;
    } else {
        DetailsViewController *detailsViewController = [[DetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        detailsViewController.title = @"Info";
        [self.navigationController pushViewController:detailsViewController animated:YES];
    }
}

#pragma mark - 
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('close-button')[0].outerHTML ='';"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString isEqualToString:_currentURLString]) {
        return YES;
    }
    [[UIApplication sharedApplication] openURL:request.URL];
    return NO;
}

@end
