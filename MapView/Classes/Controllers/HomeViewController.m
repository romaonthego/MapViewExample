//
//  HomeViewController.m
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"

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
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Standard", @"Hybrid", @"Satellite"]];
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
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

#pragma mark -
#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.25 animations:^{
        _navBar.y = 0;
        _searchBar.y = 44;
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
    
}

@end
