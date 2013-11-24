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
   // BOOL _waitingForCompany;
}
@end

@implementation MIITableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Make sure to be the delegate every viewWillAppear
    //self.data.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    // GAITrackedViewController
    self.screenName = @"MIITableViewController";
    
    // Search or cluster view
    if (self.clusterAnnotation) {
        [self.data setClusterAnnotation:self.clusterAnnotation];
    }
    
    // UIReturnKeyDone
    for (UIView *subView in [self.searchDisplayController.searchBar subviews]) {
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
    
    // updateFilter every UIControlEventValueChanged
    [self.whosHiring addTarget:self action:@selector(updateFilter:) forControlEvents:UIControlEventValueChanged];
    
    // Make sure pins on screen
    [self updateFilter:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataIsReady:) name:@"dataIsReady" object:nil];
}

- (void)dataIsReady:(NSNotification *)note
{
    MIIData *data = [[note userInfo] valueForKey:@"data"];
    self.data = data;
        [self updateFilter:self];
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
    int count = 0;
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        count += [_tableData[i] count];
    }
    self.searchDisplayController.searchBar.placeholder = [NSString stringWithFormat:@"Search %d Organizations", count];
    _searchData = [_tableData copy];
    [self.tableView reloadData];
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

- (void)updateSearch:(NSString *)searchText
{
    if ((searchText == nil) || ([searchText isEqualToString:@""])) {
        _searchData = [_tableData copy];
    } else {
        NSMutableArray *companies = [[NSMutableArray alloc] init];
        for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
            [companies insertObject:[[NSMutableArray alloc] init] atIndex:i];
            for (MIICompany *company in [_tableData objectAtIndex:i]) {
                if ([company.companyName rangeOfString:searchText options:NSCaseInsensitiveSearch].length) {
                    [[companies objectAtIndex:i] addObject:company];
                }
            }
        }
        _searchData = [companies copy];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearch:searchString];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[MIIData getAllFormatedCategories] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return ((NSArray *)[_searchData objectAtIndex:section]).count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
    } else {
        return ((NSArray *)[_tableData objectAtIndex:section]).count ? [[MIIData getAllFormatedCategories] objectAtIndex:section] : nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return ((NSArray *)[_searchData objectAtIndex:section]).count;
    } else {
        return ((NSArray *)[_tableData objectAtIndex:section]).count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MIICompany *company;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        company = [[_tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = company.companySubCategory;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MIIViewController *mapView = [self.navigationController.viewControllers objectAtIndex:0];
    MIICompany *company;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        company = [[_tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    mapView.company = company;
    mapView.data = self.data;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MIICompany *company;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        company = [[_searchData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        company = [[_tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
   // if (!_waitingForCompany) {
        [self.data getCompany:company.id];
        [self performSegueWithIdentifier:@"showCompany:" sender:self];
    //    _waitingForCompany = YES;
   // }
}

#pragma mark - MIIDataDelegate

- (void)dataIsReady
{
    [self updateFilter:self];
    MIIViewController *mapView = [self.navigationController.viewControllers objectAtIndex:0];
    [mapView initMap:self];
}

/*- (void)companyIsReady:(MIICompany *)company
{
    if (_waitingForCompany) {
        //[self performSegueWithIdentifier:@"showCompany:" sender:company];
        _waitingForCompany = NO;
    }
}

- (void)serverError // TBD: Google Analytics
{
    if (_waitingForCompany) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"Organization details are currently unavailable."
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK",nil];
        [alert show];
        _waitingForCompany = NO;
    }
}*/

@end
