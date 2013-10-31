//
//  MIIHiringViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIHiringViewController.h"
#import "MIICompany.h"

@implementation MIIHiringViewController

- (void)reloadMap
{
    NSMutableArray * annotations = [[NSMutableArray alloc] init];
    
    for (MIICompany *company in self._companies) {
        if ((![company.hiringPageURL isEqual:[NSNull null]]) && (![company.hiringPageURL isEqualToString:@""])) {
            // Coordinate
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [company.lat doubleValue];
            coordinate.longitude = [company.lon doubleValue];
        
            // Annotation
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = coordinate;
            point.title = company.companyName;
            point.subtitle = company.companyCategory;
        
            [annotations addObject:point];
        }
    }
    
    // Clusters
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Building KD-Tree…");
        [self.mapView setAnnotations:annotations];
    });
}

@end
