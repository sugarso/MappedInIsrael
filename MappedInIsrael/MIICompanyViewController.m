//
//  MIICompanyViewController.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/1/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIICompanyViewController.h"
#import "UIColor+MBCategory.h"
#import "MIIPointAnnotation.h"
#import "MIIJobViewController.h"
#import "MIIData.h"
#import "MIIJob.h"
#import "UITextView+FitText.h"

@implementation MIICompanyViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSIndexPath * selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.screenName = @"MIICompanyViewController";

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    NSDictionary *category = (NSDictionary *)self.company.companyCategory;
    self.navigationItem.title = [MIIData getAllFormatedCategories][[[MIIData getAllCategories] indexOfObject:[category valueForKey:@"categoryName"]]];
    self.hiringLabel.text = [NSString stringWithFormat:@"%@ is currently hiring:", self.company.companyName];
    self.nameLabel.text = self.company.companyName;
    
    self.descriptionTextView.text = self.company.desc;
    self.textViewHeightConstraint.constant = [self.descriptionTextView fitTextHeight];
    
    self.tableViewHeightConstraint.constant = self.tableView.rowHeight*[self.company.jobs count];
    [self.contactButton setTitle:self.company.contactEmail forState:UIControlStateNormal];
    [self.homePageButton setTitle:self.company.websiteURL forState:UIControlStateNormal];
    [self.addressButton setTitle:[NSString stringWithFormat:@"%@ %@, %@, Israel",
                                  self.company.addressStreet,
                                  self.company.addressHouse,
                                  self.company.addressCity] forState:UIControlStateNormal];
    [self.addressButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    if (![self.company.jobs count]) {
        self.labelHeightConstraint.constant = 0;
    }
    
    self.mapView.delegate = self;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.company.lat doubleValue];
    coordinate.longitude = [self.company.lon doubleValue];
    MIIPointAnnotation *point = [[MIIPointAnnotation alloc] init];
    point.coordinate = coordinate;
    point.title = self.company.companyName;
    NSDictionary *companyCategory = (NSDictionary *)self.company.companyCategory;
    point.subtitle = companyCategory[@"categoryName"];
    point.company = self.company;
    [self.mapView addAnnotation:point];
    MKCoordinateRegion region;
    region.center.latitude = coordinate.latitude;
    region.center.longitude = coordinate.longitude;
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
    [self.mapView setRegion:region animated:NO];
    [self.tableView reloadData];
}

- (IBAction)openWebsite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.company.websiteURL]];
}

- (IBAction)openMail:(id)sender
{
    NSString *emailTitle = @"";
    NSString *messageBody = @"";
    NSArray *toRecipents = @[self.company.contactEmail];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    [self presentViewController:mc animated:YES completion:NULL];
}

- (IBAction)openMap:(id)sender
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.company.lat doubleValue];
    coordinate.longitude = [self.company.lon doubleValue];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = self.company.companyName;
    [item openInMapsWithLaunchOptions:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showJob:"]) {
        if ([sender isKindOfClass:[MIIJob class]]) {
            MIIJobViewController *controller = (MIIJobViewController *)segue.destinationViewController;
            controller.job = (MIIJob *)sender;
            controller.hiringPageURL = self.company.hiringPageURL;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *v = nil;
    
    if ([annotation isKindOfClass:[MIIPointAnnotation class]]) {
        v = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Company"];
            
        if (!v) {
            v = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Company"];
        }
        
        v.canShowCallout = NO;
        NSString *subtitle = ((MIIPointAnnotation *)annotation).subtitle;
        UIImage *i = [UIImage imageNamed:subtitle];
        v.image = i;
    }

    return v;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.company.jobs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    MIIJob *job = (self.company.jobs)[indexPath.row];
    cell.textLabel.text = job.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showJob:" sender:(self.company.jobs)[indexPath.row]];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            Hello(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            Hello(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            Hello(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            Hello(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
