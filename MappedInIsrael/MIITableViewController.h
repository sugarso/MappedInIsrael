//
//  MIITableViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/12/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "MIIData.h"

@interface MIITableViewController : GAITrackedViewController

@property (nonatomic) MIIData *data;
@property (nonatomic) NSArray *clusterAnnotation;

@end
