//
//  MIIViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ADClusterMapView.h"
#import "GAITrackedViewController.h"

enum displayedView
{
    kMap,
    kSearch,
    kInfo
};

@interface MIIViewController : GAITrackedViewController <MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UITabBarControllerDelegate,UITabBarDelegate>

@property (weak, nonatomic) IBOutlet ADClusterMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *categoriesBar;
@property (strong, nonatomic) NSArray *companies;

- (IBAction)showCurrentLocation;

@end
