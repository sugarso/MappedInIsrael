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

@interface MIIViewController : UIViewController <MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet ADClusterMapView *mapView;

@end
