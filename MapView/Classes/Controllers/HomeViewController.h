//
//  HomeViewController.h
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate> {
    UINavigationBar *_navBar;
    UISearchBar *_searchBar;
    MKMapView *_mapView;
    UIToolbar *_toolBar;
    UIBarButtonItem *_curlButton;
    
    UIView *_overlayView;
    UIBarButtonItem *_clearButton;
    UIBarButtonItem *_doneButton;
    
    CLGeocoder *_geocoder;
    NSMutableArray *_annotations;
}

@end
