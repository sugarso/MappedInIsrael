//
//  MIICommunicator.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIICommunicator.h"
#import "MIICommunicatorDelegate.h"

#define PAGESIZE 10000
#define PAGE 0

@implementation MIICommunicator

- (void)getAllCompanies
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.mappedinisrael.com/api/site/companies?page=%d&pageSize=%d", PAGE, PAGESIZE];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate fetchingCompaniesFailedWithError:error];
        } else {
            [self.delegate receivedCompaniesJSON:data];
        }
    }];
}

@end
