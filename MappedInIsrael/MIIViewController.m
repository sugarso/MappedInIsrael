//
//  MIIViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIViewController.h"
#import "UIColor+MBCategory.h"
#import "KPAnnotation.h"
#import "MIIClusterView.h"
#import "MIITableViewController.h"
#import "MIICompanyViewController.h"

#define DEFAULT_LATITUDE 32.11303727704297
#define DEFAULT_LONGITUDE 34.7941900883194
#define USER_LOCATION_MAXIMUM_DISTANCE 200000

#define SMALL_CLUSTER 10
#define MEDIUM_CLUSTER 100
#define LARGE_CLUSTER INF

#define SMALL_CLUSTER_COLOR @"#64b1e4"
#define MEDIUM_CLUSTER_COLOR @"#3498db"
#define LARGE_CLUSER_COLOR @"#0072bc"

#define SMALL_CLUSTER_FONT 14
#define MEDIUM_CLUSTER_FONT 16
#define LARGE_CLUSER_FONT 18

#define SMALL_CLUSTER_DIAM 40
#define MEDIUM_CLUSTER_DIAM 50
#define LARGE_CLUSER_DIAM 60

#define SMALL_CLUSTER_ALPHA 0.9
#define MEDIUM_CLUSTER_ALPHA 0.9
#define LARGE_CLUSER_ALPHA 0.9

@interface MIIViewController ()
    @property (strong, nonatomic) MIIData *data;
    @property (strong, nonatomic) KPTreeController *treeController;
    @property (strong, nonatomic) CLLocationManager *locationManager;
    @property (nonatomic) BOOL firstShowCompany;
    @property (nonatomic) BOOL waitingForCompany;
@end

@implementation MIIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.company) {
        CLLocationCoordinate2D coordinate;
        coordinate.longitude = [self.company.lon floatValue];
        coordinate.latitude = [self.company.lat floatValue];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 0, 0);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion animated:NO];

        for (id<MKAnnotation> annotation in [self.mapView annotationsInMapRect:self.mapView.visibleMapRect]) {
            if ([annotation isKindOfClass:[KPAnnotation class]]) {
                KPAnnotation *ann = (KPAnnotation *)annotation;
                if ([ann isCluster]) {
                    for (MIIPointAnnotation *a in ann.annotations) {
                        if ([a.company.companyName isEqual:self.company.companyName]) {
                            self.firstShowCompany = YES;
                            [self.mapView selectAnnotation:ann animated:NO];
                        }
                    }
                } else {
                    MIIPointAnnotation *a = (MIIPointAnnotation *)[ann.annotations anyObject];
                    if ([a.company.companyName isEqual:self.company.companyName]) {
                        [self.mapView selectAnnotation:annotation animated:NO];
                    }
                }
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"MIIViewController";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                           target:self
                                                                                           action:@selector(showSearch:)];
    
    self.data = [[MIIData alloc] init];
    self.data.delegate = self;
    
    self.mapView.delegate = self;
    
    self.treeController = [[KPTreeController alloc] initWithMapView:self.mapView];
    self.treeController.delegate = self;
    self.treeController.animationOptions = UIViewAnimationOptionCurveEaseOut;
    self.treeController.gridSize = CGSizeMake(150.f, 150.f);
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    
    [self showCurrentLocation:self];
}

- (void)showSearch:(id)sender
{
    [self performSegueWithIdentifier:@"showSearch:" sender:sender];
}

