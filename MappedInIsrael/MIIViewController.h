//
//  MIIViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GAITrackedViewController.h"
#import "KPTreeController.h"
#import "MIICompany.h"
#import "MIIData.h"

@interface MIIViewController : GAITrackedViewController <MKMapViewDelegate,UIGestureRecognizerDelegate,CLLocationManagerDelegate,KPTreeControllerDelegate,MIIDataDelegate>

@property (strong, nonatomic) MIIData *data;
@property (weak, nonatomic) MIICompany *company;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *showCurrentLocation;

@end
