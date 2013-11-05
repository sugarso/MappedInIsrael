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
    MIIManager *_manager;
    NSArray *_companies;
    BOOL showSearch;
}
@end

@implementation MIIViewController

@synthesize mapView;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.searchBar.delegate = self;
    
    _manager = [[MIIManager alloc] init];
    _manager.communicator = [[MIICommunicator alloc] init];
    _manager.communicator.delegate = _manager;
    _manager.delegate = self;
    
    // TBD:
    [_manager getAllCompanies];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                         selector:@selector(startFetchingCompanies:)
    //                                             name:@"kCLAuthorizationStatusAuthorized"
    //                                           object:nil];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delaysTouchesEnded = YES;
    [self.mapView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.searchBar resignFirstResponder];
    
    showSearch = false; // Default    
}

- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"single tap");
    [UIView animateWithDuration:0.5 animations:^{
        if (showSearch) {
            self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                              -self.searchBar.frame.size.height,
                                              self.searchBar.frame.size.width,
                                              self.searchBar.frame.size.height);
        } else {
            self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                              20,
                                              self.searchBar.frame.size.width,
                                              self.searchBar.frame.size.height);
        }
    }];
    showSearch = !showSearch;
}

- (void)doubleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"double tap");
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

- (NSString *)clusterTitleForMapView:(ADClusterMapView *)mapView
{
    return @"%d companies";
}

- (MKAnnotationView *)mapView:(ADClusterMapView *)mapView viewForClusterAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *reuseId = @"MapViewController";
    MKAnnotationView *view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    return view;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"MapViewController";
    MKAnnotationView *view = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];

    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    
    NSString *subtitle = ((MKPointAnnotation *)annotation).subtitle;
    UIImage *annImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", subtitle, @".png"]];
    view.image = annImage;
    
    return view;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"setCompany:" sender:view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setCompany:"]) {
        MKAnnotationView *aView = sender;
        UIViewController *mdvc = segue.destinationViewController;
        mdvc.title = aView.annotation.title;
    }
}

@end
