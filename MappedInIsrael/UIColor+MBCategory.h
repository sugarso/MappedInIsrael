//
//  UIColor+MBCategory.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/15/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (MBCategory)

+ (UIColor *)colorWithHex:(UInt32)col alpah:(CGFloat)alpah;
+ (UIColor *)colorWithHexString:(NSString *)str alpah:(CGFloat)alpah;

@end
