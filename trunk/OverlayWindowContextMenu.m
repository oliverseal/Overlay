//
//  OverlayWindowContextMenu.m
//  Overlay
//
//  Created by Oliver Wilkerson on 6/1/11.
//  Copyright 2011 Oliver Wilkerson. All rights reserved.
//

#import "OverlayWindowContextMenu.h"
#import "OverlayWindow.h"


@implementation OverlayWindowContextMenu

@synthesize alwaysOnTopItem;
@synthesize closeItem;
@synthesize showAlphaSliderItem;
@synthesize parentWindow;

- (void)dealloc {
	[alwaysOnTopItem dealloc];
	[closeItem dealloc];
	[showAlphaSliderItem dealloc];
	[super dealloc];
}

- (OverlayWindowContextMenu *)initWithWindow:(OverlayWindow *)callingWindow {
	self = [self init];	
	
	showAlphaSliderItem = [[NSMenuItem alloc] initWithTitle:@"Show Alpha Slider" action:nil keyEquivalent:@"t"];
	alwaysOnTopItem = [[NSMenuItem alloc] initWithTitle:@"Always On Top" action:nil keyEquivalent:@"a"];
	closeItem = [[NSMenuItem alloc] initWithTitle:@"Close" action:nil keyEquivalent:@"w"];
	
	[self addItem:showAlphaSliderItem];
	[self addItem:alwaysOnTopItem];
	[self addItem:closeItem];
	
	[self setAutoenablesItems:NO];
	parentWindow = callingWindow;
	[closeItem setTarget:parentWindow];
	[closeItem setAction:@selector(close)];
	
	[alwaysOnTopItem setTarget:parentWindow];
	[alwaysOnTopItem setAction:@selector(toggleAlwaysOnTop)];
	if (parentWindow.alwaysOnTop == YES)
		[alwaysOnTopItem setState:NSOnState];
	else
		[alwaysOnTopItem setState:NSOffState];
	
	[showAlphaSliderItem setTarget:parentWindow];
	[showAlphaSliderItem setAction:@selector(toggleAlphaSlider)];
	if (parentWindow.alphaSliderVisible == YES)
		[showAlphaSliderItem setState:NSOnState];
	else
		[showAlphaSliderItem setState:NSOffState];
	return self;
}

- (void)overlayWindowAlwaysOnTopChanged:(id)sender {
	if (parentWindow.alwaysOnTop == YES)
		[alwaysOnTopItem setState:NSOnState];
	else
		[alwaysOnTopItem setState:NSOffState];
}

-(void)overlayWindowAlphaSliderVisibleChanged:(id)sender {
	if (parentWindow.alphaSliderVisible == YES)
		[showAlphaSliderItem setState:NSOnState];
	else
		[showAlphaSliderItem setState:NSOffState];
}

@end
