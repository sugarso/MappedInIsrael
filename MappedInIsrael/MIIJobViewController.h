//
//  MIIJobViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/16/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface MIIJobViewController : GAITrackedViewController

@property (strong, nonatomic) NSDictionary *job;
@property (weak, nonatomic) IBOutlet UITextView *jobTextView;

@end
