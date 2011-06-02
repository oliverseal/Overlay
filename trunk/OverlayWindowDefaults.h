//
//  OverlayWindowDefaults.h
//  Overlay
//
//  Created by Oliver Wilkerson on 6/1/11.
//  Copyright 2011 Oliver Wilkerson. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//this is just something that is storable
@interface OverlayWindowDefaults : NSObject <NSCoding> {
	NSString *imageLocation;
	CGFloat defaultAlpha;
	BOOL alwaysOnTop;
@public
	CGFloat originX;
	CGFloat originY;
}
@property (assign) NSString *imageLocation;
@property (assign) CGFloat defaultAlpha;
@property (assign) BOOL alwaysOnTop;

-(void)setOrigin:(NSPoint)origin;
@end
