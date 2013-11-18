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
    NSArray *_tableData;
    NSArray *_searchData;
    BOOL _waitingForCompany;
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
    
    // Search or cluster view
    if (self.clusterAnnotation) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d Organizations", [self.clusterAnnotation count]];
        [self.data setClusterAnnotation:self.clusterAnnotation];
    } else {
        self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
        
        // UIReturnKeyDone
        for (UIView *subView in [self.searchBar subviews]) {
            if ([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
                [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
            } else {
                for (UIView *subSubView in [subView subviews]) {
                    if ([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                        [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                    }
                }      
            }
        }
    }
    
    // updateFilter every UIControlEventValueChanged
    [self.whosHiring addTarget:self action:@selector(updateFilter:) forControlEvents:UIControlEventValueChanged];
    
    // Make sure pins on screen
    [self updateFilter:self];
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
}

- (void)updateFilter:(id)sender
{
    //NSLog(@"SegmentIndex: %d", self.whosHiring.selectedSegmentIndex);

    if (self.whosHiring.selectedSegmentIndex == 0) {
        if (self.clusterAnnotation) {
            _tableData = [self.data getClusterAnnotationWhosHiring:NO];
        } else {
            _tableData = [self.data getCompaniesWhosHiring:NO];
        }
    } else {
        if (self.clusterAnnotation) {
            _tableData = [self.data getClusterAnnotationWhosHiring:YES];
        } else {
            _tableData = [self.data getCompaniesWhosHiring:YES];
        }
    }
    _searchData = [_tableData copy];
    [self.tableView reloadData];
}

- (void)updateSearch:(NSString *)searchText
{
    NSMutableArray *companies = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        [companies insertObject:[[NSMutableArray alloc] init] atIndex:i];
        
        for (MIICompany *company in [_tableData objectAtIndex:i]) {
            if ((searchText == nil) ||
                ([searchText isEqualToString:@""]) ||
                ([company.companyName rangeOfString:searchText options:NSCaseInsensitiveSearch].length)) {
                [[companies objectAtIndex:i] addObject:company];
            }
        }
    }
    
    _searchData = [companies copy];
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate/UISearchDisplayDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    [self updateSearch:@""];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateSearch:searchText];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[MIIData getAllFormatedCategories] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ((NSArray *)[_searchData objectAtIndex:section]).count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)[_searchData objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MIICompany *company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = company.companySubCategory;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MIIViewController *mapView = [self.navigationController.viewControllers objectAtIndex:0];
    MIICompany *company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    mapView.company = company;
    mapView.data = self.data;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (!_waitingForCompany) {
        MIICompany *company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [self.data getCompany:company.id];
        _waitingForCompany = YES;
    }
}

#pragma mark - MIIDataDelegate

- (void)dataIsReady
{
    [self updateFilter:self];
    MIIViewController *mapView = [self.navigationController.viewControllers objectAtIndex:0];
    [mapView initMap:self];
}

- (void)companyIsReady:(MIICompany *)company
{
    if (_waitingForCompany) {
        [self performSegueWithIdentifier:@"showCompany:" sender:company];
        _waitingForCompany = NO;
    }
}

@end
