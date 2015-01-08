//
//  NSString+HTML.h
//  MappedInIsrael
//
//  Created by Genady Okrain on 11/17/13.
//  Copyright (c) 2013 Genady Okrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringByDecodingXMLEntities;

@end
