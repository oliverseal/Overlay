//
//  OverlayWindowContextMenu.h
//  Overlay
//
//  Created by Oliver Wilkerson on 6/1/11.
//  Copyright 2011 Oliver Wilkerson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OverlayWindow.h"

@interface OverlayWindowContextMenu : NSMenu {
	NSMenuItem *showAlphaSliderItem;
	NSMenuItem *alwaysOnTopItem;
	NSMenuItem *closeItem;
	OverlayWindow *parentWindow;
}
@property (assign) NSMenuItem *alwaysOnTopItem;
@property (assign) NSMenuItem *closeItem;
@property (assign) NSMenuItem *showAlphaSliderItem;
@property (assign) OverlayWindow *parentWindow;

- (void)overlayWindowAlwaysOnTopChanged:(id)sender;
- (void)overlayWindowAlphaSliderVisibleChanged:(id)sender;
@end
