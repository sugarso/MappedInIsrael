//
//  MIIManagerDelegate.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIICompany.h"

@protocol MIIManagerDelegate <NSObject>

- (void)didReceiveCompanies:(NSArray *)companies;
- (void)didReceiveCompany:(MIICompany *)company;
- (void)fetchingCompanyFailedWithError:(NSError *)error;

@end
