//
//  MIICommunicatorDelegate.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MIICommunicatorDelegate <NSObject>

- (void)receivedCompaniesJSON:(NSData *)objectNotation;
- (void)fetchingCompaniesFailedWithError:(NSError *)error;
- (void)receivedCompanyJSON:(NSData *)objectNotation;
- (void)fetchingCompanyFailedWithError:(NSError *)error;

@end
