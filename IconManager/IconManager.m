//
//  IconManager.m
//  IconManager
//
//  Created by Tobias Haag on 5/8/12.
//  Copyright (c) 2012 Yammer. All rights reserved.
//

#import "IconManager.h"

@implementation IconManager{

}

+ (NSImage*) getCurrentIcon:(NSString *)file{
    if(![[NSFileManager defaultManager] fileExistsAtPath:file]) return nil;
    [[NSWorkspace sharedWorkspace] setIcon:nil forFile:file options:0];
    NSImage *iconImg = [[NSWorkspace sharedWorkspace] iconForFile:file];    
    return iconImg;
}

+ (int) setBadgeForFile:(NSString*) file AndIconPath:(NSString*)iconPath{
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:file] || 
       ![[NSFileManager defaultManager] fileExistsAtPath:iconPath]) return 1;
    
    NSImage *badge = [[NSImage alloc] initWithContentsOfFile:iconPath];
    
    if(badge==nil) return 2;        
        
    NSImage *fileIcon = [self getCurrentIcon:file];
    
    if(fileIcon == nil) return 3;
    
    NSSize newBadgeSize = NSMakeSize(fileIcon.size.width/2, fileIcon.size.height/2);
    
    [badge setSize:newBadgeSize];
    
    [fileIcon lockFocus];
    [badge 
     drawInRect:NSMakeRect(fileIcon.size.width - badge.size.width, 0, badge.size.width, badge.size.height) 
     fromRect:NSZeroRect 
     operation:NSCompositeSourceOver 
     fraction:1.0];
    [fileIcon unlockFocus];
    
    [[NSWorkspace sharedWorkspace] setIcon:fileIcon forFile:file options:0];
    
    return 0;
}

+ (int) setIconForFile:(NSString*) file AndIconPath:(NSString*)iconPath{
    if(![[NSFileManager defaultManager] fileExistsAtPath:file] ||
       ![[NSFileManager defaultManager] fileExistsAtPath:iconPath]) return 1;
    
    NSImage *newIcon = [[NSImage new] initWithContentsOfFile:iconPath];
    
    if(newIcon == nil) return 2;
    
    [[NSWorkspace sharedWorkspace] setIcon:newIcon forFile:file options:0];
        
    return 0;
}

+ (int)removeIconFromFile:(NSString*)file{
    if(![[NSFileManager defaultManager] fileExistsAtPath:file]) return 1;
    [[NSWorkspace sharedWorkspace] setIcon:nil forFile:file options:0];
    
    return 0;
}

@end

int setBadge(const char* filepath, const char* iconPath) {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = [IconManager setBadgeForFile:[NSString stringWithUTF8String:filepath] AndIconPath:[NSString stringWithUTF8String:iconPath]];
    
    [pool drain];
    return result;
}

int setIcon(const char* filepath, const char* iconPath) {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = [IconManager setIconForFile:[NSString stringWithUTF8String:filepath] AndIconPath:[NSString stringWithUTF8String:iconPath]];
    
    [pool drain];
    return result;
}

int removeIcon(const char* filepath) {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = [IconManager removeIconFromFile:[NSString stringWithUTF8String:filepath]];
    [pool drain];
    return result;
}
