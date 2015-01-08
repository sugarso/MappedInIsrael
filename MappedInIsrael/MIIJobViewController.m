//
//  MIIJobViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/16/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIJobViewController.h"
#import "UITextView+FitText.h"

@interface MIIJobViewController ()
    @property (strong, nonatomic) NSString *url;
@end

@implementation MIIJobViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.screenName = @"MIIJobViewController";

    self.title = self.job.title;
    self.jobTextView.text = self.job.desc;
    self.textViewHeightConstraint.constant = [self.jobTextView fitTextHeight];

    if ([self.job.jobLink isKindOfClass:[NSString class]]) {
        self.url = self.job.jobLink;
    } else if ([self.hiringPageURL isKindOfClass:[NSString class]]) {
        self.url = self.hiringPageURL;
    } else {
        self.showWeb.hidden = YES;
    }
}

- (IBAction)lookForJob:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.url]]; // TBD: Google Analytics
}

@end
