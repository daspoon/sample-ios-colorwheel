/*

  Created by David Spooner on 4/29/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

  An EAGLView encapsulates some of the tasks required to interact with OpenGL ES and is
  intended  to simplify the creation of views classes for drawing specific content.

*/

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>


@interface GxEAGLView : UIView
  {
    EAGLContext  *context;
    GLuint        renderBuffer;
    GLuint        frameBuffer;
    GLint         backingWidth;
    GLint         backingHeight;
  }


- (id) initWithFrame:(CGRect)aRect context:(EAGLContext *)aContext;
    // Initialize a new instance with the given OpenGL context, which must not be nil.


// UIView overrides

- (void) didMoveToWindow;
    // The behavior of this method depends on whether the receiver is being associated with a
    // window or disassociated from its window: in the former case, the framebuffer and the
    // drawing state are created; in the latter case, the framebuffer and drawing state are 
    // deleted.

- (void) layoutSubviews;
    // This method performs rendering: specifically, it makes the associated context current, 
    // sets the viewport, clears the color and depth buffers, invokes the appropriate -draw
    // method (based on context's -API), and presents the renderbuffer.


// Protected methods

- (void) createFramebuffer;
    // Create the backing framebuffer and note the viewport dimensions.

- (void) deleteFramebuffer;
    // Delete the backing framebuffer.

- (void) createES1State;
- (void) createES2State;
    // Called upon the receiver's assignment to a window.  Subclasses can override these
    // methods to perform context initialization or allocate resources in the GL.  The
    // default implementations call -createState.

- (void) createState;
    // Subclasses can override this method to perform API-independent context initialization 
    // resource allocation.  The default implementation does nothing.

- (void) drawES1;
- (void) drawES2;
    // Called by -layoutSubviews to render view content.  The default implementations 
    // call -draw.

- (void) draw;
    // Subclasses can override this method to perform API-independent rendering.  The 
    // default implementation does nothing.

- (void) deleteES1State;
- (void) deleteES2State;
    // Called upon the receiver's removal from its window.  Subclasses can override these
    // methods to delete resources within the GL.  The default implementations call
    // -deleteState.

- (void) deleteState;
    // Subclasses can override this method to perform API-independent resource deallocation. 
    // The default implementation does nothing.

@end
