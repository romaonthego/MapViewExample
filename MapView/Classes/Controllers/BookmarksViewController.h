//
//  BookmarksViewController.h
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookmarksViewControllerDelegate;

@interface BookmarksViewController : UITableViewController <UIActionSheetDelegate>

@property (weak, nonatomic) NSMutableArray *searches;
@property (weak, nonatomic) id <BookmarksViewControllerDelegate> delegate;

@end

@protocol BookmarksViewControllerDelegate <NSObject>

- (void)selectedSavedSearch:(NSString *)search;

@end