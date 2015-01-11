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
    NSArray *_companiesInCategoryHiring;
    NSArray *_clusterAnnotationInCategory;
    NSArray *_clusterAnnotationInCategoryHiring;
}
@end

@implementation MIIData

- (instancetype)init {
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
    
    NSMutableArray *companiesTemp = [[NSMutableArray alloc] init];
    NSMutableArray *companiesHiringTemp = [[NSMutableArray alloc] init];
    
    // Init companies
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        [companiesTemp insertObject:[[NSMutableArray alloc] init] atIndex:i];
        [companiesHiringTemp insertObject:[[NSMutableArray alloc] init] atIndex:i];
    }
    
    // Add companies
    for (MIICompany *company in _companies) {
        NSString *companyCategory = company.companyCategory;
        NSUInteger categoryIndex = [[MIIData getAllCategories] indexOfObject:companyCategory];
        [companiesTemp[categoryIndex] addObject:company];
        
        // Check whos hiring
        if ((company.hiring != nil) &&
            (![company.hiring isKindOfClass:[NSNull class]]) &&
            (![company.hiring isEqualToString:@""])) {
            [companiesHiringTemp[categoryIndex] addObject:company];
        } else if ((![company.hiringPageURL isKindOfClass:[NSNull class]]) &&
            (![company.hiringPageURL isEqualToString:@""])) {
            [companiesHiringTemp[categoryIndex] addObject:company];
        }
    }
    
    // Order companies
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"companyName" ascending:YES];
        [companiesTemp[i] sortUsingDescriptors:@[sort]];
        [companiesHiringTemp[i] sortUsingDescriptors:@[sort]];
    }
    
    // Copy
    _companiesInCategory = [companiesTemp copy];
    _companiesInCategoryHiring = [companiesHiringTemp copy];
    
    [self.delegate dataIsReady];
}

- (void)fetchingCompaniesFailedWithError:(NSError *)error
{
    HelloBug(@"Error %@; %@", error, [error localizedDescription]);
    [self.delegate serverError];
}

+ (NSArray *)getAllCategories
{
    return @[@"community", @"coworking", @"accelerator", @"investor", @"service", @"startup", @"rdcenter"];
}

+ (NSArray *)getAllFormatedCategories
{
    return @[@"Community", @"Co-Working Space", @"Accelerator", @"Investor", @"Service", @"Startup", @"Enterprise"];
}

- (NSArray *)getAllCompanies {
    return _companies;
}

- (NSArray *)getCompaniesWhosHiring:(BOOL)whosHiring
{
    if (whosHiring) {
        return [_companiesInCategoryHiring copy];
    } else {
        return [_companiesInCategory copy];
    }
}

- (void)didReceiveCompany:(MIICompany *)company;
{
    [self.delegate companyIsReady:company];
}

- (void)fetchingCompanyFailedWithError:(NSError *)error
{
    HelloBug(@"Error %@; %@", error, [error localizedDescription]);
    [self.delegate serverError];
}

- (void)getCompany:(NSString *)id
{
    [_manager getCompany:id];
}

- (void)setClusterAnnotation:(NSArray *)clusterAnnotation
{
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    NSMutableArray *companiesHiring = [[NSMutableArray alloc] init];
    
    // Init companies
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        [companies insertObject:[[NSMutableArray alloc] init] atIndex:i];
        [companiesHiring insertObject:[[NSMutableArray alloc] init] atIndex:i];
    }
    
    // Add companies
    for (MIIPointAnnotation *companyAnnotation in clusterAnnotation) {
        MIICompany *company = companyAnnotation.company;
        NSString *companyCategory = company.companyCategory;
        NSUInteger categoryIndex = [[MIIData getAllCategories] indexOfObject:companyCategory];
        [companies[categoryIndex] addObject:company];
        
        // Check whos hiring
        if ((company.hiring != nil) &&
            (![company.hiring isKindOfClass:[NSNull class]]) &&
            (![company.hiring isEqualToString:@""])) {
            [companiesHiring[categoryIndex] addObject:company];
        } else if ((![company.hiringPageURL isKindOfClass:[NSNull class]]) &&
            (![company.hiringPageURL isEqualToString:@""])) {
            [companiesHiring[categoryIndex] addObject:company];
        }
    }
    
    // Order companies
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"companyName" ascending:YES];
        [companies[i] sortUsingDescriptors:@[sort]];
        [companiesHiring[i] sortUsingDescriptors:@[sort]];
    }
    
    // Copy
    _clusterAnnotationInCategory = [companies copy];
    _clusterAnnotationInCategoryHiring = [companiesHiring copy];
}

- (NSArray *)getClusterAnnotationWhosHiring:(BOOL)whosHiring
{
    if (whosHiring) {
        return [_clusterAnnotationInCategoryHiring copy];
    } else {
        return [_clusterAnnotationInCategory copy];
    }
}

@end
