//
//  MIITableViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/12/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIITableViewController.h"
#import "UIColor+MBCategory.h"
#import "MIICompanyViewController.h"
#import "MIICompany.h"
#import "MIIViewController.h"

@interface MIITableViewController ()
{
    UISearchBar *_searchBar;
    BOOL _whosHiringBool;
}
@end

@implementation MIITableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make sure to be the delegate every viewWillAppear
    self.data.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GAITrackedViewController
    self.screenName = @"MIITableViewController";
    
    // NavigationBar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    // SearchBar
    _searchBar = [UISearchBar new];
    [_searchBar sizeToFit];
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.placeholder = @"Search Organizations";
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor colorWithHexString:@"#61a9ff" alpah:1.0]];
    
    // Search or cluster view
    if (self.clusterAnnotation) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d companies", [self.clusterAnnotation count]];
        [self.data setClusterAnnotation:self.clusterAnnotation];
    } else {
        self.navigationItem.titleView = _searchBar;
    }
    
    // updateFilter every UIControlEventValueChanged
    _whosHiringBool = NO;
    [self.whosHiring addTarget:self action:@selector(updateFilter:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MIICompany class]]) {
            MIICompany *company = (MIICompany *)sender;
            MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
            controller.company = company;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showMap:"]) {
        MIIViewController *controller = (MIIViewController *)segue.destinationViewController;
        if ([sender isKindOfClass:[NSIndexPath class]]) { // With Zoom
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
            MIICompany *company;
            if (self.clusterAnnotation) {
                company = [[self.data getClusterAnnotationInCategory:category whosHiring:_whosHiringBool] objectAtIndex:indexPath.row];
            } else {
                company = [[self.data getCompaniesInCategory:category] objectAtIndex:indexPath.row];
            }
            controller.company = company;
        }
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)updateFilter:(id)sender
{
    NSLog(@"Search: %@, SegmentIndex: %d", _searchBar.text, self.whosHiring.selectedSegmentIndex);

    if (self.whosHiring.selectedSegmentIndex == 0) {
        if (!self.clusterAnnotation) {
            [self.data setSearch:_searchBar.text setWhosHiring:NO];
        }
        _whosHiringBool = NO;
    } else {
        if (!self.clusterAnnotation) {
            [self.data setSearch:_searchBar.text setWhosHiring:YES];
        }
        _whosHiringBool = YES;
    }
    
    [self.tableView reloadData];
}

- (void)showMap:(id)sender
{
    [self performSegueWithIdentifier:@"showMap:" sender:sender];
}

#pragma mark - UISearchBarDelegate/UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateFilter:searchBar];
}
 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[MIIData getAllFormatedCategories] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.clusterAnnotation) {
        return [self.data getClusterAnnotationInCategory:[[MIIData getAllFormatedCategories] objectAtIndex:section] whosHiring:_whosHiringBool].count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
    } else {
        return [self.data getCompaniesInCategory:[[MIIData getAllFormatedCategories] objectAtIndex:section]].count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *category = (NSString *)[[MIIData getAllFormatedCategories] objectAtIndex:section];
    
    if (self.clusterAnnotation) {
        return [self.data getClusterAnnotationInCategory:category whosHiring:_whosHiringBool].count;
    } else {
        return [self.data getCompaniesInCategory:category].count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
    MIICompany *company;
    if (self.clusterAnnotation) {
        company = [[self.data getClusterAnnotationInCategory:category whosHiring:_whosHiringBool] objectAtIndex:indexPath.row];
    } else {
        company = [[self.data getCompaniesInCategory:category] objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = company.companySubCategory;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showMap:" sender:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
    MIICompany *company;
    if (self.clusterAnnotation) {
        company = [[self.data getClusterAnnotationInCategory:category whosHiring:_whosHiringBool] objectAtIndex:indexPath.row];
    } else {
        company = [[self.data getCompaniesInCategory:category] objectAtIndex:indexPath.row];
    }
    
    [self.data getCompany:company.id];
}

#pragma mark - MIIDataDelegate

- (void)dataIsReady
{
    [self.tableView reloadData];
}

- (void)companyIsReady:(MIICompany *)company
{
    [self performSegueWithIdentifier:@"showCompany:" sender:company];
}

@end
