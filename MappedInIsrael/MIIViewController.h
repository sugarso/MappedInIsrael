//
//  MIIViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MIIAppDelegate.h"
#import "GAITrackedViewController.h"
#import "KPTreeController.h"
#import "KPAnnotation.h"
#import "MIICompany.h"
#import "MIIData.h"
#import "MIITableViewController.h"
#import "MIIClusterView.h"
#import "MIICompanyViewController.h"
#import "MIIPointAnnotation.h"

@interface MIIViewController : GAITrackedViewController <MKMapViewDelegate,UIGestureRecognizerDelegate,KPTreeControllerDelegate>

@property (nonatomic) BOOL dontRefreshData;
@property (strong, nonatomic) MIIData *data;
@property (weak, nonatomic) MIICompany *company;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (void)dataIsReady;

@end
