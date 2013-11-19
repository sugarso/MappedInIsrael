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
    
    self.title = self.job.title;
    self.jobTextView.text = self.job.description;
    self.jobTextView.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.jobTextView.textColor = [UIColor grayColor];
    
    // Resize descriptionTextView
    CGRect rect = [self.jobTextView.attributedText boundingRectWithSize:CGSizeMake(self.jobTextView.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    // Move jobTextView
    self.jobTextView.frame = CGRectMake(self.jobTextView.frame.origin.x,
                                        20,
                                        self.jobTextView.frame.size.width,
                                        rect.size.height+10);
    
    self.showWeb.frame = CGRectMake(self.showWeb.frame.origin.x,
                                    self.jobTextView.frame.origin.x+
                                    self.jobTextView.frame.size.height+20,
                                    self.showWeb.frame.size.width,
                                    self.showWeb.frame.size.height);
    
    if ([self.job.jobLink isKindOfClass:[NSString class]]) {
        NSURL *candidateURL = [NSURL URLWithString:self.job.jobLink];
        if (!(candidateURL && candidateURL.scheme && candidateURL.host)) {
            self.showWeb.hidden = YES;
        }
    } else {
        self.showWeb.hidden = YES;
    }
    
    if (self.showWeb.hidden) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 self.jobTextView.frame.size.height+2*20);
    } else {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 self.jobTextView.frame.size.height+self.showWeb.frame.size.height+3*20);
    }
    
}

- (IBAction)lookForJob:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.job.jobLink]];
}

@end
