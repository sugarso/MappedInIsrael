//
//  MIIData.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/11/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIIDataDelegate.h"
#import "MIICompany.h"
#import "MIICommunicator.h"
#import "MIIManager.h"


@interface MIIData : NSObject

@property (weak, nonatomic) id<MIIDataDelegate> delegate;

- (id)init;
+ (NSArray *)getAllCategories;
+ (NSArray *)getAllFormatedCategories;

- (NSArray *)getCompanies;
- (NSArray *)getCompaniesInCategory:(NSString *)category;
- (MIICompany *)category:(NSString *)category companyAtIndex:(NSInteger)index;

- (NSArray *)searchCompanies:(NSString *)string;
- (NSArray *)category:(NSString *)category searchCompaniesByString:(NSString *)string;
- (MIICompany *)category:(NSString *)category index:(NSInteger)index searchCompaniesByString:(NSString *)string;
@end
