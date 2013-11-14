//
//  MIIManager.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "MIIManagerDelegate.h"
#import "MIICommunicatorDelegate.h"

@class MIICommunicator;

@interface MIIManager : NSObject<MIICommunicatorDelegate>

@property (strong, nonatomic) MIICommunicator *communicator;
@property (weak, nonatomic) id<MIIManagerDelegate> delegate;

- (void)getAllCompanies;
- (void)getCompany:(NSString *)id;

@end
