//
//  IconManager.m
//  IconManager
//
//  Created by Tobias Haag on 5/8/12.
//  Copyright (c) 2012 Yammer. All rights reserved.
//

#import "IconManager.h"
#import <QuickLook/QuickLook.h>
#import "sys/xattr.h"

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
    
    [self removeIconFromFile:file];
    
    NSImage *badge = [[NSImage alloc] initWithContentsOfFile:iconPath];
    
    if(badge==nil) return 2;        
    
    NSImage *fileIcon = [self imageWithPreviewOfFileAtPath:file ofSize:NSMakeSize(512.0, 512.0) asIcon:YES];
    
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

+ (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path ofSize:(NSSize)size asIcon:(BOOL)icon
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!path || !fileURL) {
        return nil;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:icon] 
                                                     forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault, 
                                            (CFURLRef)fileURL, 
                                            CGSizeMake(size.width, size.height),
                                            (CFDictionaryRef)dict);
    
    if (ref != NULL) {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep) {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];
            [bitmapImageRep release];
            
            if (newImage) {
                return [newImage autorelease];
            }
        }
        CFRelease(ref);
    } else {
        // If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        if (icon) {
            [icon setSize:size];
        }
        return icon;
    }
    
    return nil;
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

int refreshState(const char* filepath, const char* iconPath){
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    const char *attrName = [@"com.yammer.filestate" UTF8String];
        
    int bufferLength = getxattr(filepath,attrName,NULL,0,0,0);
    
    if(bufferLength <= 0) return 1;
    
    char *buffer = malloc(bufferLength);
    
    getxattr(filepath, attrName, buffer, bufferLength, 0, 0);
    
    NSString *retString = [[NSString alloc] initWithBytes:buffer length:bufferLength encoding:NSUTF8StringEncoding];
    
    free(buffer);
    
    if(retString == nil) return 2;
        
    NSString *icon;
    
    if([retString isEqualToString:@"SYNCING"]){
        icon = [[NSString stringWithUTF8String: iconPath] stringByAppendingString:@"/syncing.png"];
    }else if([retString isEqualToString:@"NOT_SYNCED"]){
        icon = [[NSString stringWithUTF8String: iconPath] stringByAppendingString:@"/notSynced.png"];
    }else if([retString isEqualToString:@"SYNCED"]){
        icon = [[NSString stringWithUTF8String: iconPath] stringByAppendingString:@"/synced.png"];
    }
    
    NSString *file = [NSString stringWithUTF8String:filepath];

    int result = [IconManager setBadgeForFile: file AndIconPath:icon];
    [pool drain];
    return result;
    
}