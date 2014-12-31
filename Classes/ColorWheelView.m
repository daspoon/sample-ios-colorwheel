/*

  Created by David Spooner on 4/28/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import "ColorWheelView.h"
#import "glutils.h"
#import "geometry.h"
#import "colors.h"
#import "UIColor-GxGraphics.h"


// The format of vertex data in the wheelVertexBuffer buffer.
typedef struct {
      GLfloat x, y;
      GLfloat r, g, b, a;
  } GxColorWheelVertex;


@implementation GxColorWheelView

@synthesize numberOfSlices, borderColor, selectedPoint, brightness, delegate;


- (id) initWithFrame:(CGRect)aRect context:(EAGLContext *)aContext
  {
    if ((self = [super initWithFrame:aRect context:aContext]) == nil)
      return nil;

    numberOfSlices = 64;
    borderColor    = nil;
    selectedPoint  = CGPointMake(0.5, 0.5);
    brightness     = 1.0;

    return self;
  }


- (void) dealloc
  {
    [borderColor release];
    [super dealloc];
  }


+ (UIColor *) colorForPoint:(CGPoint)point withBrighness:(CGFloat)value
  {
  // note: it is expected that point lies within the unit circle...
    CGFloat hue = (M_PI + atan2(-point.y, -point.x)) / (2 * M_PI);
    CGFloat saturation = sqrt(point.x*point.x + point.y*point.y);
    return [[[UIColor alloc] initWithHue:hue saturation:saturation brightness:value alpha:1.0] autorelease];
  }


+ (void) getPoint:(CGPoint *)point_p andBrighness:(CGFloat *)value_p forColor:(UIColor *)color
  {
    NSAssert(point_p && value_p && color, @"invalid arguments");

    CGFloat r, g, b, h, s, v, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    GxConvertRGBToHSB(r, g, b, h, s, v);

    if (s == 0) // h == NAN
      *point_p = CGPointMake(0, 0);
    else {
      float a = h * (M_PI * 2);
      point_p->x = cos(a) * s;
      point_p->y = sin(a) *s;
    }

    *value_p = v;
  }


- (void) setNumberOfSlices:(GLuint)number
  {
    if (number == numberOfSlices)
      return;

    numberOfSlices = number;

    flags.wheelChanged = 1;
    [self setNeedsDisplay];
  }


- (void) setSelectedPoint:(CGPoint)point
  {
    if (CGPointEqualToPoint(point, selectedPoint))
      return;

    CGFloat len = sqrt(point.x*point.x + point.y*point.y);
    if (len > 1) {
      point.x /= len;
      point.y /= len;
    }
    selectedPoint = point;

    flags.pointChanged = 1;
    [self setNeedsDisplay];
  }


- (void) setBrightness:(CGFloat)value
  {
    if (value == brightness)
      return;

    brightness = value;

    flags.wheelChanged = 1;
    [self setNeedsDisplay];
  }


+ (NSSet *) keyPathsForValuesAffectingSelectedColor
  { return [NSSet setWithObjects:@"selectedPoint", @"brightness", nil]; }

- (UIColor *) selectedColor
  { return [isa colorForPoint:selectedPoint withBrighness:brightness]; }


- (CGRect) projectionRect
  {
    // As viewing volume we use an orthographic projection corresponding to the smallest rectangle
    // which encloses [-1..1]x[-1..1] and has the aspect ratio of our bounds
    return GxOuterImageRect(CGRectMake(-1,-1,2,2), GxRectAspectRatio(self.bounds));
  }


- (void) updateWheelVertexBuffer
  {
    // Generate the vertex coordinate and color data for the wheel: the first vertex is the center 
    // of the circle and is white; the remaining (n_slices + 1) vertices loop around the edge of the
    // circle, with the last edge point a duplicate of the first edge point...
    GxColorWheelVertex data[numberOfSlices + 2];
    data[0].x = data[0].y = 0;
    data[0].r = data[0].g = data[0].b = brightness;
    data[0].a = 1.0;
    GLfloat delta_angle = (2 * M_PI) / numberOfSlices, delta_hue = 1.0 / numberOfSlices;
    for (GLuint i = 0; i <= numberOfSlices; ++i) {
      GxColorWheelVertex *v = &data[i+1];
      v->x = cos(i * delta_angle);
      v->y = sin(i * delta_angle);
      GxConvertHSBToRGB(i * delta_hue, 1.0, brightness, v->r, v->g, v->b);
      v->a = 1.0;
    }

    glBufferData(GL_ARRAY_BUFFER, sizeof(data), data, GL_STATIC_DRAW);

    flags.wheelChanged = 0;
  }


- (void) updatePointVertexBuffer
  {
    // Generate the vertex and color data for the selected point indicator.
    CGFloat delta = 0.015;
    GLfloat v[8] = { // 2-triangle strip...
        selectedPoint.x-delta, selectedPoint.y-delta,
        selectedPoint.x-delta, selectedPoint.y+delta,
        selectedPoint.x+delta, selectedPoint.y-delta,
        selectedPoint.x+delta, selectedPoint.y+delta
      };

    glBufferData(GL_ARRAY_BUFFER, sizeof(v), v, GL_STATIC_DRAW);

    flags.pointChanged = 0;
  }


#pragma mark Actions

- (void) processTouch:(UITouch *)touch
  {
    CGPoint point = [touch locationInView:self];

    // Convert the point from view coordinates to 'world' coordinates and update our selected point
    CGRect  r = self.bounds;
    CGFloat s = fmin(CGRectGetWidth(r), CGRectGetHeight(r)) * 0.5;
    CGFloat x =  (point.x - CGRectGetMidX(r)) / s;
    CGFloat y = -(point.y - CGRectGetMidY(r)) / s;
    self.selectedPoint = CGPointMake(x, y);

    // Inform the delegate
    if ([delegate respondsToSelector:@selector(colorWheelSelectionDidChange:)])
      [(id<GxColorWheelViewDelegate>)delegate colorWheelSelectionDidChange:self];
  }


#pragma mark GxEAGLView

- (void) createState
  {
    [super createState];

    // Turn off depth testing
    glDepthFunc(GL_ALWAYS);

    // Create the vertex buffers for the wheel and selected point graphics
    glGenBuffers(1, &wheelVertexBuffer);
    glGenBuffers(1, &pointVertexBuffer);

    // Mark these buffers as needing update on the next draw call
    flags.wheelChanged = 1;
    flags.pointChanged = 1;

    // Create and update the element buffer for the selected point as an outline
    glGenBuffers(1, &pointIndexBuffer);
    GLubyte indices[4] = {0, 1, 3, 2};
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, pointIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4*sizeof(GLubyte), indices, GL_STATIC_DRAW);

    // Enable vertex arrays
    enableVertexAttribArray(context.API, 0);
  }


- (void) createES2State
  {
    [super createES2State];

    // Create and compile a vertex shader.
    GLchar *message;
    vertexShader = GxCreateCompiledShader(GL_VERTEX_SHADER, &message,
        "attribute vec4 point, color;",
        "uniform mat4 projection;",
        "varying highp vec4 fragColor;",
        "void main(void) {",
        "  gl_Position = projection * point;",
        "  fragColor = color;",
        "}",
        NULL);
    if (vertexShader == 0) {
      NSLog(@"vertex shader compilation failed: %s", message);
      free(message);
    }

    // Create and compile a fragment shader.
    fragmentShader = GxCreateCompiledShader(GL_FRAGMENT_SHADER, &message, 
        "varying highp vec4 fragColor;",
        "void main(void) {",
        "  gl_FragColor = fragColor;",
        "}",
        NULL);
    if (fragmentShader == 0) {
      NSLog(@"fragment shader compilation failed: %s", message);
      free(message);
    }

    // Create a program linking the two shaders.
    program = GxCreateLinkedProgram(&message, vertexShader, fragmentShader, NULL);
    if (program == 0) {
      NSLog(@"program linking failed: %s", message);
      free(message);
    }

    // Get the location of our projection matrix uniform.
    projectionLoc = glGetUniformLocation(program, "projection");
  }


- (void) deleteState
  {
    // Delete our vertex buffers
    if (wheelVertexBuffer)
      { glDeleteBuffers(1, &wheelVertexBuffer); wheelVertexBuffer = 0; }
    if (pointVertexBuffer)
      { glDeleteBuffers(1, &pointVertexBuffer); pointVertexBuffer = 0; }
    if (pointIndexBuffer)
      { glDeleteBuffers(1, &pointIndexBuffer); pointIndexBuffer = 0; }

    [super deleteState];
  }


- (void) deleteES2State
  {
    // Delete our program and shaders
    if (program)
      { glDeleteProgram(program); program = 0; }
    if (vertexShader != 0)
      { glDeleteShader(vertexShader); vertexShader = 0; }
    if (fragmentShader != 0)
      { glDeleteShader(fragmentShader); fragmentShader = 0; }

    [super deleteES2State];
  }


- (void) drawES2
  {
    glUseProgram(program);

    // Upload the projection matrix
    CGRect rect = [self projectionRect];
    GLfloat P[16];
    setOrtho(P, CGRectGetMinX(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxY(rect), -1, 1);
    glUniformMatrix4fv(projectionLoc, 1, NO, P);

    [super drawES2];
  }


- (void) drawES1
  {
    // Establish projection matrix
    CGRect rect = [self projectionRect];
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(CGRectGetMinX(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxY(rect), -1, 1);

    [super drawES1];
  }


- (void) draw
  {
    [super draw];

    EAGLRenderingAPI API = context.API;

    // Draw the color wheel interior as a triangle fan (with per-vertex colors)...
    glBindBuffer(GL_ARRAY_BUFFER, wheelVertexBuffer);
    if (flags.wheelChanged)
      [self updateWheelVertexBuffer];
    vertexAttribPointer(API, 0, 2, GL_FLOAT, FALSE, sizeof(GxColorWheelVertex), (void *)0);
    vertexAttribPointer(API, 1, 4, GL_FLOAT, FALSE, sizeof(GxColorWheelVertex), (void *)(2*sizeof(GLfloat)));
    enableVertexAttribArray(API, 1);
    glDrawArrays(GL_TRIANGLE_FAN, 0, numberOfSlices + 2);
    disableVertexAttribArray(API, 1);
    // and draw the perimeter as a line loop in the specified border color.
    CGFloat r=0, g=0, b=0, a=0;
    [borderColor getRed:&r green:&g blue:&b alpha:&a];
    vertexAttrib4f(API, 1, r, g, b, a);
    glDrawArrays(GL_LINE_LOOP, 1, numberOfSlices);

    // Draw the selected point as a white square (2-triangle strip)
    glBindBuffer(GL_ARRAY_BUFFER, pointVertexBuffer);
    if (flags.pointChanged)
      [self updatePointVertexBuffer];
    vertexAttribPointer(API, 0, 2, GL_FLOAT, FALSE, sizeof(GLfloat)*2, (void *)0);
    vertexAttrib4f(API, 1, 1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // Draw the selected point as a black line loop.
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, pointIndexBuffer);
    vertexAttrib4f(API, 1, 0.0, 0.0, 0.0, 1.0);
    glDrawElements(GL_LINE_LOOP, 4, GL_UNSIGNED_BYTE, (void *)0);
  }


#pragma mark UIResponder

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
  {
    if ([[event touchesForView:self] count] == 1)
      [self processTouch:[touches anyObject]];
  }


- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
  {
    if ([[event touchesForView:self] count] == 1)
      [self processTouch:[touches anyObject]];
  }

@end
