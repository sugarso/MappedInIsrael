//
//  MIICommunicator.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol MIICommunicatorDelegate;

@interface MIICommunicator : NSObject

@property (weak, nonatomic) id<MIICommunicatorDelegate> delegate;

- (void)getAllCompanies;

@end
