//
//  MIIJobViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/16/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIJobViewController.h"

@interface MIIJobViewController ()

@end

@implementation MIIJobViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"MIIJobViewController";
    
    self.title = [self.job objectForKey:@"title"];
    self.jobTextView.text = [self.job objectForKey:@"description"];
}

- (IBAction)lookForJob:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [self.job objectForKey:@"jobLink"]]];
}

@end
