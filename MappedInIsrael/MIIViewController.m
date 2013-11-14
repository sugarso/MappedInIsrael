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
    BOOL _fullScreen;
    CLLocationManager *_locationManager;
    CLLocation *_myHome;
}
@end

@implementation MIIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"MIIViewController";
    
    _myHome = [[CLLocation alloc] initWithLatitude:32.11303727704297 longitude:34.7941900883194];

    // Map
    self.mapView.delegate = self;
    _treeController = [[KPTreeController alloc] initWithMapView:self.mapView];
    _treeController.delegate = self;
    _treeController.animationOptions = UIViewAnimationOptionCurveEaseOut;
    _fullScreen = NO;
    // SignleTap on mapView
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delaysTouchesEnded = YES;
    singleTap.delegate = self;
    [self.mapView addGestureRecognizer:singleTap];
    
    // DoubleTap on mapView
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.mapView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // NavigationBar
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    self.navigationItem.rightBarButtonItem = search;
    self.navigationItem.hidesBackButton = YES;
    
    // Data
    self.data = [[MIIData alloc] init];
    self.data.delegate = self;

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if (self.company) {
        MKCoordinateRegion region;
        region.center.latitude = [self.company.lat doubleValue];
        region.center.longitude = [self.company.lon doubleValue];
        region.span.latitudeDelta = 0.005;
        region.span.longitudeDelta = 0.005;
        [self.mapView setRegion:region animated:YES];
    } else {
        [self showCurrentLocation:self];
    }
}

- (void)companyIsReady:(MIICompany *)company
{
    [self performSegueWithIdentifier:@"showCompany:" sender:company];
}

- (void)dataIsReady
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (MIICompany *company in [self.data getAllCompanies]) {
        // Coordinate
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [company.lat doubleValue];
        coordinate.longitude = [company.lon doubleValue];
        
        // Annotation
        MIIPointAnnotation *point = [[MIIPointAnnotation alloc] init];
        point.coordinate = coordinate;
        point.title = company.companyName;
        point.subtitle = company.companyCategory;
        point.company = company;
        
        [annotations addObject:point];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_treeController setAnnotations:annotations];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.company) {
                CLLocationDistance distance = 0;
                CLLocationCoordinate2D coordinate;
                coordinate.longitude = [self.company.lon floatValue];
                coordinate.latitude = [self.company.lat floatValue];
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, distance, distance);
                [self.mapView setRegion:region animated:NO];
                
                for (id<MKAnnotation> annotation in self.mapView.annotations) {
                    if ([annotation isKindOfClass:[KPAnnotation class]]) { // TBD: make sure zoomed in and see the company pin
                        KPAnnotation *ann = (KPAnnotation *)annotation;
                        if ([ann isCluster]) {
                            for (MIIPointAnnotation *a in ann.annotations) {
                                if ([a.company.companyName isEqual:self.company.companyName]) { // TBD: check by name is not so good
                                    [self performSelector:@selector(ZoomToAnnotation:)
                                               withObject:annotation
                                               afterDelay:0.5];
                                    self.company = nil;
                                    return;
                                }
                            }
                        } else {
                            MIIPointAnnotation *a = (MIIPointAnnotation *)[ann.annotations anyObject];
                            if ([a.company.companyName isEqual:self.company.companyName]) {
                                [self performSelector:@selector(ZoomToAnnotation:)
                                           withObject:annotation
                                           afterDelay:0.5];
                                self.company = nil;
                                return;
                            }
                        }
                    }
                }
                self.company = nil;
            }
        });
    });
}

- (void)ZoomToAnnotation:(id <MKAnnotation>)annotation
{
    [self.mapView selectAnnotation:annotation
                             animated:YES];
}

- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *v = [self.mapView hitTest:[gestureRecognizer locationInView:self.mapView] withEvent:nil];
    if (![v isKindOfClass:[MKAnnotationView class]]) {
        if (_fullScreen == NO) {
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            _fullScreen = YES;
        } else {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [UIApplication sharedApplication].statusBarHidden = NO;
            _fullScreen = NO;
        }
    }
}

