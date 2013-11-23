//
//  UITextView+FitText.m
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/23/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import "UITextView+FitText.h"

@implementation UITextView (FitText)

- (CGFloat)fitTextHeight
{
    CGFloat leftRightPadding = self.textContainerInset.left + self.textContainerInset.right + 2*self.textContainer.lineFragmentPadding;
    CGFloat topBottomPadding = self.textContainerInset.top + self.textContainerInset.bottom;
    CGSize size = CGSizeMake(self.bounds.size.width - leftRightPadding, CGFLOAT_MAX);
    CGRect rect = [self.attributedText boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
    
    return ceilf(rect.size.height)+topBottomPadding;
}
@end
