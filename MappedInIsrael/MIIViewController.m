//
//  MIIViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIViewController.h"
#import "MIICompany.h"
#import "MIICommunicator.h"
#import "MIIManager.h"

@interface MIIViewController () <MIIManagerDelegate> {
    NSArray *_companies;
    MIIManager *_manager;
}
@end

@implementation MIIViewController

@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    
    _manager = [[MIIManager alloc] init];
    _manager.communicator = [[MIICommunicator alloc] init];
    _manager.communicator.delegate = _manager;
    _manager.delegate = self;
    
    [_manager getAllCompanies];
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(startFetchingCompanies:)
    //                                             name:@"kCLAuthorizationStatusAuthorized"
    //                                           object:nil];
    
}

- (void)startFetchingCompanies:(NSNotification *)notification
{
    [_manager getAllCompanies];
}

- (void)didReceiveCompanies:(NSArray *)companies
{
    _companies = companies;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadMap];
    });
}

- (void)fetchingCompaniesFailedWithError:(NSError *)error
{
    NSLog(@"Error %@; %@", error, [error localizedDescription]);
}

- (void)reloadMap
{
    NSMutableArray * annotations = [[NSMutableArray alloc] init];
    
    for (MIICompany *company in _companies) {
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
    
    // Clusters
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Building KD-Tree…");
        [self.mapView setAnnotations:annotations];
    });
}

@end