- (void)doubleTapRecognized:(UIGestureRecognizer *)gestureRecognizer
{
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (IBAction)showCurrentLocation:(id)sender
{
    [_locationManager startUpdatingLocation];
}

- (void)showTelAviv:(id)sender
{
    MKCoordinateRegion region;
    region.center.latitude = _myHome.coordinate.latitude;
    region.center.longitude = _myHome.coordinate.longitude;
    region.span.latitudeDelta = 1;
    region.span.longitudeDelta = 1;
    [self.mapView setRegion:region animated:YES];
    self.showCurrentLocation.hidden = YES;
    [_locationManager stopUpdatingLocation];
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
            
            NSString *numberOfCompanies = [NSString stringWithFormat:@"%d", a.annotations.count];
            
            UILabel *l;
            MIIClusterView *clusterView;
            if ([numberOfCompanies intValue] < 10) {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 30, 30) color:[UIColor greenColor]];
                l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                [l setFont:[UIFont fontWithName:@"Hellvetika" size:10]];
            } else if ([numberOfCompanies intValue] < 100) {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 40, 40) color:[UIColor yellowColor]];
                l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
                [l setFont:[UIFont fontWithName:@"Hellvetika" size:12]];
            } else {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) color:[UIColor redColor]];
                l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                [l setFont:[UIFont fontWithName:@"Hellvetika" size:14]];
            }
            [l setTextAlignment:NSTextAlignmentCenter];
            l.text = numberOfCompanies;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            v.rightCalloutAccessoryView = btn;
            v.canShowCallout = YES;
            a.title = [NSString stringWithFormat:@"%d companies", [numberOfCompanies intValue]];
            BOOL first = YES;
            for (MIIPointAnnotation *annotation in a.annotations) {
                if (first) {
                    first = NO;
                    a.subtitle = annotation.company.companyName;
                } else {
                    a.subtitle = [NSString stringWithFormat:@"%@, %@", a.subtitle, annotation.company.companyName];
                }
            }
            [clusterView addSubview:l];
            
            v.image = [MIIClusterView imageWithView:clusterView];
        } else {
            v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Company"];
            
            if (!v) {
                v = [[MKPinAnnotationView alloc] initWithAnnotation:[a.annotations anyObject] reuseIdentifier:@"Company"];
            }
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            v.rightCalloutAccessoryView = btn;
            v.canShowCallout = YES;

            NSString *subtitle = ((MKPointAnnotation *)annotation).subtitle;
            UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", subtitle, @".png"]];
            v.image = i;
            
            a.title = [NSString stringWithFormat:@"%@", ((MKPointAnnotation *)annotation).title];
            a.subtitle = [NSString stringWithFormat:@"%@", ((MKPointAnnotation *)annotation).subtitle];
        }
    }
    
    return v;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [_treeController refresh:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    KPAnnotation *annotation = (KPAnnotation *)view.annotation;
    
    if ([annotation isCluster]) {
        [self performSegueWithIdentifier:@"showCompanies:" sender:view];
    } else {
        KPAnnotation *annotation = (KPAnnotation *)view.annotation;
        MIIPointAnnotation *a = (MIIPointAnnotation *)[annotation.annotations anyObject];
        [self.data getCompany:a.company.id];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MIICompany class]]) {
            MIICompany *company = (MIICompany *)sender;
            MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
            controller.company = company;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showSearch:"]) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            MIITableViewController *controller = (MIITableViewController *)segue.destinationViewController;
            controller.data = self.data;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showCompanies:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *annotationView = (MKAnnotationView *)sender;
            KPAnnotation *annotation = (KPAnnotation *)annotationView.annotation;
            MIITableViewController *controller = (MIITableViewController *)segue.destinationViewController;
            controller.data = self.data;
            controller.clusterAnnotation = [annotation.annotations allObjects];
        }
    }
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError error: %@", error);
    [self showTelAviv:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocationDistance distance = [newLocation distanceFromLocation:_myHome];
    NSLog(@"Distance: %f",distance);
    if (distance > 200000) {
        [self showTelAviv:self];
    } else {
        MKCoordinateRegion region;
        region.center.latitude = newLocation.coordinate.latitude;
        region.center.longitude = newLocation.coordinate.longitude;
        region.span.latitudeDelta = 0.03;
        region.span.longitudeDelta = 0.03;
        [self.mapView setRegion:region animated:YES];
        self.showCurrentLocation.hidden = NO;
        [_locationManager stopUpdatingLocation];
    }
}

@end
