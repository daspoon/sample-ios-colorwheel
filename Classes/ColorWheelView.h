/*

  Created by David Spooner on 4/28/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

  A ColorWheelView draws and allows interaction with a color wheel.  OpenGL ES is
  used for drawing and both ES1 and ES2 are supported.

*/

#import "EAGLView.h"

@protocol GxColorWheelViewDelegate;


@interface GxColorWheelView : GxEAGLView
  {
    GLuint        numberOfSlices;
    UIColor      *borderColor;
    CGPoint       selectedPoint;
    CGFloat       brightness;
    id            delegate;

    GLuint        program;              // program name
    GLuint        vertexShader;         // shader name
    GLuint        fragmentShader;       // shader name
    GLuint        wheelVertexBuffer;    // buffer name
    GLuint        pointVertexBuffer;    // buffer name
    GLuint        pointIndexBuffer;     // buffer name
    GLuint        projectionLoc;        // index of 'projection' uniform

    struct {
      NSUInteger  pointChanged:1;
      NSUInteger  wheelChanged:1;
      } flags;
  }

@property (nonatomic) GLuint numberOfSlices;
    // The number of divisions used to draw the color wheel.

@property (nonatomic, retain) UIColor *borderColor;
    // Optional color to draw the perimeter of the color wheel.

@property (nonatomic) CGPoint selectedPoint;
    // A point in the unit circle corresponding to the hue and saturation of the
    // selected color.

@property (nonatomic) CGFloat brightness;
    // The brightness of the selected color, between 0 and 1.

@property (nonatomic, assign) NSObject<GxColorWheelViewDelegate> *delegate;
    // An object which will be notified of changes to the selected color.

@property (nonatomic, readonly) UIColor *selectedColor;
    // The selected color.


+ (UIColor *) colorForPoint:(CGPoint)point withBrighness:(CGFloat)value;
    // Return the color corresponding to the given point in the unit circle (corresponding 
    // to hue and saturation) and brighness value (between 0 and 1).

+ (void) getPoint:(CGPoint *)point_p andBrighness:(CGFloat *)value_p forColor:(UIColor *)color;
    // Return the point and brightness corresponding to the given color.

@end


@protocol GxColorWheelViewDelegate

- (void) colorWheelSelectionDidChange:(GxColorWheelView *)sender;
    // Invoked in response to touch events which effect the selected point.

@end
