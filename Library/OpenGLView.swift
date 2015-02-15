/*

  Created by David Spooner

*/

import UIKit


protocol GxOpenGLViewDelegate
  {
    func createStateForOpenGLView(sender: GxOpenGLView)
    func deleteStateForOpenGLView(sender: GxOpenGLView)
    func drawOpenGLView(sender: GxOpenGLView)
  }


@IBDesignable
class GxOpenGLView : UIView
  {

    var context: EAGLContext!

    var renderBuffer: GLuint = 0
    var frameBuffer: GLuint = 0
    var backingWidth: GLint = 0
    var backingHeight: GLint = 0

    var delegate: GxOpenGLViewDelegate!


    override class func layerClass() -> AnyClass
      { return CAEAGLLayer.self }


    class func createOpenGLContext() -> EAGLContext
      { return EAGLContext(API:EAGLRenderingAPI.OpenGLES2) }


    convenience init(frame: CGRect, context: EAGLContext)
      {
        self.init(frame:frame)

        self.context = context
      }


    override func awakeFromNib()
      {
        if context == nil {
          context = self.dynamicType.createOpenGLContext()
        }
      }


    func createFramebuffer()
      {
        assert(EAGLContext.currentContext() == context!, "unexpected state")

        glGenFramebuffersOES(1, &frameBuffer)
        glGenRenderbuffersOES(1, &renderBuffer)
        glBindFramebufferOES(GLenum(GL_FRAMEBUFFER_OES), frameBuffer)
        glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), renderBuffer)

        context!.renderbufferStorage(Int(GL_RENDERBUFFER_OES), fromDrawable:(self.layer as! CAEAGLLayer))

        glFramebufferRenderbufferOES(GLenum(GL_FRAMEBUFFER_OES), GLenum(GL_COLOR_ATTACHMENT0_OES), GLenum(GL_RENDERBUFFER_OES), renderBuffer);
        if glCheckFramebufferStatusOES(GLenum(GL_FRAMEBUFFER_OES)) != GLenum(GL_FRAMEBUFFER_COMPLETE_OES) {
          NSLog("glFramebufferRenderbufferOES failed")
        }

        glGetRenderbufferParameterivOES(GLenum(GL_RENDERBUFFER_OES), GLenum(GL_RENDERBUFFER_WIDTH_OES), &backingWidth)
        glGetRenderbufferParameterivOES(GLenum(GL_RENDERBUFFER_OES), GLenum(GL_RENDERBUFFER_HEIGHT_OES), &backingHeight)
      }


    func deleteFramebuffer()
      {
        assert(EAGLContext.currentContext() == context!, "unexpected state")

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


    // UIView

    override func didMoveToWindow()
      {
        EAGLContext.setCurrentContext(context!)

        if self.window != nil {
          var layer = self.layer as! CAEAGLLayer
          layer.opaque = false
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
        EAGLContext.setCurrentContext(context!)

        // Set the viewport according to the dimensions of the renderbuffer
        glViewport(0, 0, backingWidth, backingHeight)

        // Set the clear color (transparent black if backgroundColor == nil)
        var r:GLfloat=0, g:GLfloat=0, b:GLfloat=0, a:GLfloat=0
        self.backgroundColor?.getGLRed(&r, green:&g, blue:&b, alpha:&a)
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
