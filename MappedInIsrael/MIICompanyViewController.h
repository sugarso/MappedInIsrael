//
//  MIICompanyViewController.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/1/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>
#import "GAITrackedViewController.h"
#import "MIICompany.h"

@interface MIICompanyViewController : GAITrackedViewController <MKMapViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) MIICompany *company;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIView *tableSuperView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *hiringLabel;

@property (weak, nonatomic) IBOutlet UIView *nameSuperView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UIView *iconsSuperView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *homePageButton;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;

@end
