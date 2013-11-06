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

enum displayedView
{
    kMap,
    kSearch,
    kInfo
};

@interface MIIViewController : UIViewController <MKMapViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,UITabBarControllerDelegate,UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet ADClusterMapView *mapView;

@end
