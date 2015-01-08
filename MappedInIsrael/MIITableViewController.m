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
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
    @property (strong, nonatomic) NSArray *tableData;
    @property (strong, nonatomic) NSArray *searchData;
    @property (nonatomic) BOOL waitingForCompany;
@end

@implementation MIITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.screenName = @"MIITableViewController";
    
    // Notifications from main view controller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataIsReady:) name:@"dataIsReady" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(companyIsReady:) name:@"companyIsReady" object:nil];
    
    // Search or cluster view
    if (self.clusterAnnotation) {
        [self.data setClusterAnnotation:self.clusterAnnotation];
    }
    
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
    
    // updateFilter every UIControlEventValueChanged
    [self.whosHiring addTarget:self action:@selector(updateFilter:) forControlEvents:UIControlEventValueChanged];
    
    // Make sure pins on screen
    [self updateFilter:self];
}

- (void)updateFilter:(id)sender
{
    if (self.whosHiring.selectedSegmentIndex == 0) {
        if (self.clusterAnnotation) {
            self.tableData = [self.data getClusterAnnotationWhosHiring:NO];
        } else {
            self.tableData = [self.data getCompaniesWhosHiring:NO];
        }
    } else {
        if (self.clusterAnnotation) {
            self.tableData = [self.data getClusterAnnotationWhosHiring:YES];
        } else {
            self.tableData = [self.data getCompaniesWhosHiring:YES];
        }
    }
    
    int count = 0;
    for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
        count += [self.tableData[i] count];
    }
    self.searchBar.placeholder = [NSString stringWithFormat:@"Search %d Organizations", count];
    
    self.searchData = [self.tableData copy];
    [self.tableView reloadData];
}

- (void)updateSearch:(NSString *)searchText
{
    if ((searchText == nil) || ([searchText isEqualToString:@""])) {
        self.searchData = [self.tableData copy];
    } else {
        NSMutableArray *companies = [[NSMutableArray alloc] init];
        for (int i = 0; i < [MIIData getAllFormatedCategories].count; i++) {
            [companies insertObject:[[NSMutableArray alloc] init] atIndex:i];
            for (MIICompany *company in (self.tableData)[i]) {
                if ([company.companyName rangeOfString:searchText options:NSCaseInsensitiveSearch].length) {
                    [companies[i] addObject:company];
                }
            }
        }
        self.searchData = [companies copy];
    }
}

- (void)companyIsReady:(NSNotification *)note // TBD: Google Analytics, timeout?
{
    MIICompany *company = [[note userInfo] valueForKey:@"company"];
    [self performSegueWithIdentifier:@"showCompany:" sender:company];
}

- (void)dataIsReady:(NSNotification *)note
{
    MIIData *data = [[note userInfo] valueForKey:@"data"];
    self.data = data;
    [self updateFilter:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCompany:"]) {
        if ([sender isKindOfClass:[MIICompany class]]) {
            MIICompany *company = (MIICompany *)sender;
            MIICompanyViewController *controller = (MIICompanyViewController *)segue.destinationViewController;
            controller.company = company;
            self.waitingForCompany = NO;
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearch:searchString];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[MIIData getAllFormatedCategories] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return ((NSArray *)(self.searchData)[section]).count ? [MIIData getAllFormatedCategories][section] : nil;
    } else {
        return ((NSArray *)(self.tableData)[section]).count ? [MIIData getAllFormatedCategories][section] : nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.tableView) {
        return ((NSArray *)(self.searchData)[section]).count;
    } else {
        return ((NSArray *)(self.tableData)[section]).count;
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
    if (tableView != self.tableView) {
        company = (self.searchData)[indexPath.section][indexPath.row];
    } else {
        company = (self.tableData)[indexPath.section][indexPath.row];
    }
    
    cell.textLabel.text = company.companyName;
    cell.detailTextLabel.text = company.companySubCategory;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MIIViewController *mapView = (self.navigationController.viewControllers)[0];
    MIICompany *company;
    if (tableView != self.tableView) {
        company = (self.searchData)[indexPath.section][indexPath.row];
    } else {
        company = (self.tableData)[indexPath.section][indexPath.row];
    }
    mapView.company = company;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MIICompany *company;
    if (tableView != self.tableView) {
        company = (self.searchData)[indexPath.section][indexPath.row];
    } else {
        company = (self.tableData)[indexPath.section][indexPath.row];
    }
    
    if (!self.waitingForCompany) {
        [self.data getCompany:company.id];
        self.waitingForCompany = YES;
    }
}

@end
