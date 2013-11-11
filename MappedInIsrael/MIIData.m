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
    NSMutableArray *_companiesInCategory; // TBD: Make it NSArray
}
@end

@implementation MIIData

- (id)init {
    self = [super init];
    if (self) {
        // Init _companiesInCategory
        _companiesInCategory = [[NSMutableArray alloc] init];
        for(int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
            NSMutableArray *_companiesInCategoryArray = [[NSMutableArray alloc] init];
            [_companiesInCategory insertObject:_companiesInCategoryArray atIndex:i];
        }
        
        // Init _manager
        _manager = [[MIIManager alloc] init];
        _manager.communicator = [[MIICommunicator alloc] init];
        _manager.communicator.delegate = _manager;
        _manager.delegate = self;
        [_manager getAllCompanies]; // Get all data from MII API
    }
    return self;
}

- (void)didReceiveCompanies:(NSArray *)companies // TBD: Use CoreData to save it and load it in background for the next time.
{
    _companies = companies;
    
    // Add companies to _companiesInCategory
    for (MIICompany *company in companies) {
        NSString *companyCategory = company.companyCategory;
        NSUInteger categoryIndex = [[MIIData getAllCategories] indexOfObject:companyCategory];
        [[_companiesInCategory objectAtIndex:categoryIndex] addObject:company];
    }
    
    // Order _companiesInCategory
    for(int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"companyName" ascending:YES];
        [[_companiesInCategory objectAtIndex:i] sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    
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

- (NSArray *)getCompanies
{
    return _companies;
}

- (NSArray *)getCompaniesInCategory:(NSString *)category
{
    NSUInteger categoryIndex = [[MIIData getAllFormatedCategories] indexOfObject:category];
    return [[_companiesInCategory objectAtIndex:categoryIndex] copy];
}

- (NSInteger)getNumberOfCompaniesInCategory:(NSString *)category
{
    NSUInteger categoryIndex = [[MIIData getAllFormatedCategories] indexOfObject:category];
    return [[_companiesInCategory objectAtIndex:categoryIndex] count];
}

- (MIICompany *)category:(NSString *)category companyAtIndex:(NSInteger)index {
    NSUInteger categoryIndex = [[MIIData getAllFormatedCategories] indexOfObject:category];
    return [[_companiesInCategory objectAtIndex:categoryIndex] objectAtIndex:index];
}

@end
