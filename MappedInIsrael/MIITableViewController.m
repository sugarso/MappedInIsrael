//
//  MIITableViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/12/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIITableViewController.h"

@interface MIITableViewController () {
    UISearchBar *_searchBar;
}
@end

@implementation MIITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.screenName = @"MIITableViewController";
    
    // NavigationBar
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(showMap:)];
    self.navigationItem.rightBarButtonItem = done;
    self.navigationItem.hidesBackButton = YES;
    
    // SearchBar
    _searchBar = [UISearchBar new];
    [_searchBar sizeToFit];
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.placeholder = @"Search jobs, companies...";
    self.navigationItem.titleView = _searchBar;
    
    // updateFilter every UIControlEventValueChanged
    [self.whosHiring addTarget:self action:@selector(updateFilter:) forControlEvents:UIControlEventValueChanged];
}

- (void)updateFilter:(id)sender
{
    NSLog(@"Search: %@, SegmentIndex: %d", _searchBar.text, self.whosHiring.selectedSegmentIndex);
    if (self.whosHiring.selectedSegmentIndex == 0) {
        [self.data setSearch:_searchBar.text setWhosHiring:NO];
    } else {
        [self.data setSearch:_searchBar.text setWhosHiring:YES];
    }
    [self.tableView reloadData];
}

- (void)showMap:(id)sender
{
    [self performSegueWithIdentifier:@"showMap:" sender:sender];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[MIIData getAllFormatedCategories] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.data getCompaniesInCategory:[[MIIData getAllFormatedCategories] objectAtIndex:section]].count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *category = (NSString *)[[MIIData getAllFormatedCategories] objectAtIndex:section];
    return [self.data getCompaniesInCategory:category].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
    MIICompany *company = [self.data category:category companyAtIndex:indexPath.row];
    
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
    [self performSegueWithIdentifier:@"showCompany:" sender:indexPath];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
            MIICompany *company = [self.data category:category companyAtIndex:indexPath.row];
            MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
            controller.company = company;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showMap:"]) {
        if ([sender isKindOfClass:[NSIndexPath class]]) { // With Zoom
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
            MIICompany *company = [self.data category:category companyAtIndex:indexPath.row];
            MIIViewController *controller = (MIIViewController *)segue.destinationViewController;
            controller.company = company;
        }
    }
}

@end
