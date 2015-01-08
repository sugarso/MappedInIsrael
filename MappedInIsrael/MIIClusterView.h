//
//  MIIClusterView.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/12/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CLUSTER_X_OFF 15
#define CLUSTER_Y_OFF 2

@interface MIIClusterView : UIView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color NS_DESIGNATED_INITIALIZER;
+ (UIImage *)imageWithView:(UIView *)view;

@end
