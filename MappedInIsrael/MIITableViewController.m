//
//  MIITableViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/10/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIITableViewController.h"
#import "MIIViewController.h"
#import "MIICompany.h"

@interface MIITableViewController () {
    UISearchBar *mySearchBar;
    NSArray *categories;
}
@end

@implementation MIITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Table View";
    
    self.navigationItem.hidesBackButton = YES;
    
    // searchBar
    [self addSearchBar:self];
    
    categories = @[@"Startups", @"Accelerators", @"Coworking", @"Investors", @"R&D Centers", @"Community", @"Services"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [categories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [categories objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tmp = @[@"startup", @"accelerator", @"coworking", @"investor", @"rdcenter", @"community", @"service"];
    NSString *category = (NSString *) [tmp objectAtIndex:section];
    NSInteger num = 0;
    MIIViewController *vc = [self.navigationController.viewControllers objectAtIndex:0];
    for (MIICompany *company in vc.companies) {
        if ([company.companyCategory isEqualToString:category]){
            num++;
        }
    }

    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    MIIViewController *vc = [self.navigationController.viewControllers objectAtIndex:0];
    
    NSArray *tmp = @[@"startup", @"accelerator", @"coworking", @"investor", @"rdcenter", @"community", @"service"];
    NSString *category = (NSString *) [tmp objectAtIndex:indexPath.section];
    NSMutableArray *tmparr = [[NSMutableArray alloc] init];
    for (MIICompany *company in vc.companies) {
        if ([company.companyCategory isEqualToString:category]){
            [tmparr addObject:company];
        }
    }
    
    cell.textLabel.text = ((MIICompany *) [tmparr objectAtIndex:indexPath.row]).companyName;
    cell.detailTextLabel.text = ((MIICompany *) [tmparr objectAtIndex:indexPath.row]).companySubCategory;
    
    return cell;
}

- (void)buttonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showMap:" sender:self.view];
}

- (void)addSearchBar:(id)sender {
    mySearchBar = [UISearchBar new];
    [mySearchBar sizeToFit];
    mySearchBar.delegate = self;
    mySearchBar.searchBarStyle = UISearchBarStyleMinimal;
    mySearchBar.placeholder = @"Search jobs, companies...";
    
    UIImage *image = [UIImage imageNamed:@"map-25.png"];
    UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [imageButton setImage:image forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:imageButton];
    
    self.navigationItem.rightBarButtonItem = buttonItem;
    self.navigationItem.titleView = mySearchBar;
}

@end
