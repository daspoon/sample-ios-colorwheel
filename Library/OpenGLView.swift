/*

  Copyright © 2010-2016 David Spooner; see License.txt

  A subclass of UIView which enables drawing content with OpenGL. The OpenGLViewDelegate protocol
  enables a delegate to manage graphic state and perform drawing.

*/

import UIKit


protocol OpenGLViewDelegate
  {

    func createStateForOpenGLView(_ sender: OpenGLView)
      // This method is invoked when the sending view becomes associated with a window.
      // It can be used to allocate graphics state.

    func deleteStateForOpenGLView(_ sender: OpenGLView)
      // This method is invoked when the sending view is disassociated with its window.
      // It can be used to deallocate graphics state.

    func drawOpenGLView(_ sender: OpenGLView)
      // This method is invoked whenever the view needs to be redrawn.

  }


@IBDesignable
class OpenGLView : UIView
  {

    var context: EAGLContext!

    var renderBuffer: GLuint = 0
    var frameBuffer: GLuint = 0
    var backingWidth: GLint = 0
    var backingHeight: GLint = 0

    var delegate: OpenGLViewDelegate!


    override class var layerClass : AnyClass
      { return CAEAGLLayer.self }


    class func createOpenGLContext() -> EAGLContext
      { return EAGLContext(api:EAGLRenderingAPI.openGLES2) }


    convenience init(frame: CGRect, context: EAGLContext)
      {
        self.init(frame:frame)

        self.context = context
      }


    override func awakeFromNib()
      {
        if context == nil {
          context = type(of: self).createOpenGLContext()
        }
      }


    func createFramebuffer()
      {
        assert(EAGLContext.current() == context!, "unexpected state")

        glGenFramebuffersOES(1, &frameBuffer)
        glGenRenderbuffersOES(1, &renderBuffer)
        glBindFramebufferOES(GLenum(GL_FRAMEBUFFER_OES), frameBuffer)
        glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), renderBuffer)

        context!.renderbufferStorage(Int(GL_RENDERBUFFER_OES), from:(self.layer as! CAEAGLLayer))

        glFramebufferRenderbufferOES(GLenum(GL_FRAMEBUFFER_OES), GLenum(GL_COLOR_ATTACHMENT0_OES), GLenum(GL_RENDERBUFFER_OES), renderBuffer);
        if glCheckFramebufferStatusOES(GLenum(GL_FRAMEBUFFER_OES)) != GLenum(GL_FRAMEBUFFER_COMPLETE_OES) {
          NSLog("glFramebufferRenderbufferOES failed")
        }

        glGetRenderbufferParameterivOES(GLenum(GL_RENDERBUFFER_OES), GLenum(GL_RENDERBUFFER_WIDTH_OES), &backingWidth)
        glGetRenderbufferParameterivOES(GLenum(GL_RENDERBUFFER_OES), GLenum(GL_RENDERBUFFER_HEIGHT_OES), &backingHeight)
      }


    func deleteFramebuffer()
      {
        assert(EAGLContext.current() == context!, "unexpected state")

        glDeleteFramebuffersOES(1, &frameBuffer)
        glDeleteRenderbuffersOES(1, &renderBuffer)

        frameBuffer = 0
        renderBuffer = 0
        backingWidth = 0
        backingHeight = 0
      }


    func createState()
      {
        delegate?.createStateForOpenGLView(self)
      }


    func deleteState()
      {
        delegate?.deleteStateForOpenGLView(self)
      }


    func draw()
      {
        delegate?.drawOpenGLView(self)
      }


    // MARK: - UIView

    override func didMoveToWindow()
      {
        EAGLContext.setCurrent(context!)

        if self.window != nil {
          let layer = self.layer as! CAEAGLLayer
          layer.isOpaque = false
          layer.drawableProperties = [
              kEAGLDrawablePropertyRetainedBacking: false,
              kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8,
            ]

          self.createFramebuffer()
          self.createState()
        }
        else {
          self.deleteState()
          self.deleteFramebuffer()
        }
      }


    override func layoutSubviews()
      {
        EAGLContext.setCurrent(context!)

        // Set the viewport according to the dimensions of the renderbuffer
        glViewport(0, 0, backingWidth, backingHeight)

        // Set the clear color (transparent black if backgroundColor == nil)
        var r:GLfloat=0, g:GLfloat=0, b:GLfloat=0, a:GLfloat=0
        self.backgroundColor?.getGL(red:&r, green:&g, blue:&b, alpha:&a)
        glClearColor(r, g, b, a)

        // Clear the buffers
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT))

        // Subclass-specific drawing
        self.draw()

        context!.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
      }


    override func setNeedsDisplay()
      {
        self.setNeedsLayout()
      }

  }
