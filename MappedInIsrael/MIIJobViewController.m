//
//  MIIJobViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/16/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIJobViewController.h"

@implementation MIIJobViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GAITrackedViewController
    self.screenName = @"MIIJobViewController";
    
    self.title = [self.job objectForKey:@"title"];
    self.jobTextView.text = [NSString stringWithFormat:@"%@",[self.job objectForKey:@"description"]];
    self.jobTextView.font = [UIFont fontWithName:@"Helvetica" size:17];
}

- (IBAction)lookForJob:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [self.job objectForKey:@"jobLink"]]];
}

@end
