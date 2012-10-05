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

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
}

@end
