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
    self.navigationItem.title = self.company.companyName;
}

@end
