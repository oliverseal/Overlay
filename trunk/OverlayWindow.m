//
//  OverlayWindow.m
//  Overlay
//
//  Created by Oliver Wilkerson on 6/1/11.
//  Copyright 2011 Oliver Wilkerson. All rights reserved.
//

#import "OverlayWindow.h"
#import <AppKit/AppKit.h>
#import "OverlayWindowContextMenu.h"


@implementation OverlayWindow

@synthesize alwaysOnTop;
@synthesize defaultSettings;
@synthesize alphaSliderVisible;

- (void)dealloc {
	[image release];
	[defaultSettings release];
	[alphaSlider release];
	[super dealloc];
}

- (OverlayWindow *)init {
	OverlayWindow *window = [super init];
	[window setStyleMask:NSBorderlessWindowMask];
	[window setHasShadow:NO];
	
	OverlayWindowContextMenu *menu = [[OverlayWindowContextMenu alloc] initWithWindow: window];
	[window.contentView setMenu:menu];
	[[NSNotificationCenter defaultCenter] addObserver:menu selector:@selector(overlayWindowAlwaysOnTopChanged:) name:OVERLAY_NOTIFICATION_KEY_ALWAYSONTOPCHANGED object:self];
	[[NSNotificationCenter defaultCenter] addObserver:menu selector:@selector(overlayWindowAlphaSliderVisibleChanged:) name:OVERLAY_NOTIFICATION_KEY_ALPHASLIDERVISIBLECHANGED object:self];
	
	[window setReleasedWhenClosed:YES];
	return window;
}

+ (OverlayWindow*)initWithDefaults:(OverlayWindowDefaults *)newDefaults {
	OverlayWindow *window = [[OverlayWindow alloc] init];
	[window setDefaultSettings:newDefaults quietly:NO];
	return window;
}

+ (OverlayWindow*)initWithDefaults:(OverlayWindowDefaults *)newDefaults quietly:(BOOL)silent {
	OverlayWindow *window = [[OverlayWindow alloc] init];
	[window setDefaultSettings:newDefaults quietly:silent];
	return window;
}

- (void)setDefaultSettings:(OverlayWindowDefaults *)toDefaults quietly:(BOOL)silent {
	if (defaultSettings != nil && toDefaults != nil && defaultSettings != toDefaults)
		[defaultSettings release];
	else if (toDefaults == nil)
		return;
	
	defaultSettings = toDefaults;
	[defaultSettings retain];
	[self setAlphaValue: defaultSettings.defaultAlpha];
	[self setFrameOrigin: NSMakePoint(defaultSettings->originX, defaultSettings->originY)];
	[self setAlwaysOnTop: defaultSettings.alwaysOnTop withoutNotification:silent];
	
	if (image != nil)
		[image release];
	image = [[NSImage alloc] initWithContentsOfFile:defaultSettings.imageLocation];
	
	//now that we loaded the image we need to set the bounds;
	NSSize imageSize = [image size];
	[self setContentSize:imageSize];
	[self setBackgroundColor:[NSColor colorWithPatternImage:image]];
	
	NSRect rect = NSMakeRect(imageSize.width - 20, 0, 20, imageSize.height);
	[self.contentView addTrackingRect:rect owner:self userData:nil assumeInside:YES];
	if (alphaSlider == nil) {
		alphaSlider = [[[[NSSlider alloc] init] retain] initWithFrame:rect];
		[alphaSlider setMaxValue:1];
		[alphaSlider setMinValue:0.1];
		[alphaSlider setTarget:self];
		[alphaSlider setAction:@selector(alphaSliderValueDidChange:)];
		[alphaSlider setContinuous:YES];
	}
	double alphaValue = (double)[self alphaValue];
	[alphaSlider setDoubleValue:alphaValue];
	[self.contentView addSubview:alphaSlider];
	[self setAlphaSliderVisible:NO];
}

-(void)updateDefaultSettings {
	//if (defaultSettings == nil)
	//	defaultSettings = [[[OverlayWindowDefaults alloc] init] retain];
	[defaultSettings setAlwaysOnTop: self.alwaysOnTop];
	[defaultSettings setDefaultAlpha: [self alphaValue]];
	[defaultSettings setOrigin:[self frame].origin];
	[[NSNotificationCenter defaultCenter] postNotificationName:OVERLAY_NOTIFICATION_KEY_DEFAULTSCHANGED object:self];
}

-(void)toggleAlphaSlider {
	[self setAlphaSliderVisible:!alphaSliderVisible];
}

-(void)setAlphaSliderVisible:(BOOL)alphaSliderVisibleState {
	alphaSliderVisible = alphaSliderVisibleState;
	[alphaSlider setHidden:!alphaSliderVisible];
	[[NSNotificationCenter defaultCenter] postNotificationName:OVERLAY_NOTIFICATION_KEY_ALPHASLIDERVISIBLECHANGED object:self];
}

-(void)toggleAlwaysOnTop {
	[self setAlwaysOnTop:!alwaysOnTop];
}

-(void)setAlwaysOnTop:(BOOL)alwaysOnTopState {
	[self setAlwaysOnTop:alwaysOnTopState withoutNotification:NO];
}

-(void)setAlwaysOnTop:(BOOL)alwaysOnTopState withoutNotification:(BOOL)silent {
	alwaysOnTop = alwaysOnTopState;
	if (alwaysOnTop == YES) {
		[self setLevel:NSFloatingWindowLevel];
	}
	else {
		[self setLevel:NSNormalWindowLevel];
	}
	if (!silent) {
		[self updateDefaultSettings];
		[[NSNotificationCenter defaultCenter] postNotificationName:OVERLAY_NOTIFICATION_KEY_ALWAYSONTOPCHANGED object:self];
	}
}

-(void)setAlphaValue:(CGFloat)windowAlpha {
	[super setAlphaValue:windowAlpha];
	
}

-(void)mouseDown:(NSEvent *)e {
    NSRect windowFrame = [self frame];
	
    initialLocation = [NSEvent mouseLocation];
	
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
}

- (void)mouseDragged:(NSEvent *)e {
    NSPoint currentLocation;
    NSPoint newOrigin;
	
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    NSRect windowFrame = [self frame];
	
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
	
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
        newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
	
    //go ahead and move the window to the new location
    [self setFrameOrigin:newOrigin];
}

-(void)mouseUp:(NSEvent *)e {
	if (defaultSettings->originX != [self frame].origin.x || defaultSettings->originY != [self frame].origin.y)
		[self updateDefaultSettings];
}

-(void)mouseEntered:(NSEvent *)e {
	alphaSnapshot = [self alphaValue];
	//NSLog(@"snapshot %f", alphaSnapshot);
}

-(void)mouseExited:(NSEvent *)e {
	//NSLog(@"snapshot check %f", [self alphaValue]);
	if (alphaSnapshot != [self alphaValue]) {
		[self updateDefaultSettings];
	}
}

- (void)alphaSliderValueDidChange:(NSEvent *)e {
	[self setAlphaValue:[alphaSlider doubleValue]];
}

- (void)close {
	[[NSNotificationCenter defaultCenter] postNotificationName:OVERLAY_NOTIFICATION_KEY_WILLCLOSE object:self];
	[super close];
}

@end
