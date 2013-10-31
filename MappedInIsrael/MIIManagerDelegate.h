//
//  MIIManagerDelegate.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MIIManagerDelegate <NSObject>

- (void)didReceiveCompanies:(NSArray *)groups;
- (void)fetchingCompaniesFailedWithError:(NSError *)error;

@end
