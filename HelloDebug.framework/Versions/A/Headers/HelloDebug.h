//
//  HelloDebug.h
//
//  Copyright (c) 2015 Hello Debug Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>


#if DEBUG
 #define HD_DEVMACHINE YES
#else
 #define HD_DEVMACHINE NO
#endif

#define Hello(format, ...)      HelloDebugLog(HD_DEVMACHINE, __FILE__, __LINE__, __PRETTY_FUNCTION__, format, ##__VA_ARGS__);
#define HelloBug(format, ...)   HelloDebugBug(HD_DEVMACHINE, __FILE__, __LINE__, __PRETTY_FUNCTION__, format, ##__VA_ARGS__);

FOUNDATION_EXPORT void HelloDebugLog(BOOL dev, const char *file, int lineNumber, const char *functionName, NSString *format, ...) NS_FORMAT_FUNCTION(5,6);
FOUNDATION_EXPORT void HelloDebugBug(BOOL dev, const char *file, int lineNumber, const char *functionName, NSString *format, ...) NS_FORMAT_FUNCTION(5,6);

@interface HelloDebug : NSObject

// Set the current username
+ (void)setUsername:(NSString *)username;

// Return the current username
+ (NSString *)username;

@end