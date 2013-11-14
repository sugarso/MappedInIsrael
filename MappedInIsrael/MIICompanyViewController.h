//
//  MIICompanyViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/1/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "MIICompany.h"

@interface MIICompanyViewController : GAITrackedViewController

@property (strong, nonatomic) MIICompany *company;

@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePageLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;

@end
