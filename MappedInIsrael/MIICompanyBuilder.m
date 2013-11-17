//
//  MIICompanyBuilder.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIICompanyBuilder.h"
#import "MIICompany.h"
#import "NSString+HTML.h"

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
                if ([[companyDic valueForKey:key] isKindOfClass:[NSString class]]) {
                    [company setValue:[[companyDic valueForKey:key] stringByDecodingXMLEntities] forKey:key];
                } else {
                    [company setValue:[companyDic valueForKey:key] forKey:key];
                }
            }
        }

        [companies addObject:company];
    }
    
    return companies;
}

+ (MIICompany *)companyFromJSON:(NSData *)objectNotation error:(NSError **)error;
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }

    NSArray *payload = [parsedObject valueForKey:@"payload"];
    NSDictionary *organization = [payload valueForKey:@"organization"];
    NSLog(@"Organization Count: %lu", (unsigned long)organization.count);
    
    MIICompany *company = [[MIICompany alloc] init];
    
    for (NSString *key in organization) {
        if ([company respondsToSelector:NSSelectorFromString(key)]) {
            if ([[organization valueForKey:key] isKindOfClass:[NSString class]]) {
                [company setValue:[[organization valueForKey:key] stringByDecodingXMLEntities] forKey:key];
            } else {
                [company setValue:[organization valueForKey:key] forKey:key];
            }
        }
    }
    
    // TBD: write it better
    NSMutableArray *jobs = [[NSMutableArray alloc] init];
    for (NSDictionary *job in [payload valueForKey:@"jobs"]) {
        NSString *title = [[job valueForKey:@"title"] stringByDecodingXMLEntities];
        NSString *description = [[job valueForKey:@"description"] stringByDecodingXMLEntities];
        NSMutableDictionary *jobFixed = [[NSMutableDictionary alloc] init];
        [jobFixed setValue:title forKey:@"title"];
        [jobFixed setValue:description forKey:@"description"];
        [jobs addObject:jobFixed];
    }
    company.jobs = [jobs copy];
    
    return company;
}

@end
