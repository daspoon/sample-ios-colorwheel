/*

  Created by David Spooner on 4/29/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

  Derived from Apple's EAGLView sample code...

*/

#import "EAGLView.h"
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>


@implementation GxEAGLView

@synthesize context;


+ (Class) layerClass
  { return [CAEAGLLayer class]; }


- (id) initWithFrame:(CGRect)aRect context:(EAGLContext *)aContext
  {
    if ((self = [super initWithFrame:aRect]) == nil)
      return nil;

    context = aContext;

    [self awakeFromNib];

    return self;
  }


- (id) initWithFrame:(CGRect)aRect
  {
    return [self initWithFrame:aRect context:nil];
  }


- (void) awakeFromNib
  {
    [super awakeFromNib];

    if (context == nil)
      context = [self.class createOpenGLContext];
  }


+ (EAGLContext *) createOpenGLContext
  {
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (aContext == nil)
      aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    return aContext;
  }


- (void) createFramebuffer
  {
    NSAssert([EAGLContext currentContext] == context, @"wrong context");

    glGenFramebuffersOES(1, &frameBuffer);
    glGenRenderbuffersOES(1, &renderBuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, frameBuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderBuffer);

    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer *)self.layer];

    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderBuffer);
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
      NSLog(@"glFramebufferRenderbufferOES failed");

    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
  }


- (void) deleteFramebuffer
  {
    NSAssert([EAGLContext currentContext] == context, @"wrong context");

    glDeleteFramebuffersOES(1, &frameBuffer);
    glDeleteRenderbuffersOES(1, &renderBuffer);
    frameBuffer = 0;
    renderBuffer = 0;
  }


- (void) createState
  {
  }


- (void) createES1State
  {
    [self createState];
  }


- (void) createES2State
  {
    [self createState];
  }


- (void) deleteState
  {
  }


- (void) deleteES1State
  {
    [self deleteState];
  }


- (void) deleteES2State
  {
    [self deleteState];
  }


- (void) draw
  {
  }


- (void) drawES1
  {
    [self draw];
  }


- (void) drawES2
  {
    [self draw];
  }


#pragma mark UIView

- (void) didMoveToWindow
  {
    [EAGLContext setCurrentContext:context];

    if (self.window) {
      CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
      layer.opaque = YES;
      layer.drawableProperties
          = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                    nil];

      [self createFramebuffer];
      switch (context.API) {
        case kEAGLRenderingAPIOpenGLES1 :
          [self createES1State];
          break;
        case kEAGLRenderingAPIOpenGLES2 :
          [self createES2State];
          break;
        default :
          NSAssert(0, @"unhandled case");
      }
      [self setNeedsLayout];
    }
    else {
      switch (context.API) {
        case kEAGLRenderingAPIOpenGLES1 :
          [self deleteES1State];
          break;
        case kEAGLRenderingAPIOpenGLES2 :
          [self deleteES2State];
          break;
        default :
          NSAssert(0, @"unhandled case");
      }
      [self deleteFramebuffer];
    }
  }


- (void) layoutSubviews
  {
    [EAGLContext setCurrentContext:context];

    // Set the viewport according to the dimensions of the renderbuffer
    glViewport(0, 0, backingWidth, backingHeight);

    // Set the clear color (transparent black if backgroundColor == nil)
    GLfloat r=0, g=0, b=0, a=0;
    [self.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
    glClearColor(r, g, b, a);

    // Clear the buffers
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    switch (context.API) {
      case kEAGLRenderingAPIOpenGLES1 :
        [self drawES1];
        break;
      case kEAGLRenderingAPIOpenGLES2 :
        [self drawES2];
        break;
      default :
        NSAssert(0, @"unhandled case");
    }

    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
  }


- (void) setNeedsDisplay
  { [self setNeedsLayout]; }

@end
