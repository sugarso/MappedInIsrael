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
    
    if (self.company) {
        MKCoordinateRegion region;
        region.center.latitude = [self.company.lat doubleValue];
        region.center.longitude = [self.company.lon doubleValue];
        region.span.latitudeDelta = 0.005;
        region.span.longitudeDelta = 0.005;
        [self.mapView setRegion:region animated:YES];
    } else {
        //[self showCurrentLocation:self]; TBD: only when location is ready
    }
}

- (void)dataIsReady
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (MIICompany *company in [self.data getCompaniesInCategory:@"All"]) {
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
                for (id<MKAnnotation> annotation in self.mapView.annotations) {
                    if ([annotation isKindOfClass:[KPAnnotation class]]) { // TBD: make sure zoomed in and see the company pin
                        KPAnnotation *ann = (KPAnnotation *)annotation;
                        if ([[ann.annotations anyObject] isKindOfClass:[MIIPointAnnotation class]]) {
                            MIIPointAnnotation *a = (MIIPointAnnotation *)[ann.annotations anyObject];
                            if ([a.company.companyName isEqual:self.company.companyName]) { // TBD: compare all company
                                [self.mapView selectAnnotation:annotation animated:YES];
                                self.company = nil;
                                return;
                            }
                        }
                    }
                }
            }
        });
    });
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
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                v.rightCalloutAccessoryView = btn;
                v.canShowCallout = YES;
            }
            
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
    [self performSegueWithIdentifier:@"showCompany:" sender:view];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *annotationView = (MKAnnotationView *)sender;
            KPAnnotation *annotation = (KPAnnotation *)annotationView.annotation;
            if ([[annotation.annotations anyObject] isKindOfClass:[MIIPointAnnotation class]]) {
                MIIPointAnnotation *a = (MIIPointAnnotation *)[annotation.annotations anyObject];
                MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
                controller.company = a.company;
            }
        }
    }
    
    if ([segue.identifier isEqualToString:@"showSearch:"]) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            MIITableViewController *controller = (MIITableViewController *)segue.destinationViewController;
            controller.data = self.data;
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

@end
