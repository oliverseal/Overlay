//
//  OverlayWindow.h
//  Overlay
//
//  Created by Oliver Wilkerson on 6/1/11.
//  Copyright 2011 Oliver Wilkerson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OverlayWindowDefaults.h"

@interface OverlayWindow : NSWindow {
	OverlayWindowDefaults *defaultSettings;
	NSSlider *alphaSlider;
	NSImage *image;
	CGFloat alphaSnapshot;
	BOOL alwaysOnTop;
	BOOL alphaSliderVisible;
	NSPoint initialLocation;
}
@property (assign) BOOL alwaysOnTop;
@property (assign) BOOL alphaSliderVisible;
@property (assign) OverlayWindowDefaults *defaultSettings;

+(OverlayWindow *)initWithDefaults:(OverlayWindowDefaults *)newDefaults;
+(OverlayWindow *)initWithDefaults:(OverlayWindowDefaults *)newDefaults quietly:(BOOL)silent;
-(void)setDefaultSettings:(OverlayWindowDefaults *)toDefaults;
-(void)setDefaultSettings:(OverlayWindowDefaults *)toDefaults quietly:(BOOL)silent;
-(void)toggleAlwaysOnTop;
-(void)toggleAlphaSlider;
-(void)setAlwaysOnTop:(BOOL)alwaysOnTopState withoutNotification:(BOOL)silent;
@end
