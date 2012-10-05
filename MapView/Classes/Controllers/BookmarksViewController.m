//
//  BookmarksViewController.m
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "BookmarksViewController.h"
#import "Storage.h"

@interface BookmarksViewController ()

@end

@implementation BookmarksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"Recents";
        self.navigationItem.prompt = @"Choose a recent search";
        
        UIBarButtonItem *clearButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearButtonPressed)];
        self.navigationItem.leftBarButtonItem = clearButtonItem;
        
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = doneButtonItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searches count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *info = [_searches objectAtIndex:indexPath.row];
    cell.textLabel.text = [info objectForKey:@"search"];
    cell.detailTextLabel.text = [info objectForKey:@"result"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *info = [_searches objectAtIndex:indexPath.row];
    [_delegate selectedSavedSearch:[info objectForKey:@"result"]];
}

#pragma mark -
#pragma mark Button actions

- (void)doneButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearButtonPressed
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Clear All Recents"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [_searches removeAllObjects];
        [Storage saveArray:_searches];
        [self.tableView reloadData];
    }
}

@end
