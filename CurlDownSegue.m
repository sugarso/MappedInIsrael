//
//  CurlDownSegue.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/16/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "CurlDownSegue.h"

@implementation CurlDownSegue

- (void)perform
{
    UIViewController *src = (UIViewController *)self.sourceViewController;
    UIViewController *dst = (UIViewController *)self.destinationViewController;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    [src.navigationController pushViewController:dst animated:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:src.navigationController.view cache:NO];
    [UIView commitAnimations];
}

@end
