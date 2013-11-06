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
#import "MIIAppDelegate.h"

#define INFO_VIEW_HEIGHT 350

@interface MIIViewController () <MIIManagerDelegate> {
    MIIManager *_manager;
    NSArray *_companies;
    enum displayedView _displayedView;
    UIView *infoView;
    UIView *greyView;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat statusBarHeight;
}
@end

@implementation MIIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // By default don't show Navigation Bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
    self.searchBar.delegate = self;
    self.tabBarController.delegate = self;
    
    // iPhone5 or iPhone4?
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    // infoView & greyView
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        screenHeight,
                                                        screenWidth,
                                                        INFO_VIEW_HEIGHT)];
    infoView.backgroundColor = [UIColor whiteColor];
    
    greyView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        self.navigationController.navigationBar.frame.size.height+statusBarHeight,
                                                        screenWidth,
                                                        screenHeight-(self.navigationController.navigationBar.frame.size.height+statusBarHeight))];
    greyView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    greyView.hidden = YES;
    
    _manager = [[MIIManager alloc] init];
    _manager.communicator = [[MIICommunicator alloc] init];
    _manager.communicator.delegate = _manager;
    _manager.delegate = self;
    [_manager getAllCompanies]; // Get all data from MII API
    
    // Show Done on the Navigation Bar
    UIBarButtonItem *submit = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                               target:self
                               action:@selector(dismissInfo:)];
    self.navigationItem.rightBarButtonItem = submit;
    
    // SignleTap on mapView
    UITapGestureRecognizer *singleTapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTapMap.numberOfTapsRequired = 1;
    singleTapMap.delaysTouchesEnded = YES;
    [self.mapView addGestureRecognizer:singleTapMap];
    
    // DoubleTap on mapView
    UITapGestureRecognizer *doubleTapMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTapMap.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:doubleTapMap];
    [singleTapMap requireGestureRecognizerToFail:doubleTapMap];
    
    // SingleTap on greyView
    UITapGestureRecognizer *singleTapGrey = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTapGrey.numberOfTapsRequired = 1;
    singleTapGrey.delaysTouchesEnded = YES;
    [greyView addGestureRecognizer:singleTapGrey];
    
    // DoubleTap on greyView
    UITapGestureRecognizer *doubleTapGrey = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTapGrey.numberOfTapsRequired = 2;
    [greyView addGestureRecognizer:doubleTapGrey];
    [singleTapGrey requireGestureRecognizerToFail:doubleTapGrey];
    
    // Defaults
    _displayedView = kMap;
    
    // Create Info Controller
    NSMutableArray *listOfViewControllers = [[NSMutableArray alloc] initWithArray:self.tabBarController.viewControllers];
    UIViewController *vc = [[UIViewController alloc] init];
	vc.title = @"Info";
	[listOfViewControllers addObject:vc];
	[self.tabBarController setViewControllers:listOfViewControllers
	                                 animated:YES];
    
    // On top of the Tab Bar
    [[[[UIApplication sharedApplication] delegate] window] addSubview:greyView];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:infoView];
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

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSUInteger indexOfTab = [tabBarController.viewControllers indexOfObject:viewController];
    NSLog(@"Tab %lu", (unsigned long)indexOfTab);
    
    if (indexOfTab == 0) {
        [self showCurrentLocation];
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        greyView.hidden = NO;
        
        [UIView animateWithDuration:0.6 animations:^{
            infoView.frame = CGRectMake(infoView.frame.origin.x,
                                       screenHeight-infoView.frame.size.height,
                                       infoView.frame.size.width,
                                       infoView.frame.size.height);
        } completion:^(BOOL finished) {
            if (finished)
            {
                _displayedView = kInfo;
            }
        }];
    }
    return NO;
}

- (IBAction)dismissInfo:(id)sender {
    [UIView animateWithDuration:0.6 animations:^{
        infoView.frame = CGRectMake(infoView.frame.origin.x,
                                    screenHeight,
                                    infoView.frame.size.width,
                                    infoView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished)
        {
            greyView.hidden = YES;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            _displayedView = kSearch;
        }
    }];
}

- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Single Tap");
    
    if (_displayedView == kInfo) {
        [self dismissInfo:self];
    } else {
        if (_displayedView == kSearch) {
            [UIView animateWithDuration:0.6 animations:^{
                self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                                  -self.searchBar.frame.size.height,
                                                  self.searchBar.frame.size.width,
                                                  self.searchBar.frame.size.height);
                self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x,
                                                                screenHeight,
                                                                self.tabBarController.tabBar.frame.size.width,
                                                                self.tabBarController.tabBar.frame.size.height);
            }];
            
            _displayedView = kMap;
        } else {
            [UIView animateWithDuration:0.6 animations:^{
                self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x,
                                                  statusBarHeight,
                                                  self.searchBar.frame.size.width,
                                                  self.searchBar.frame.size.height);
                self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x,
                                                                screenHeight-self.tabBarController.tabBar.frame.size.height,
                                                                self.tabBarController.tabBar.frame.size.width,
                                                                self.tabBarController.tabBar.frame.size.height);
            }];
            
            _displayedView = kSearch;
        }
    }
}

- (void)doubleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"Double Tap");
}

- (IBAction)showCurrentLocation {
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    [self.mapView setRegion:region animated:YES];
}

@end
