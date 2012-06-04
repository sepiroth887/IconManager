//
//  IconManager.h
//  IconManager
//
//  Created by Tobias Haag on 5/8/12.
//  Copyright (c) 2012 Yammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconManager : NSObject

+ (NSImage*)getCurrentIcon:(NSString*) file;
+ (int)setBadgeForFile:(NSString*) file AndIconPath:(NSString*)iconPath;
+ (int)setIconForFile:(NSString*) file AndIconPath:(NSString*)iconPath;
+ (int)removeIconFromFile:(NSString*)file;
+ (NSString*) getIconFromXattrAtPath:(const char*)filepath AndIconPath:(const char*)iconPath;
@end

int setBadge(const char* filepath, const char* iconPath);
int setIcon(const char* filepath, const char* iconPath);
int removeIcon(const char* filepath);
