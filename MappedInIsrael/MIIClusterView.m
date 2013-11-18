//
//  MIIClusterView.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/12/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "MIIClusterView.h"

@interface MIIClusterView () {
    UIColor *_color;
}
@end

@implementation MIIClusterView

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        _color = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _color.CGColor);
    //CGContextSetShadowWithColor(context, CGSizeMake(-1,1), 1, [UIColor grayColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 1, self.frame.size.width-15, self.frame.size.height-1));
}

+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
