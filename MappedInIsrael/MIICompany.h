//
//  MIICompany.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIICompany : NSObject

@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *companyCategory;
@property (strong, nonatomic) NSString *companySubCategory;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *lon;
@property (strong, nonatomic) NSString *lat;
@property (strong, nonatomic) NSString *hiringPageURL;

@end
