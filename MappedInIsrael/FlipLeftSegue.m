//
//  FlipLeftSegue.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/10/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "FlipLeftSegue.h"

@implementation FlipLeftSegue

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    [UIView transitionWithView:src.navigationController.view duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];;
                    }
                    completion:NULL];
}

@end
