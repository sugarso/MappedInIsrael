//
//  MIIJobViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/16/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "MIIJob.h"

@interface MIIJobViewController : GAITrackedViewController

@property (strong, nonatomic) MIIJob *job;
@property (strong, nonatomic) NSString *hiringPageURL;
@property (weak, nonatomic) IBOutlet UITextView *jobTextView;
@property (weak, nonatomic) IBOutlet UIButton *showWeb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@end
