//
//  MIICompanyBuilder.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIICompanyBuilder.h"
#import "MIICompany.h"
#import "MIIJob.h"
#import "NSString+HTML.h"
#import "MIICommunicator.h"

@implementation MIICompanyBuilder

+ (NSArray *)companiesFromJSON:(NSData *)objectNotation
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        parsedObject = [NSJSONSerialization JSONObjectWithData:[MIICommunicator getStaticData] options:0 error:&localError];
    } else {
        [MIICommunicator setStaticData:objectNotation]; // TBD: test it
    }
    
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    
    NSArray *payload = [parsedObject valueForKey:@"payload"];
    Hello(@"Companies Count: %lu", (unsigned long)payload.count);
    
    for (NSDictionary *companyDic in payload) {
        MIICompany *company = [[MIICompany alloc] init];

        for (NSString *key in companyDic) {
            if ([company respondsToSelector:NSSelectorFromString(key)]) {
                if ([[companyDic valueForKey:key] isKindOfClass:[NSString class]]) {
                    [company setValue:[companyDic[key] stringByDecodingXMLEntities] forKey:key];
                } else {
                    [company setValue:companyDic[key] forKey:key];
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
    NSArray *jobs = [payload valueForKey:@"jobs"];
    
    MIICompany *company = [[MIICompany alloc] init];
    for (NSString *key in organization) {
        if ([key isEqualToString:@"description"]) {
            [company setValue:[organization[key] stringByDecodingXMLEntities] forKey:@"desc"];
        } else if ([company respondsToSelector:NSSelectorFromString(key)]) {
            if ([organization[key] isKindOfClass:[NSString class]]) {
                [company setValue:[organization[key] stringByDecodingXMLEntities] forKey:key];
            } else {
                [company setValue:organization[key] forKey:key];
            }
        }
    }
    
    NSMutableArray *jobsL = [[NSMutableArray alloc] init];
    for (NSDictionary *job in jobs) {
        MIIJob *jobL = [[MIIJob alloc] init];
        for (NSString *key in job) {
            if ([key isEqualToString:@"description"]) {
                [jobL setValue:[organization[key] stringByDecodingXMLEntities] forKey:@"desc"];
            } else if ([jobL respondsToSelector:NSSelectorFromString(key)]) {
                if ([job[key] isKindOfClass:[NSString class]]) {
                    [jobL setValue:[job[key] stringByDecodingXMLEntities] forKey:key];
                } else {
                    [jobL setValue:job[key] forKey:key];
                }
            }
        }
        [jobsL addObject:jobL];
    }
    company.jobs = [jobsL copy];
    
    return company;
}

@end
