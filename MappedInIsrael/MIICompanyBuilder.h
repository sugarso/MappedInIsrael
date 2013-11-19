//
//  MIICompanyBuilder.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIICompany.h"

@interface MIICompanyBuilder : NSObject

+ (NSArray *)companiesFromJSON:(NSData *)objectNotation;
+ (MIICompany *)companyFromJSON:(NSData *)objectNotation error:(NSError **)error;

@end
