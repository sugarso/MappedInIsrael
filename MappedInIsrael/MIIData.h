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

- (instancetype)init NS_DESIGNATED_INITIALIZER;
+ (NSArray *)getAllCategories;
+ (NSArray *)getAllFormatedCategories;
@property (NS_NONATOMIC_IOSONLY, getter=getAllCompanies, readonly, copy) NSArray *allCompanies;
- (NSArray *)getCompaniesWhosHiring:(BOOL)whosHiring;
- (void)getCompany:(NSString *)id;
- (void)setClusterAnnotation:(NSArray *)clusterAnnotation;
- (NSArray *)getClusterAnnotationWhosHiring:(BOOL)whosHiring;

@end
