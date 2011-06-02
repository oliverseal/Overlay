//
//  OverlayAppDelegate.h
//  Overlay
//
//  Created by Oliver Wilkerson on 6/1/11.
//  Copyright 2011 Oliver Wilkerson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OverlayWindow.h"

@interface OverlayAppDelegate : NSObject <NSApplicationDelegate> {
    NSMutableArray *defaultWindowPreferences;
	NSMutableArray *windows;
	NSOpenPanel *openDialog;
	BOOL applicationIsActive;
	BOOL willTerminate;
}
@property (assign) NSMutableArray *windows;

- (IBAction)openNewOverlayWindow:(id)sender;
- (OverlayWindow *)createNewOverlayWindowWithLocation:(NSString *)fileName andAlpha:(CGFloat)defaultAlpha andAlwaysOnTop:(BOOL)alwaysOnTop;
- (OverlayWindow *)createNewOverlayWindowWithDefaults:(OverlayWindowDefaults *)defaults withoutNotification:(BOOL)silent;
- (void)saveSettings;
@end