- (IBAction)showCurrentLocation:(id)sender
{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    HelloBug(@"didFailWithError error: %@", error);
    [self showDefault:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationDistance distance = [newLocation distanceFromLocation:[[CLLocation alloc]
                                                                     initWithLatitude:DEFAULT_LATITUDE
                                                                     longitude:DEFAULT_LONGITUDE]];

    if (distance > USER_LOCATION_MAXIMUM_DISTANCE) {
        Hello(@"distance: %f", distance);
        [self showDefault:self];
    } else {
        self.showCurrentLocationButton.hidden = NO;
        MKCoordinateRegion region;
        region.center.latitude = newLocation.coordinate.latitude;
        region.center.longitude = newLocation.coordinate.longitude;
        region.span.latitudeDelta = 0.03;
        region.span.longitudeDelta = 0.03;
        [self.mapView setRegion:region animated:YES];
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)showDefault:(id)sender
{
    MKCoordinateRegion region;
    region.center.latitude = DEFAULT_LATITUDE;
    region.center.longitude = DEFAULT_LONGITUDE;
    region.span.latitudeDelta = 1;
    region.span.longitudeDelta = 1;
    [self.mapView setRegion:region animated:YES];
    [self.locationManager stopUpdatingLocation];
}

- (void)dataIsReady // TBD: Add timeout
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (MIICompany *company in [self.data getAllCompanies]) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [company.lat doubleValue];
        coordinate.longitude = [company.lon doubleValue];
        MIIPointAnnotation *point = [[MIIPointAnnotation alloc] init];
        point.coordinate = coordinate;
        point.title = company.companyName;
        point.subtitle = company.companyCategory;
        point.company = company;
        [annotations addObject:point];
    }
    [self.treeController setAnnotations:annotations];
    
    // Send data to table view (if table view is the active screen and data just arrived now)
    NSDictionary *dict = @{@"data": self.data};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataIsReady" object:nil userInfo:dict];
}

- (void)companyIsReady:(MIICompany *)company // TBD: Add timeout
{
    if ([self.navigationController.visibleViewController isKindOfClass:[MIIViewController class]]) {
        [self performSegueWithIdentifier:@"showCompany:" sender:company];
    } else {
        NSDictionary *dict = @{@"company": company};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"companyIsReady" object:nil userInfo:dict];
    }
}

