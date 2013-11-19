//
//  MIIDataDelegate.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/11/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIICompany.h"

@protocol MIIDataDelegate <NSObject>

- (void)dataIsReady;
- (void)companyIsReady:(MIICompany *)company;
- (void)serverError;

@end
