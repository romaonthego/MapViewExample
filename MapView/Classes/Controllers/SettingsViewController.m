//
//  SettingsViewController.m
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Custom initialization
    self.view.backgroundColor = [UIColor underPageBackgroundColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:_hasPin ? @"Remove Pin" : @"Drop Pin" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(10, self.view.frame.size.height - 54, 300, 44)];
    [button addTarget:self action:@selector(dropPinButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropPinButtonPressed
{
    if (!_hasPin) {
        [_delegate dropPin];
    } else {
        [_delegate removePin];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
