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
#import "MIIClusterView.h"

@interface MIIViewController () <MIIDataDelegate> {
    MIIData *_data;
    UISearchBar *_searchBar;    
    BOOL _showingMap;
    NSArray const *_flipMapTableIcons;
}
@end

@implementation MIIViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showCurrentLocation:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Defaults
    _showingMap = YES;
    self.screenName = @"MIIViewController";
    _flipMapTableIcons = @[@"map-25.png",@"align_justify-25.png"];

    // Map
    self.map.delegate = self;
    
    // SearchBar
    _searchBar = [UISearchBar new];
    [_searchBar sizeToFit];
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.placeholder = @"Search jobs, companies...";
    self.navigationItem.titleView = _searchBar;
    UIImage *image = [UIImage imageNamed:[_flipMapTableIcons objectAtIndex:1]];
    [self flipMapTableIcon:image];
    
    // Data
    _data = [[MIIData alloc] init];
    _data.delegate = self;
    
    // updateFilter every UIControlEventValueChanged
    [self.whosHiring addTarget:self action:@selector(updateFilter:) forControlEvents:UIControlEventValueChanged];
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
        [self.map addAnnotations:annotations];
    });
}

- (IBAction)showCurrentLocation:(id)sender {
    MKCoordinateRegion region;
    region.center.latitude = self.map.userLocation.coordinate.latitude;
    region.center.longitude = self.map.userLocation.coordinate.longitude;
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
    [self.map setRegion:region animated:YES];
}

- (void)flipMapTableIcon:(UIImage *)icon
{
    UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [imageButton setImage:icon forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(flipMapTable:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)updateFilter:(id)sender
{
    NSLog(@"Search: %@, SegmentIndex: %d", _searchBar.text, self.whosHiring.selectedSegmentIndex);
    if (self.whosHiring.selectedSegmentIndex == 0) {
        [_data setSearch:_searchBar.text setWhosHiring:NO];
    } else {
        [_data setSearch:_searchBar.text setWhosHiring:YES];
    }
    [self dataIsReady];
}

- (void)flipMapTable:(id)sender {
    UIImage *image;
    UIView *src;
    UIView *dst;
    UIViewAnimationOptions animation;
    
    if (_showingMap) {
        src = self.mapView;
        dst = self.tableView;
        animation = UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromLeft;
        image = [UIImage imageNamed:[_flipMapTableIcons objectAtIndex:0]];
        _showingMap = NO;
    } else {
        src = self.tableView;
        dst = self.mapView;
        animation = UIViewAnimationOptionShowHideTransitionViews|UIViewAnimationOptionTransitionFlipFromRight;
        image = [UIImage imageNamed:[_flipMapTableIcons objectAtIndex:1]];
        _showingMap = YES;
    }
    
    [UIView transitionFromView:src
                        toView:dst
                      duration:0.7
                       options:animation
                    completion:^(BOOL finished) {
                        [self flipMapTableIcon:image];
                    }];
}

#pragma mark - mapView

/*
- (NSString *)clusterTitleForMapView:(ADClusterMapView *)mapView
{
    return @"%d companies";
}

- (MKAnnotationView *)mapView:(ADClusterMapView *)mapView viewForClusterAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *reuseId = @"ClusterMapViewController";
    MKAnnotationView *view = [self.map dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
    }
    
    NSString *title = ((MKPointAnnotation *)annotation).title;
    NSString *numberOfCompanies = [[[title componentsSeparatedByString:@" "] subarrayWithRange:NSMakeRange(0, 1)] objectAtIndex:0];
    
    UILabel *annLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [annLabel setTextAlignment:NSTextAlignmentCenter];
    annLabel.text = numberOfCompanies;
    
    MIIClusterView *clusterView;
    if ([numberOfCompanies intValue] < 10) {
        clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 32, 32) color:[UIColor greenColor]];
    } else if ([numberOfCompanies intValue] < 20) {
        clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 32, 32) color:[UIColor yellowColor]];
    } else {
        clusterView = [[MIIClusterView alloc] initWithFrame:CGRectMake(0, 0, 32, 32) color:[UIColor redColor]];
    }
    [clusterView addSubview:annLabel];

    view.image = [MIIClusterView imageWithView:clusterView];

    return view;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    static NSString *reuseId = @"MapViewController";
    MKAnnotationView *view = [self.map dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
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
*/

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"setCompanyByPin:" sender:view];
}

#pragma mark - searchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateFilter:searchBar];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[MIIData getAllFormatedCategories] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_data getCompaniesInCategory:[[MIIData getAllFormatedCategories] objectAtIndex:section]].count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *category = (NSString *)[[MIIData getAllFormatedCategories] objectAtIndex:section];
    return [_data getCompaniesInCategory:category].count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"setCompanyByCell:" sender:indexPath];
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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *title;
    
    // MapView
    if ([segue.identifier isEqualToString:@"setCompanyByPin:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *view = sender;
            title = view.annotation.title;
        }
    }
    
    // TableView
    if ([segue.identifier isEqualToString:@"setCompanyByCell:"]) {
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            NSIndexPath *indexPath = sender;
            NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
            MIICompany *company = [_data category:category companyAtIndex:indexPath.row];
            title = company.companyName;
        }
    }
    
    UIViewController *dst = segue.destinationViewController;
    dst.title = title;
}

@end
