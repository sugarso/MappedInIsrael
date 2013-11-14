//
//  MIICompanyViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/1/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIICompanyViewController.h"

@interface MIICompanyViewController ()

@end

@implementation MIICompanyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"MIICompanyViewController";
    
    // NavigationBar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationItem.title = self.company.companyName;
    
    self.cityLabel.text = self.company.addressCity;
}

@end
