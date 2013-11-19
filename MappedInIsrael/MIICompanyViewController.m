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
    
    // GAITrackedViewController
    self.screenName = @"MIICompanyViewController";
    
    // Company
    NSDictionary *category = (NSDictionary *)self.company.companyCategory;
    self.navigationItem.title = [[MIIData getAllFormatedCategories] objectAtIndex:[[MIIData getAllCategories] indexOfObject:[category valueForKey:@"categoryName"]]];
    self.hiringLabel.text = [NSString stringWithFormat:@"%@ is currently hiring:", self.company.companyName];
    self.nameLabel.text = self.company.companyName;
    self.descriptionTextView.text = self.company.description;
    self.descriptionTextView.font = [UIFont fontWithName:@"Helvetica" size:17];
    self.descriptionTextView.textColor = [UIColor grayColor];
    [self.contactButton setTitle:self.company.contactEmail forState:UIControlStateNormal];
    [self.homePageButton setTitle:self.company.websiteURL forState:UIControlStateNormal];
    [self.addressButton setTitle:[NSString stringWithFormat:@"%@ %@, %@, Israel",
                                  self.company.addressStreet,
                                  self.company.addressHouse,
                                  self.company.addressCity] forState:UIControlStateNormal];
    
    [self.addressButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    // Map Annotation
    self.mapView.delegate = self;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.company.lat doubleValue];
    coordinate.longitude = [self.company.lon doubleValue];
    MIIPointAnnotation *point = [[MIIPointAnnotation alloc] init];
    point.coordinate = coordinate;
    point.title = self.company.companyName;
    NSDictionary *companyCategory = (NSDictionary *)self.company.companyCategory;
    point.subtitle = [companyCategory objectForKey:@"categoryName"];
    point.company = self.company;
    [self.mapView addAnnotation:point];
    MKCoordinateRegion region;
    region.center.latitude = coordinate.latitude;
    region.center.longitude = coordinate.longitude;
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
    [self.mapView setRegion:region animated:YES];
    
    // Table
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Move tableSuperView&tableView
    if (![self.company.jobs count]) {
        self.tableSuperView.frame = CGRectMake(self.tableSuperView.frame.origin.x,
                                               self.tableSuperView.frame.origin.y,
                                               self.tableSuperView.frame.size.width,
                                               0);
    } else {
        self.tableSuperView.frame = CGRectMake(self.tableSuperView.frame.origin.x,
                                               self.tableSuperView.frame.origin.y,
                                               self.tableSuperView.frame.size.width,
                                               self.tableView.frame.origin.y+
                                               self.tableView.rowHeight*[self.company.jobs count]);
        
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                          self.tableView.frame.origin.y,
                                          self.tableView.frame.size.width,
                                          self.tableView.rowHeight*[self.company.jobs count]);
    }
    
    // Resize descriptionTextView
    CGRect rect = [self.descriptionTextView.attributedText boundingRectWithSize:CGSizeMake(self.descriptionTextView.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    // Move nameSuperView
    self.nameSuperView.frame = CGRectMake(self.nameSuperView.frame.origin.x,
                                          self.mapView.frame.size.height+
                                          self.tableSuperView.frame.size.height,
                                          self.nameSuperView.frame.size.width,
                                          self.descriptionTextView.frame.origin.y+
                                          rect.size.height+30);
    
    self.descriptionTextView.frame = CGRectMake(self.descriptionTextView.frame.origin.x,
                                                self.descriptionTextView.frame.origin.y,
                                                self.descriptionTextView.frame.size.width,
                                                rect.size.height+30);
    
    // Move iconsSuperView
    self.iconsSuperView.frame = CGRectMake(self.iconsSuperView.frame.origin.x,
                                           self.mapView.frame.size.height+
                                           self.tableSuperView.frame.size.height+
                                           self.nameSuperView.frame.size.height,
                                           self.iconsSuperView.frame.size.width,
                                           self.iconsSuperView.frame.size.height);
    
    // Resize scrollView
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             self.mapView.frame.size.height+
                                             self.tableSuperView.frame.size.height+
                                             self.nameSuperView.frame.size.height+
                                             self.iconsSuperView.frame.size.height);
}

- (IBAction)openWebsite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.company.websiteURL]];
}

- (IBAction)openMail:(id)sender
{
    NSString *emailTitle = @"";
    NSString *messageBody = @"";
    NSArray *toRecipents = [NSArray arrayWithObject:self.company.contactEmail];
    
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

#pragma mark - Table view data source

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
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@", subtitle, @".png"]];
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
    
    MIIJob *job = [self.company.jobs objectAtIndex:indexPath.row];
    cell.textLabel.text = job.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showJob:" sender:[self.company.jobs objectAtIndex:indexPath.row]];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
