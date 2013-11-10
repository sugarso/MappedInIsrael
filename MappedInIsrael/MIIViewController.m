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

#define INFO_VIEW_HEIGHT 300
#define BORDERS_MARGIN 10
#define SEARCH_BAR_HEIGHT 44
#define SEGMENTED_CONTROL_HEIGHT 29

@interface MIIViewController () <MIIManagerDelegate> {
    MIIManager *_manager;
    NSArray *_allCompanies;
    enum displayedView _displayedView;
    UIView *infoView;
    UIView *grayView;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat statusBarHeight;
    UISearchBar *mySearchBar;
    UISegmentedControl *segmentedControl;
}
@end

@implementation MIIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showCurrentLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Map View";
    
    self.navigationItem.hidesBackButton = YES;
    
    self.mapView.delegate = self;
    self.tabBarController.delegate = self;
    
    // iPhone5 or iPhone4?
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    // infoView & grayView
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        screenHeight,
                                                        screenWidth,
                                                        INFO_VIEW_HEIGHT)];
    infoView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    
    UIView *segmentedControlView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    screenWidth,
                                                                    SEGMENTED_CONTROL_HEIGHT+2*BORDERS_MARGIN)];
    segmentedControlView.backgroundColor = [[UIColor whiteColor]  colorWithAlphaComponent:0.8f];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Who's Hiring?"]];
    segmentedControl.frame = CGRectMake(BORDERS_MARGIN,
                                        BORDERS_MARGIN,
                                        screenWidth-2*BORDERS_MARGIN,
                                        SEGMENTED_CONTROL_HEIGHT);
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(updateMap:) forControlEvents:UIControlEventValueChanged];
    [segmentedControlView addSubview:segmentedControl];
    [infoView addSubview:segmentedControlView];
    
    UIView *vc1 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          SEGMENTED_CONTROL_HEIGHT+2*BORDERS_MARGIN+1,
                                                          screenWidth,
                                                          SEGMENTED_CONTROL_HEIGHT+2*BORDERS_MARGIN)];
    vc1.backgroundColor = [[UIColor whiteColor]  colorWithAlphaComponent:0.7f];
    [infoView addSubview:vc1];
    
    UIView *vc2 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          2*SEGMENTED_CONTROL_HEIGHT+4*BORDERS_MARGIN+2,
                                                          screenWidth,
                                                          SEGMENTED_CONTROL_HEIGHT+2*BORDERS_MARGIN)];
    vc2.backgroundColor = [[UIColor whiteColor]  colorWithAlphaComponent:0.7f];
    [infoView addSubview:vc2];
    
    UIView *vc3 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                           3*SEGMENTED_CONTROL_HEIGHT+6*BORDERS_MARGIN+3,
                                                           screenWidth,
                                                           SEGMENTED_CONTROL_HEIGHT+2*BORDERS_MARGIN)];
    vc3.backgroundColor = [[UIColor whiteColor]  colorWithAlphaComponent:0.7f];
    [infoView addSubview:vc3];
    
    UIView *vc4 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                           4*SEGMENTED_CONTROL_HEIGHT+8*BORDERS_MARGIN+4,
                                                           screenWidth,
                                                           SEGMENTED_CONTROL_HEIGHT+2*BORDERS_MARGIN)];
    vc4.backgroundColor = [[UIColor whiteColor]  colorWithAlphaComponent:0.7f];
    [infoView addSubview:vc4];
    
    UIView *vc5 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                           5*SEGMENTED_CONTROL_HEIGHT+10*BORDERS_MARGIN+5,
                                                           screenWidth,
                                                           SEGMENTED_CONTROL_HEIGHT+2*BORDERS_MARGIN)];
    vc5.backgroundColor = [[UIColor whiteColor]  colorWithAlphaComponent:0.7f];
    [infoView addSubview:vc5];
    
    grayView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                        self.navigationController.navigationBar.frame.size.height+statusBarHeight,
                                                        screenWidth,
                                                        screenHeight-(self.navigationController.navigationBar.frame.size.height+statusBarHeight))];
    grayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    grayView.hidden = YES;
    
    _manager = [[MIIManager alloc] init];
    _manager.communicator = [[MIICommunicator alloc] init];
    _manager.communicator.delegate = _manager;
    _manager.delegate = self;
    [_manager getAllCompanies]; // Get all data from MII API
    
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
    
    // SingleTap on grayView
    UITapGestureRecognizer *singleTapGray = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTapGray.numberOfTapsRequired = 1;
    singleTapGray.delaysTouchesEnded = YES;
    [grayView addGestureRecognizer:singleTapGray];
    
    // DoubleTap on grayView
    UITapGestureRecognizer *doubleTapGray = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapRecognized:)];
    doubleTapGray.numberOfTapsRequired = 2;
    [grayView addGestureRecognizer:doubleTapGray];
    [singleTapGray requireGestureRecognizerToFail:doubleTapGray];
    
    // Defaults
    _displayedView = kSearch;
    
    // Create Info Controller
    NSMutableArray *listOfViewControllers = [[NSMutableArray alloc] initWithArray:self.tabBarController.viewControllers];
    UIViewController *vc = [[UIViewController alloc] init];
	vc.title = @"Info";
	[listOfViewControllers addObject:vc];
	[self.tabBarController setViewControllers:listOfViewControllers
	                                 animated:YES];
    
    // searchBar
    [self addSearchBar:self];
    
    // On top of the Tab Bar
    [[[[UIApplication sharedApplication] delegate] window] addSubview:grayView];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:infoView];
}

