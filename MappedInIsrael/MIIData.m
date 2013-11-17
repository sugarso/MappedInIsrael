//
//  MIIData.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/11/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIData.h"

@interface MIIData () <MIIManagerDelegate> {
    MIIManager *_manager;
    NSArray *_companies;
    NSArray *_companiesInCategory;
    NSArray *_clusterAnnotationInCategory;
}
@end

@implementation MIIData

- (id)init {
    self = [super init];
    if (self) {
        // Init _manager
        _manager = [[MIIManager alloc] init];
        _manager.communicator = [[MIICommunicator alloc] init];
        _manager.communicator.delegate = _manager;
        _manager.delegate = self;
        [_manager getAllCompanies]; // Get all data from MII API
    }
    return self;
}

- (void)didReceiveCompanies:(NSArray *)companies
{
    _companies = companies;
    [self setSearch:nil setWhosHiring:false];
    [self.delegate dataIsReady];
}

- (void)fetchingCompaniesFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

+ (NSArray *)getAllCategories
{
    return @[@"startup", @"accelerator", @"coworking", @"investor", @"rdcenter", @"community", @"service"];
}

+ (NSArray *)getAllFormatedCategories
{
    return @[@"Startups", @"Accelerators", @"Coworking", @"Investors", @"R&D Centers", @"Community", @"Services"];
}

- (NSArray *)getAllCompanies {
    return _companies;
}

- (void)setSearch:(NSString *)search setWhosHiring:(BOOL)whosHiring
{
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    
    // Init companies
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        NSMutableArray *companiesArray = [[NSMutableArray alloc] init];
        [companies insertObject:companiesArray atIndex:i];
    }
    
    // Add companies
    for (MIICompany *company in _companies) {
        NSString *companyCategory = company.companyCategory;
        NSUInteger categoryIndex = [[MIIData getAllCategories] indexOfObject:companyCategory];
        // Check whosHiring BOOL
        if ((whosHiring == NO) ||
            ((whosHiring == YES) &&
             (![company.hiringPageURL isKindOfClass:[NSNull class]]) &&
             (![company.hiringPageURL isEqualToString:@""]))) {
            // Check search string
            if ((search == nil) ||
                ([search isEqualToString:@""]) ||
                ([company.companyName rangeOfString:search options:NSCaseInsensitiveSearch].length)) {
                [[companies objectAtIndex:categoryIndex] addObject:company];
            }
        }
    }
    
    // Order companies
    for(int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"companyName" ascending:YES];
        [[companies objectAtIndex:i] sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    
    // Copy
    _companiesInCategory = [companies copy];
}

- (NSArray *)getCompaniesInCategory:(NSString *)category
{
    NSUInteger categoryIndex = [[MIIData getAllFormatedCategories] indexOfObject:category];
    return [[_companiesInCategory objectAtIndex:categoryIndex] copy];
}

- (MIICompany *)category:(NSString *)category companyAtIndex:(NSInteger)index
{
    NSUInteger categoryIndex = [[MIIData getAllFormatedCategories] indexOfObject:category];
    return [[_companiesInCategory objectAtIndex:categoryIndex] objectAtIndex:index];
}

- (void)didReceiveCompany:(MIICompany *)company;
{
    [self.delegate companyIsReady:company];
}

- (void)fetchingCompanyFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

- (void)getCompany:(NSString *)id
{
    [_manager getCompany:id];
}

- (void)setClusterAnnotation:(NSArray *)clusterAnnotation
{
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    
    // Init companies
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        NSMutableArray *companiesArray = [[NSMutableArray alloc] init];
        [companies insertObject:companiesArray atIndex:i];
    }
    
    // Add companies
    for (MIIPointAnnotation *companyAnnotation in clusterAnnotation) {
        MIICompany *company = companyAnnotation.company;
        NSString *companyCategory = company.companyCategory;
        NSUInteger categoryIndex = [[MIIData getAllCategories] indexOfObject:companyCategory];
        [[companies objectAtIndex:categoryIndex] addObject:company];

    }
    
    // Order companies
    for(int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"companyName" ascending:YES];
        [[companies objectAtIndex:i] sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    
    // Copy
    _clusterAnnotationInCategory = [companies copy];
}

- (NSArray *)getClusterAnnotationInCategory:(NSString *)category whosHiring:(BOOL)whosHiring
{
    NSUInteger categoryIndex = [[MIIData getAllFormatedCategories] indexOfObject:category];
    NSArray *clusterAnnotationInCategory = [[_clusterAnnotationInCategory objectAtIndex:categoryIndex] copy];
    
    if (whosHiring) {
        NSMutableArray *hiringCompaniesAnnotation = [[NSMutableArray alloc] init];
        
        // Add companies
        for (MIICompany *company in clusterAnnotationInCategory) {
            // Check whosHiring BOOL
            if ((![company.hiringPageURL isKindOfClass:[NSNull class]]) &&
                (![company.hiringPageURL isEqualToString:@""])) {
                [hiringCompaniesAnnotation addObject:company];
            }
        }
        
        return [hiringCompaniesAnnotation copy];
        
    } else {
        return clusterAnnotationInCategory;
    }
}

@end
