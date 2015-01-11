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

+ (NSString *)fileName
{
    return @"companies.data";
}

+ (NSString *)getDstPath
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [docPath stringByAppendingPathComponent:[MIICommunicator fileName]];
}

+ (NSData *)getStaticData // TBD: Google Analytics
{
    if (!([[NSFileManager defaultManager] fileExistsAtPath:[MIICommunicator getDstPath]])) {
        [[NSFileManager defaultManager] copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[MIICommunicator fileName]]
                                                toPath:[MIICommunicator getDstPath]
                                                 error:nil];
    }
    
    Hello(@"getStaticData");
    return [[NSFileManager defaultManager] contentsAtPath:[MIICommunicator getDstPath]];
}

+ (void)setStaticData:(NSData *)data
{
    Hello(@"setStaticData");
    [data writeToFile:[MIICommunicator getDstPath] atomically:YES];
}

- (void)getAllCompanies
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.mappedinisrael.com/api/site/companies?page=%d&pageSize=%d", PAGE, PAGESIZE];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    Hello(@"getAllCompanies URL: %@", urlAsString);
    
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
    Hello(@"getCompany URL: %@", urlAsString);
    
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
