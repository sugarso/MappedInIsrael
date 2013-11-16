//
//  MIICompanyViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/1/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GAITrackedViewController.h"
#import "MIICompany.h"
#import "MIIPointAnnotation.h"

@interface MIICompanyViewController : GAITrackedViewController <MKMapViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) MIICompany *company;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIView *tableSuperView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *nameSuperView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *homePageLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;

@end
