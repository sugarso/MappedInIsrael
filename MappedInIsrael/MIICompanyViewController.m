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
    
    // Company
    //self.navigationItem.title = self.company.companyCategory;
    self.streetLabel.text = self.company.addressStreet;
    self.cityLabel.text = self.company.addressCity;
    self.contactLabel.text = self.company.contactEmail;
    self.homePageLabel.text = self.company.websiteURL;
    self.nameLabel.text = self.company.companyName;
    self.descriptionTextView.text = self.company.description;
}

@end
