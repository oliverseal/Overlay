//
//  OverlayAppDelegate.m
//  Overlay
//
//  Created by Oliver Wilkerson on 6/1/11.
//  Copyright 2011 Oliver Wilkerson. All rights reserved.
//

#import "OverlayAppDelegate.h"
#import "OverlayWindowDefaults.h"
#import "OverlayWindow.h"

@implementation OverlayAppDelegate

@synthesize windows;

- (void)dealloc {
	[windows release];
	[defaultWindowPreferences release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	//if the application is closing, we don't want to save the closing windows
	willTerminate = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	applicationIsActive = YES;
	NSLog(@"%i", [windows count]);
	for (OverlayWindow *window in windows) {
		if (window != nil)
			[window setIgnoresMouseEvents:NO];
	}
}

- (void)applicationDidResignActive:(NSNotification *)notification {
	applicationIsActive = NO;
	for (OverlayWindow *window in windows) {
		if (window != nil)
			[window setIgnoresMouseEvents:YES];
	}
}

- (void)awakeFromNib {
	windows = [[[NSMutableArray alloc] init] retain];
	defaultWindowPreferences = [[[NSMutableArray alloc] init] retain];
	//get any previous windows that were overlayed and load them.
	NSData *preferencesAtLoad = [[NSUserDefaults standardUserDefaults] objectForKey:OVERLAY_DEFAULTSKEY_WINDOWS];
	if (preferencesAtLoad != nil)
	{
		NSArray *windowsFromPreferences = [NSKeyedUnarchiver unarchiveObjectWithData:preferencesAtLoad];
		if (windowsFromPreferences != nil) {
			for (OverlayWindowDefaults *savedDefaults in windowsFromPreferences) {
				[self createNewOverlayWindowWithDefaults:savedDefaults withoutNotification:NO];
			}
		}
	}
}

- (void)openNewOverlayWindow:(id)sender {
	//open a new file dialog looking for only images
	openDialog = [NSOpenPanel openPanel];
	NSArray *fileTypes = [NSArray arrayWithObjects:@"jpg", @"png", @"tiff", nil];
	[openDialog setCanChooseFiles:YES];
	[openDialog setCanChooseDirectories:NO];
	[openDialog setAllowedFileTypes:fileTypes];
	[openDialog setAllowsOtherFileTypes:NO];
	[openDialog setAllowsMultipleSelection:YES];
	
	if ( [openDialog runModalForDirectory:nil file:nil types:fileTypes] == NSOKButton )
	{
		//we'll create an OverlayWindow for each of the files selected
		NSArray* files = [openDialog filenames];
		
		for(NSInteger i = 0; i < [files count]; i++ )
		{
			NSString* fileName = [[[NSString alloc] initWithString:[files objectAtIndex:i]] retain];
			[self createNewOverlayWindowWithLocation:fileName andAlpha:0.8 andAlwaysOnTop:YES];
		}
	}
	[self saveSettings];
}

- (OverlayWindow *) createNewOverlayWindowWithLocation:(NSString *)imageLocation andAlpha:(CGFloat)defaultAlpha andAlwaysOnTop:(BOOL)alwaysOnTop {
	//retain them; Window should release on dealloc
	OverlayWindowDefaults *defaults = [[[OverlayWindowDefaults alloc] init] retain];
	[defaults setImageLocation:imageLocation];
	[defaults setDefaultAlpha:defaultAlpha];
	[defaults setAlwaysOnTop:alwaysOnTop];
	
	OverlayWindow *window = [self createNewOverlayWindowWithDefaults:defaults withoutNotification:NO];
	return window;
}

- (OverlayWindow *) createNewOverlayWindowWithDefaults:(OverlayWindowDefaults *)defaults withoutNotification:(BOOL)silent {
	OverlayWindow *window = [OverlayWindow initWithDefaults: defaults quietly:silent];
	
	[window display];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayWindowWillClose:) name:OVERLAY_NOTIFICATION_KEY_WILLCLOSE object:window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overlayWindowDefaultsChanged:) name:OVERLAY_NOTIFICATION_KEY_DEFAULTSCHANGED object:window];
	[window makeKeyAndOrderFront:self];
	[windows addObject:window];
	[defaultWindowPreferences addObject:defaults];
	return window;
}

- (void)overlayWindowWillClose:(id)sender {
	NSNotification *senderNote = sender;
	OverlayWindow *closingWindow = senderNote.object;
	if (closingWindow != nil) {
		[defaultWindowPreferences removeObject:closingWindow.defaultSettings];
		if (!willTerminate)
			[self saveSettings];
	}
	[windows removeObject:senderNote.object];
}

- (void)overlayWindowDefaultsChanged:(id)sender {
	[self saveSettings];
}

- (void)saveSettings {
	NSArray *unmutableArray = defaultWindowPreferences;
	//NSLog(@"Saving these: %@", unmutableArray);
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:unmutableArray] forKey:OVERLAY_DEFAULTSKEY_WINDOWS];
}
@end
