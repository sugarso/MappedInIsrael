//
//  MIIPointAnnotation.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/13/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MIICompany.h"

@interface MIIPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) MIICompany *company;

@end
