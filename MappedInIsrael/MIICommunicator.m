//
//  MIICommunicator.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 10/31/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIICommunicator.h"
#import "MIICommunicatorDelegate.h"
#import "ASIHTTPRequest.h"

#define PAGESIZE 10000
#define PAGE 0

@implementation MIICommunicator

+ (NSData *)getStaticData
{
    NSData *data;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *srcPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"companies.data"];
    NSString *dstPath = [docPath stringByAppendingPathComponent:@"companies.data"];
    if (!([[NSFileManager defaultManager] fileExistsAtPath:dstPath])) {
        [[NSFileManager defaultManager] copyItemAtPath:srcPath
                                                toPath:dstPath
                                                 error:nil];
    }
    if (([[NSFileManager defaultManager] fileExistsAtPath:dstPath])) {
        NSLog(@"getStaticData");
        data = [[NSFileManager defaultManager] contentsAtPath:dstPath];
    }
    
    return data;
}

- (void)getAllCompanies
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.mappedinisrael.com/api/site/companies?page=%d&pageSize=%d", PAGE, PAGESIZE];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"getAllCompanies URL: %@", urlAsString);
    
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.delegate receivedCompaniesJSON:[request responseData]];
    }];
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.delegate receivedCompaniesJSON:[MIICommunicator getStaticData]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [request startAsynchronous];
}

- (void)getCompany:(NSString *)id
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.mappedinisrael.com/api/site/organization/%@", id];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    NSLog(@"getCompany URL: %@", urlAsString);
    
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.delegate receivedCompanyJSON:[request responseData]];
    }];
    [request setFailedBlock:^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.delegate fetchingCompanyFailedWithError:[request error]];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [request startAsynchronous];
}

@end
