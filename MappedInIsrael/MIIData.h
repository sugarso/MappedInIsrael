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
#import "MIIPointAnnotation.h"


@interface MIIData : NSObject

@property (weak, nonatomic) id<MIIDataDelegate> delegate;

- (id)init;
+ (NSArray *)getAllFormatedCategories;
- (void)setSearch:(NSString *)search setWhosHiring:(BOOL)whosHiring;
- (NSArray *)getAllCompanies;
- (NSArray *)getCompaniesInCategory:(NSString *)category;
- (MIICompany *)category:(NSString *)category companyAtIndex:(NSInteger)index;
- (void)getCompany:(NSString *)id;
+ (NSArray *)whosHiring:(NSArray *)companies;

@end
