//
//  MIIManager.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIManager.h"
#import "MIICompanyBuilder.h"
#import "MIICommunicator.h"

@implementation MIIManager

- (void)getAllCompanies
{
    [self.communicator getAllCompanies];
}

#pragma mark - MIICommunicatorDelegate

- (void)receivedCompaniesJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    NSArray *companies = [MIICompanyBuilder companiesFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        [self.delegate fetchingCompaniesFailedWithError:error];
    } else {
        [self.delegate didReceiveCompanies:companies];
    }
}

- (void)fetchingCompaniesFailedWithError:(NSError *)error
{
    [self.delegate fetchingCompaniesFailedWithError:error];
}

@end
