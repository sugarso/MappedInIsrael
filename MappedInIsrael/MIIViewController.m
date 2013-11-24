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

@interface MIIViewController () {
    KPTreeController *_treeController; // TBD: make @propertys
    BOOL _fullScreen;
    CLLocationManager *_locationManager;
    CLLocation *_myHome;
    //BOOL _waitingForCompany;
    BOOL _tbd;
    //BOOL _tbd2; // Not working!
}
@end

@implementation MIIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    // NavigationBar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearch:)];
    
    // Make sure to be the delegate every viewWillAppear
    self.data.delegate = self;
    
    if (self.company) {
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        CLLocationCoordinate2D coordinate;
        coordinate.longitude = [self.company.lon floatValue];
        coordinate.latitude = [self.company.lat floatValue];
        span.latitudeDelta = 0.0;
        span.longitudeDelta = 0.0;
        CLLocationCoordinate2D zoomLocation = coordinate;
        region.center = zoomLocation;
        region.span = span;
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:NO];
        
        for (id<MKAnnotation> annotation in [self.mapView annotationsInMapRect:self.mapView.visibleMapRect]) {
            if ([annotation isKindOfClass:[KPAnnotation class]]) {
                KPAnnotation *ann = (KPAnnotation *)annotation;
                if ([ann isCluster]) {
                    for (MIIPointAnnotation *a in ann.annotations) {
                        if ([a.company.companyName isEqual:self.company.companyName]) {
                            _tbd = YES;
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
    
    // GAITrackedViewController
    self.screenName = @"MIIViewController";
    
    // Data
    if (!self.data) {
        self.data = [[MIIData alloc] init];
    }
    
    // Default Location
    _myHome = [[CLLocation alloc] initWithLatitude:32.11303727704297 longitude:34.7941900883194];
    
    // Default Mode
    _fullScreen = NO;
    
    // Map
    self.mapView.delegate = self;
    _treeController = [[KPTreeController alloc] initWithMapView:self.mapView];
    _treeController.delegate = self;
    _treeController.animationOptions = UIViewAnimationOptionCurveEaseOut;
    _treeController.gridSize = CGSizeMake(30.f, 30.f);
    
    // SignleTap on mapView
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delaysTouchesEnded = NO;
    singleTap.delegate = self;
    //[self.mapView addGestureRecognizer:singleTap];
    
    // DoubleTap on mapView
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [self.mapView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // Location
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Show location onces
    if (!self.company) {
        [self showCurrentLocation:self];
    }
}

- (void)calloutTapped:(id)sender
{
    _fullScreen = NO;
}

- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *v = [self.mapView hitTest:[gestureRecognizer locationInView:self.mapView] withEvent:nil];
    //gestureRecognizer.view
    
    if ((![v isKindOfClass:[MKAnnotationView class]]) && (![v isKindOfClass:[MKPinAnnotationView class]])) {
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
    // nil
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
    [_locationManager stopUpdatingLocation];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showSearch:(id)sender
{
    [self performSegueWithIdentifier:@"showSearch:" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MIICompany class]]) {
            MIICompany *company = (MIICompany *)sender;
            MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
            controller.company = company;
            self.company = nil;
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

- (void)initMap:(id)sender
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

    [_treeController setAnnotations:annotations];
}

#pragma mark - MKMapViewDelegate

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
            
            NSString *numberOfCompanies = [NSString stringWithFormat:@"%d", a.annotations.count];
            
            UILabel *l;
            MIIClusterView *clusterView;
            if ([numberOfCompanies intValue] < 10) {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 55, 42) color:[UIColor colorWithHexString:@"#64b1e4" alpah:0.9]];
                l.font = [UIFont fontWithName:@"Helvetica" size:14];
                l = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
            } else if ([numberOfCompanies intValue] < 100) {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 65, 52) color:[UIColor colorWithHexString:@"#3498db" alpah:0.9]];
                l.font = [UIFont fontWithName:@"Helvetica" size:16];
                l = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 50, 50)];
            } else {
                clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 75, 62) color:[UIColor colorWithHexString:@"#0072bc" alpah:0.9]];
                l = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 60, 60)];
                l.font = [UIFont fontWithName:@"Helvetica" size:18];
            }
            l.textColor = [UIColor whiteColor];
            [l setTextAlignment:NSTextAlignmentCenter];
            l.text = numberOfCompanies;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            v.rightCalloutAccessoryView = btn;
            v.canShowCallout = YES;
            a.title = [NSString stringWithFormat:@"%d Organizations", [numberOfCompanies intValue]];
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
            a.subtitle = @""; //[NSString stringWithFormat:@"%@", ((MKPointAnnotation *)annotation).subtitle];
            
            UITapGestureRecognizer *tapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(calloutTapped:)];
            //[v addGestureRecognizer:tapGesture];
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
    [_treeController refresh:YES];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *annotation = (KPAnnotation *)view.annotation;
        if ([annotation isCluster]) {
            if (_tbd) {
                _tbd = NO;
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
           // _tbd2 = YES;
            
            KPAnnotation *annotation = (KPAnnotation *)view.annotation;
            MIIPointAnnotation *a = (MIIPointAnnotation *)[annotation.annotations anyObject];
            
            //if (!_waitingForCompany) {
                [self.data getCompany:a.company.id];
                [self performSegueWithIdentifier:@"showCompany:" sender:self];
                //_waitingForCompany = YES;
            //}
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
    //NSLog(@"Distance: %f",distance);
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

#pragma mark - MIIDataDelegate

- (void)companyIsReady:(MIICompany *)company
{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:company forKey:@"company"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"companyIsReady" object:nil userInfo:dict];
    
    //if (_waitingForCompany) {
        //[self performSegueWithIdentifier:@"showCompany:" sender:company];
    //    _waitingForCompany = NO;
    //}
}

- (void)dataIsReady
{
    [self initMap:self];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.data forKey:@"data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataIsReady" object:nil userInfo:dict];
}

// TBD: show error in other views!
- (void)serverError // TBD: Google Analytics
{
    //if (_waitingForCompany) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"Organization details are currently unavailable."
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK",nil];
        [alert show];
      //  _waitingForCompany = NO;
    //}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
