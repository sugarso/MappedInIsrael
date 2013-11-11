//
//  MIICompanyBuilder.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIICompanyBuilder.h"
#import "MIICompany.h"

@implementation MIICompanyBuilder

+ (NSArray *)companiesFromJSON:(NSData *)objectNotation error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    
    NSArray *payload = [parsedObject valueForKey:@"payload"];
    NSLog(@"Companies Count: %lu", (unsigned long)payload.count);
    
    for (NSDictionary *companyDic in payload) {
        MIICompany *company = [[MIICompany alloc] init];

        for (NSString *key in companyDic) {
            if ([company respondsToSelector:NSSelectorFromString(key)]) {
                [company setValue:[companyDic valueForKey:key] forKey:key];
            }
        }

        [companies addObject:company];
    }
    
    return companies;
}

@end