- (void)serverError // TBD: Google Analytics
{
    // TBD: show error in other views!
    self.waitingForCompany = NO;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:@"Organization details are currently unavailable."
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"OK",nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MIICompany class]]) {
            MIICompany *company = (MIICompany *)sender;
            MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
            controller.company = company;
            self.company = nil;
            self.waitingForCompany = NO;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showSearch:"]) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            MIITableViewController *controller = (MIITableViewController *)segue.destinationViewController;
            controller.data = self.data;
            controller.clusterAnnotation = nil;
            self.company = nil;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showCompanies:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *annotationView = (MKAnnotationView *)sender;
            KPAnnotation *annotation = (KPAnnotation *)annotationView.annotation;
            MIITableViewController *controller = (MIITableViewController *)segue.destinationViewController;
            controller.data = self.data;
            controller.clusterAnnotation = [annotation.annotations allObjects];
            self.company = nil;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *v = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *a = (KPAnnotation *)annotation;
        
        if ([a isCluster]) {
            v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Cluster"];
            
            if (!v) {
                v = [[MKPinAnnotationView alloc] initWithAnnotation:a reuseIdentifier:@"Cluster"];
            }
            
            NSString *numberOfCompanies = [NSString stringWithFormat:@"%lu", (unsigned long)a.annotations.count];
            UILabel *clusterLabel;
            MIIClusterView *clusterView;
            if ([numberOfCompanies intValue] < SMALL_CLUSTER) {
                clusterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CLUSTER_Y_OFF, SMALL_CLUSTER_DIAM, SMALL_CLUSTER_DIAM)];
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, SMALL_CLUSTER_DIAM+CLUSTER_X_OFF, SMALL_CLUSTER_DIAM+CLUSTER_Y_OFF)
                                                              color:[UIColor colorWithHexString:SMALL_CLUSTER_COLOR alpah:SMALL_CLUSTER_ALPHA]];
                clusterLabel.font = [UIFont fontWithName:@"Helvetica" size:SMALL_CLUSTER_FONT];
            } else if ([numberOfCompanies intValue] < MEDIUM_CLUSTER) {
                clusterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CLUSTER_Y_OFF, MEDIUM_CLUSTER_DIAM, MEDIUM_CLUSTER_DIAM)];
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, MEDIUM_CLUSTER_DIAM+CLUSTER_X_OFF, MEDIUM_CLUSTER_DIAM+CLUSTER_Y_OFF)
                                                              color:[UIColor colorWithHexString:MEDIUM_CLUSTER_COLOR alpah:MEDIUM_CLUSTER_ALPHA]];
                
                clusterLabel.font = [UIFont fontWithName:@"Helvetica" size:MEDIUM_CLUSTER_FONT];
            } else {
                clusterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CLUSTER_Y_OFF, LARGE_CLUSER_DIAM, LARGE_CLUSER_DIAM)];
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, LARGE_CLUSER_DIAM+CLUSTER_X_OFF, LARGE_CLUSER_DIAM+CLUSTER_Y_OFF)
                                                              color:[UIColor colorWithHexString:LARGE_CLUSER_COLOR alpah:LARGE_CLUSER_ALPHA]];
                clusterLabel.font = [UIFont fontWithName:@"Helvetica" size:LARGE_CLUSER_FONT];
            }
            clusterLabel.textColor = [UIColor whiteColor];
            [clusterLabel setTextAlignment:NSTextAlignmentCenter];
            clusterLabel.text = numberOfCompanies;
            [clusterView addSubview:clusterLabel];
            v.image = [MIIClusterView imageWithView:clusterView];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            v.rightCalloutAccessoryView = btn;
            v.canShowCallout = NO;
            if (self.company) {
                for (MIIPointAnnotation *annotation in a.annotations) {
                    if ([annotation.company.companyName isEqual:self.company.companyName]) {
                        v.canShowCallout = YES;
                    }
                }
            }
            
            a.title = [NSString stringWithFormat:@"%d Organizations", [numberOfCompanies intValue]];
            BOOL first = YES;
            for (MIIPointAnnotation *annotation in a.annotations) {
                if (first) {
                    first = NO;
                    a.subtitle = annotation.company.companyName;
                } else {
                    a.subtitle = [NSString stringWithFormat:@"%@, %@", a.subtitle, annotation.company.companyName];
                }
            }
        } else {
            v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Company"];
            
            if (!v) {
                v = [[MKPinAnnotationView alloc] initWithAnnotation:[a.annotations anyObject] reuseIdentifier:@"Company"];
            }

            NSString *subtitle = ((MKPointAnnotation *)annotation).subtitle;
            UIImage *i = [UIImage imageNamed:subtitle];
            v.image = i;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            v.rightCalloutAccessoryView = btn;
            v.canShowCallout = YES;
            
            a.title = [NSString stringWithFormat:@"%@", ((MKPointAnnotation *)annotation).title];
            a.subtitle = [NSString stringWithFormat:@"%@", ((MKPointAnnotation *)annotation).subtitle];
        }
    }
    
    return v;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKAnnotationView* annotationView = [mapView viewForAnnotation:userLocation];
    annotationView.canShowCallout = NO;
    userLocation.title = @"";
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.treeController refresh:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *annotation = (KPAnnotation *)view.annotation;
        if ([annotation isCluster]) {
            if (self.firstShowCompany) {
                self.firstShowCompany = NO;
            } else {
                [self performSegueWithIdentifier:@"showCompanies:" sender:view];
            }
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *annotation = (KPAnnotation *)view.annotation;
        if ([annotation isCluster]) {
            if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
                [self performSegueWithIdentifier:@"showCompanies:" sender:view];
            }
        } else {
            KPAnnotation *annotation = (KPAnnotation *)view.annotation;
            MIIPointAnnotation *a = (MIIPointAnnotation *)[annotation.annotations anyObject];
            
            if (!self.waitingForCompany) {
                [self.data getCompany:a.company.id];
                self.waitingForCompany = YES;
            }
        }
    }
}

- (void)treeController:(KPTreeController *)tree configureAnnotationForDisplay:(KPAnnotation *)annotation
{
    if (annotation.annotations.count == 1) {
        MKPointAnnotation *point = (MKPointAnnotation *)[annotation.annotations anyObject];
        annotation.title = [NSString stringWithFormat:@"%@", point.title];
        annotation.subtitle = [NSString stringWithFormat:@"%@", point.subtitle];
    }
}

@end
