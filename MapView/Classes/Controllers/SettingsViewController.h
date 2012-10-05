//
//  SettingsViewController.h
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (readwrite, nonatomic) BOOL hasPin;

@end

@protocol SettingsViewControllerDelegate <NSObject>

- (void)dropPin;
- (void)removePin;

@end