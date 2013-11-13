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
        [_data setSearch:_searchBar.text setWhosHiring:NO];
    } else {
        [_data setSearch:_searchBar.text setWhosHiring:YES];
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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *title;
    
    // TableView
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSString *category = [[MIIData getAllFormatedCategories] objectAtIndex:indexPath.section];
            MIICompany *company = [_data category:category companyAtIndex:indexPath.row];
            title = company.companyName;
        }
    }
    
    UIViewController *dst = segue.destinationViewController;
    dst.title = title;
}

@end