- (void)didReceiveCompanies:(NSArray *)companies
{
    self.companies = companies;
    _allCompanies = companies;
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
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (MIICompany *company in self.companies) {
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
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
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
        grayView.hidden = NO;
        
        self.navigationItem.titleView = nil;
        self.navigationItem.title = @"Info";
        
        // Show Done on the Navigation Bar
        UIBarButtonItem *submit = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                   target:self
                                   action:@selector(dismissInfo:)];
        self.navigationItem.rightBarButtonItem = submit;
        
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
    self.navigationItem.rightBarButtonItem = nil;
    [self addSearchBar:self];
    
    [UIView animateWithDuration:0.6 animations:^{
        infoView.frame = CGRectMake(infoView.frame.origin.x,
                                    screenHeight,
                                    infoView.frame.size.width,
                                    infoView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished)
        {
            grayView.hidden = YES;
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
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [UIView animateWithDuration:0.3 animations:^{
                self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x,
                                                                screenHeight,
                                                                self.tabBarController.tabBar.frame.size.width,
                                                                self.tabBarController.tabBar.frame.size.height);
                self.categoriesBar.frame = CGRectMake(self.categoriesBar.frame.origin.x,
                                                     -self.categoriesBar.frame.size.height,
                                                     self.categoriesBar.frame.size.width,
                                                     self.categoriesBar.frame.size.height);
            }];
            
            _displayedView = kMap;
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                self.tabBarController.tabBar.frame = CGRectMake(self.tabBarController.tabBar.frame.origin.x,
                                                                screenHeight-self.tabBarController.tabBar.frame.size.height,
                                                                self.tabBarController.tabBar.frame.size.width,
                                                                self.tabBarController.tabBar.frame.size.height);
                self.categoriesBar.frame = CGRectMake(self.categoriesBar.frame.origin.x,
                                                      statusBarHeight+self.navigationController.toolbar.frame.size.height,
                                                      self.categoriesBar.frame.size.width,
                                                      self.categoriesBar.frame.size.height);
            }];
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [UIApplication sharedApplication].statusBarHidden = NO;
            
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
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
    [self.mapView setRegion:region animated:YES];
}

- (void)addSearchBar:(id)sender {
    mySearchBar = [UISearchBar new];
    [mySearchBar sizeToFit];
    mySearchBar.delegate = self;
    mySearchBar.searchBarStyle = UISearchBarStyleMinimal;
    mySearchBar.placeholder = @"Search jobs, companies...";
    
    UIImage *image = [UIImage imageNamed:@"align_justify-25.png"];
    UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [imageButton setImage:image forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
    
    self.navigationItem.rightBarButtonItem = buttonItem;
    self.navigationItem.titleView = mySearchBar;
}

- (void)buttonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showTable:" sender:self.view];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Search: %@", searchText);
    [self updateMap:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (IBAction)updateMap:(id)sender {
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    for (MIICompany *company in _allCompanies) {
        if ((mySearchBar.text == nil) ||
            ([mySearchBar.text isEqualToString:@""]) ||
            ([company.companyName rangeOfString:mySearchBar.text].location != NSNotFound)) {
            if ((company.hiringPageURL == nil) ||
                (segmentedControl.selectedSegmentIndex == 0) ||
                ((segmentedControl.selectedSegmentIndex == 1) && (company.hiringPageURL != nil))) {
                [companies addObject:company];
            }
        }
    }
    self.companies = companies;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadMap];
    });
}

@end
