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
}
@end

@implementation MIITableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make sure to be the delegate every viewWillAppear
    self.data.delegate = self;
    
    // Make sure pins on screen
    [self updateFilter:self];
    
    // NavigationBar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // GAITrackedViewController
    self.screenName = @"MIITableViewController";
    
    // Search or cluster view
    if (self.clusterAnnotation) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d companies", [self.clusterAnnotation count]];
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
            MIICompany *company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            controller.company = company;
            controller.data = self.data;
        }
    }
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
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

- (void)showMap:(id)sender
{
    [self performSegueWithIdentifier:@"showMap:" sender:sender];
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
    [self performSegueWithIdentifier:@"showMap:" sender:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MIICompany *company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.data getCompany:company.id];
}

#pragma mark - MIIDataDelegate

- (void)dataIsReady
{
    [self updateFilter:self];
}

- (void)companyIsReady:(MIICompany *)company
{
    [self performSegueWithIdentifier:@"showCompany:" sender:company];
}

@end
