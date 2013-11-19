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

- (void)getCompany:(NSString *)id;
{
    [self.communicator getCompany:id];
}

#pragma mark - MIICommunicatorDelegate

- (void)receivedCompaniesJSON:(NSData *)objectNotation
{
    NSArray *companies = [MIICompanyBuilder companiesFromJSON:objectNotation];
    [self.delegate didReceiveCompanies:companies];
}

- (void)receivedCompanyJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    MIICompany *company = [MIICompanyBuilder companyFromJSON:objectNotation error:&error];
    
    if (error != nil) {
        [self.delegate fetchingCompanyFailedWithError:error];
    } else {
        [self.delegate didReceiveCompany:company];
    }
}

- (void)fetchingCompanyFailedWithError:(NSError *)error
{
    [self.delegate fetchingCompanyFailedWithError:error];
}

@end
