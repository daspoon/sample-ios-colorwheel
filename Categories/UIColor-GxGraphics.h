/*

    Created by David Spooner on 2/3/10.
    Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>


@interface UIColor(GxGraphics)

- (void) getRed:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b alpha:(CGFloat *)a;
    // Get the receiver's RGBA components (each component is in [0..1]).

@end
