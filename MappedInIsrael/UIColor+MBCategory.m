//
//  UIColor+MBCategory.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/15/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "UIColor+MBCategory.h"

@implementation UIColor(MBCategory)

// takes @"#123456"
+ (UIColor *)colorWithHexString:(NSString *)str  alpah:(CGFloat)alpah
{
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x alpah:alpah];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col  alpah:(CGFloat)alpah
{
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:alpah];
}

@end
