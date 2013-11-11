//
//  MIIViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIAppDelegate.h"
#import "MIICompany.h"
#import "MIIData.h"
#import "MIIViewController.h"

#define INFO_VIEW_HEIGHT 300
#define BORDERS_MARGIN 10
#define SEARCH_BAR_HEIGHT 44
#define SEGMENTED_CONTROL_HEIGHT 29

@interface MIIViewController () <MIIDataDelegate> {
    MIIData *_data;
    enum displayedView _displayedView;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat statusBarHeight;
    UISearchBar *mySearchBar;
    BOOL firstTime;
    BOOL showMap;
}
@end

@implementation MIIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(firstTime){
        [self showCurrentLocation];
        firstTime = NO;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    showMap = true;
    
    self.screenName = @"Map View";
    
    firstTime = YES;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.mapView.delegate = self;
    self.tableView.delegate  = self;
    self.tableView.dataSource = self;
    
    // iPhone5 or iPhone4?
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
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
    
    _data = [[MIIData alloc] init];
    _data.delegate = self;
}


- (void)dataIsReady
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadMap];
        [self.tableView reloadData];
    });
}

- (void)reloadMap
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (MIICompany *company in [_data getCompanies]) {
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


- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
    
    if (_displayedView == kInfo) {
    } else {
        if (_displayedView == kSearch) {
            
            CGRect fullScreenRect = CGRectMake(0,
                                        0,
                                        320,
                                        568);
            self.mapView.frame = fullScreenRect;
            //self.mainView.frame = fullScreenRect;
            [self.mainView sizeToFit];
            
            [self.mapV sizeToFit];
            

            
            [UIApplication sharedApplication].statusBarHidden = YES;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [UIView animateWithDuration:0.3 animations:^{
                self.whosHiringView.frame = CGRectMake(self.whosHiringView.frame.origin.x,
                                                     -self.whosHiringView.frame.size.height,
                                                     self.whosHiringView.frame.size.width,
                                                     self.whosHiringView.frame.size.height);
                
                
                
            }];

            
            _displayedView = kMap;
        } else {
            
            self.mainView.frame = CGRectMake(self.mainView.frame.origin.x,
                                             statusBarHeight+self.navigationController.toolbar.frame.size.height+self.whosHiringView.frame.size.height,
                                             self.mainView.frame.size.width,
                                             screenHeight-(statusBarHeight+self.navigationController.toolbar.frame.size.height+self.whosHiringView.frame.size.height));
            
            self.mapV.frame = CGRectMake(self.mapV.frame.origin.x,
                                             statusBarHeight+self.navigationController.toolbar.frame.size.height+self.whosHiringView.frame.size.height,
                                             self.mapV.frame.size.width,
                                             screenHeight-(statusBarHeight+self.navigationController.toolbar.frame.size.height+self.whosHiringView.frame.size.height));
            
            

            
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [UIApplication sharedApplication].statusBarHidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.whosHiringView.frame = CGRectMake(self.whosHiringView.frame.origin.x,
                                                      statusBarHeight+self.navigationController.toolbar.frame.size.height,
                                                      self.whosHiringView.frame.size.width,
                                                      self.whosHiringView.frame.size.height);
                
                self.mapView.frame = CGRectMake(self.mapView.frame.origin.x,
                                                statusBarHeight+self.navigationController.toolbar.frame.size.height+self.whosHiringView.frame.size.height,
                                                self.mapView.frame.size.width,
                                                screenHeight-(statusBarHeight+self.navigationController.toolbar.frame.size.height+self.whosHiringView.frame.size.height));
                
            }];
            

            

            
            _displayedView = kSearch;
        }
    }
}

- (void)doubleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
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
    if (showMap) {
        [UIView transitionFromView:self.mapV
                            toView:self.tableView
                          duration:0.7
                           options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromLeft
                        completion:nil];
        
        showMap = false;
        
        UIImage *image = [UIImage imageNamed:@"map-25.png"];
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [imageButton setImage:image forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
        
        self.navigationItem.rightBarButtonItem = buttonItem;
    } else {
        [UIView transitionFromView:self.tableView
                            toView:self.mapV
                          duration:0.7
                           options:UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromRight
                        completion:nil];
        showMap = true;
        
        UIImage *image = [UIImage imageNamed:@"align_justify-25.png"];
        UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [imageButton setImage:image forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
        
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
    
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
    for (MIICompany *company in [_data getCompanies]) {
        if ((mySearchBar.text == nil) ||
            ([mySearchBar.text isEqualToString:@""]) ||
            ([company.companyName rangeOfString:mySearchBar.text options:NSCaseInsensitiveSearch].length)) {
            [companies addObject:company];
        }
    }
    //self.companies = companies;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadMap];
    });
}

- (IBAction)bla:(id)sender {
    int *x = NULL; *x = 42;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[MIIData getAllFormatedCategories] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[MIIData getAllFormatedCategories] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *category = (NSString *)[[MIIData getAllFormatedCategories] objectAtIndex:section];
    return [_data getNumberOfCompaniesInCategory:category];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
    MIICompany *company = [_data category:category companyAtIndex:indexPath.row];
    
    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = company.companySubCategory;
    
    return cell;
}

@end
