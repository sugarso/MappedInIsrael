//
//  MIIViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIViewController.h"

@interface MIIViewController () <MIIDataDelegate> {
    KPTreeController *_treeController;
}
@end

@implementation MIIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"MIIViewController";

    // Map
    self.mapView.delegate = self;
    _treeController = [[KPTreeController alloc] initWithMapView:self.mapView];
    _treeController.delegate = self;
    _treeController.animationOptions = UIViewAnimationOptionCurveEaseOut;
    
    // NavigationBar
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    self.navigationItem.rightBarButtonItem = search;
    self.navigationItem.hidesBackButton = YES;
    
    // Data
    _data = [[MIIData alloc] init];
    _data.delegate = self;
}

- (void)dataIsReady
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (MIICompany *company in [_data getCompaniesInCategory:@"All"]) {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_treeController setAnnotations:annotations];
    });
}

- (IBAction)showCurrentLocation:(id)sender {
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
    [self.mapView setRegion:region animated:YES];
}

- (void)showSearch:(id)sender {
    [self performSegueWithIdentifier:@"showSearch:" sender:sender];
}

#pragma mark - mapView

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *v = nil;
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *a = (KPAnnotation *)annotation;
        
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            return nil;
        }
        
        if ([a isCluster]) {
            v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Cluster"];
            
            if (!v) {
                v = [[MKPinAnnotationView alloc] initWithAnnotation:a reuseIdentifier:@"Cluster"];
            }
            
            NSString *numberOfCompanies = [NSString stringWithFormat:@"%d", ((KPAnnotation *)annotation).annotations.count];
            
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [l setTextAlignment:NSTextAlignmentCenter];
            [l setFont:[UIFont fontWithName:@"American Typewriter" size:12]];
            l.text = numberOfCompanies;
            
            MIIClusterView *clusterView;
            if ([numberOfCompanies intValue] < 10) {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 32, 32) color:[UIColor greenColor]];
            } else if ([numberOfCompanies intValue] < 100) {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 32, 32) color:[UIColor yellowColor]];
            } else {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 32, 32) color:[UIColor redColor]];
            }
            [clusterView addSubview:l];
            
            v.image = [MIIClusterView imageWithView:clusterView];
        } else {
            v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Company"];
            
            if (!v) {
                v = [[MKPinAnnotationView alloc] initWithAnnotation:[a.annotations anyObject] reuseIdentifier:@"Company"];
                v.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            }
            
            NSString *subtitle = ((MKPointAnnotation *)annotation).subtitle;
            UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", subtitle, @".png"]];
            v.image = i;
        }
        v.canShowCallout = YES;
    }
    
    return v;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [_treeController refresh:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"showCompany:" sender:view];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *title;
    
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *view = sender;
            title = view.annotation.title;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showSearch:"]) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            MIITableViewController *controller = (MIITableViewController *)segue.destinationViewController;
            controller.data = self.data;
        }
    }

    UIViewController *dst = segue.destinationViewController;
    dst.title = title;
}

#pragma mark - KPTreeControllerDelegate

- (void)treeController:(KPTreeController *)tree configureAnnotationForDisplay:(KPAnnotation *)annotation
{
    if (annotation.annotations.count == 1) {
        MKPointAnnotation *point = (MKPointAnnotation *)[annotation.annotations anyObject];
        annotation.title = [NSString stringWithFormat:@"%@", point.title];
        annotation.subtitle = [NSString stringWithFormat:@"%@", point.subtitle];
    }
}

@end
