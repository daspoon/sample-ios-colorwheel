/*

  Copyright © 2010-2016 David Spooner; see License.txt

  A subclass of UIControl implementing a color wheel which emits value-changed actions 
  in response to touch/dragging events.

*/

import UIKit


@IBDesignable
class ColorWheel : UIControl, OpenGLViewDelegate
  {

    @IBInspectable var numberOfSlices: UInt = 256
      { didSet { wheelChanged=true; openGLView?.setNeedsDisplay()} }

    var selectedPoint: CGPoint = CGPoint(x:0.5, y:0.5)
      { didSet { pointChanged=true; openGLView?.setNeedsDisplay()} }

    var brightness: CGFloat = 1
      { didSet { wheelChanged=true; openGLView?.setNeedsDisplay()} }

    var borderColor: UIColor?

    var pointSize: CGFloat = 0.03

    var openGLView: OpenGLView!
    var program: GLuint = 0
    var vertexShader: GLuint = 0
    var fragmentShader: GLuint = 0
    var wheelVertexBuffer: GLuint = 0
    var pointVertexBuffer: GLuint = 0
    var pointIndexBuffer: GLuint = 0
    var projectionLoc: Int32 = 0

    var pointChanged: Bool = false
    var wheelChanged: Bool = false


    override func awakeFromNib()
      {
        openGLView = OpenGLView(frame:self.bounds, context:OpenGLView.createOpenGLContext())
        openGLView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.addSubview(openGLView)

        // We emit the content-specific GL code
        openGLView.delegate = self

        // Disable interaction in the GL view so we get touch events
        openGLView.userInteractionEnabled = false
      }


    struct Vertex
      {
        var x:GLfloat=0, y:GLfloat=0, r:GLfloat=0, g:GLfloat=0, b:GLfloat=0, a:GLfloat=0
      }

    var numberOfVertices: UInt
      { return numberOfSlices + 2 }


    var projectionRect: CGRect
      { return CGRect.withIncsribedRect(CGRect(x:-1,y:-1,width:2,height:2), aspectRatio:self.bounds.aspectRatio) }


    func updateWheelVertexBuffer()
      {
        // Generate the vertex coordinate and color data for the wheel: the first vertex is the center
        // of the circle and is white; the remaining (n_slices + 1) vertices loop around the edge of the
        // circle, with the last edge point a duplicate of the first edge point...

        var vertices = Array(count:Int(numberOfVertices), repeatedValue:Vertex())

        vertices[0].r = 1
        vertices[0].g = 1
        vertices[0].b = 1
        vertices[0].a = 1

        let delta_hue = 1.0 / CGFloat(numberOfSlices)
        let delta_phi = (2 * CGFloat(M_PI)) / CGFloat(numberOfSlices)
        for j in 0 ..< Int(numberOfSlices+1) {
          let d = CGFloat(j) * delta_phi
          let c = UIColor(hue:(CGFloat(j) * delta_hue), saturation:1, brightness:brightness, alpha:1)
          var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0
          c.getRed(&r, green:&g, blue:&b, alpha:nil)
          vertices[j+1].x = GLfloat(cos(d))
          vertices[j+1].y = GLfloat(sin(d))
          vertices[j+1].r = GLfloat(r)
          vertices[j+1].g = GLfloat(g)
          vertices[j+1].b = GLfloat(b)
          vertices[j+1].a = 1
        }

        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count * sizeof(Vertex), &vertices, GLenum(GL_STATIC_DRAW))

        wheelChanged = false
      }


    func updatePointVertexBuffer()
      {
        // Upload the vertex data (a 2-triangle strip) for the selected point indicator .

        let x = GLfloat(selectedPoint.x)
        let y = GLfloat(selectedPoint.y)
        let d = GLfloat(0.5 * pointSize)

        var vertices: [GLfloat] = [
            x - d, y - d,
            x - d, y + d,
            x + d, y - d,
            x + d, y + d,
          ]

        glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count*sizeof(GLfloat), &vertices, GLenum(GL_STATIC_DRAW))
      }


    // Actions

    func processTouch(sender: UITouch)
      {
        let point = sender.locationInView(self)

        // Convert the point from view coordinates to 'world' coordinates and update our selected point
        let r = self.bounds
        let s = fmin(CGRectGetWidth(r), CGRectGetHeight(r)) * 0.5
        let x =  (point.x - CGRectGetMidX(r)) / s
        let y = -(point.y - CGRectGetMidY(r)) / s
        self.selectedPoint = CGPoint(x:x, y:y)

        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
      }


    // OpenGLViewDelegate

    func createStateForOpenGLView(sender: OpenGLView)
      {
        var error: NSString?

        // Turn off depth testing
        glDepthFunc(GLenum(GL_ALWAYS))

        // Create the vertex buffers for the wheel and selected point graphics
        glGenBuffers(1, &wheelVertexBuffer)
        glGenBuffers(1, &pointVertexBuffer)

        // Mark these buffers as needing update on the next draw call
        wheelChanged = true
        pointChanged = true

        // Create and update the element buffer for the selected point as an outline
        glGenBuffers(1, &pointIndexBuffer)
        let indices: [GLubyte] = [0, 1, 3, 2]
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), pointIndexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), 4*sizeof(GLubyte), indices, GLenum(GL_STATIC_DRAW))

        // Enable vertex arrays
        glEnableVertexAttribArray(0);

        // Create and compile a vertex shader.
        vertexShader = sender.context.createCompiledShader(GLenum(GL_VERTEX_SHADER), error:&error, withSourceStrings:[
            "attribute vec4 point, color;",
            "uniform mat4 projection;",
            "varying highp vec4 fragColor;",
            "void main(void) {",
            "  gl_Position = projection * point;",
            "  fragColor = color;",
            "}"
          ])
        if vertexShader == 0 {
          NSLog("vertex shader compilation failed: \(error)")
        }

        // Create and compile a fragment shader.
        fragmentShader = sender.context.createCompiledShader(GLenum(GL_FRAGMENT_SHADER), error:&error, withSourceStrings:[
            "varying highp vec4 fragColor;",
            "void main(void) {",
            "  gl_FragColor = fragColor;",
            "}"
          ])
        if (fragmentShader == 0) {
          NSLog("fragment shader compilation failed: \(error)")
        }

        // Create a program linking the two shaders.
        program = sender.context.createLinkedProgramWithShaders([NSNumber(unsignedInt:vertexShader), NSNumber(unsignedInt:fragmentShader)], error:&error)
        if (program == 0) {
          NSLog("program linking failed: \(error)");
        }

        // Get the location of our projection matrix uniform.
        projectionLoc = glGetUniformLocation(program, "projection");
      }


      func deleteStateForOpenGLView(sender: OpenGLView)
        {
          // Delete our program and shaders
          if program != 0 {
            glDeleteProgram(program)
            program = 0
          }
          if vertexShader != 0 {
            glDeleteShader(vertexShader);
            vertexShader = 0;
          }
          if fragmentShader != 0 {
            glDeleteShader(fragmentShader)
            fragmentShader = 0
          }
        }


      func drawOpenGLView(sender: OpenGLView)
        {
          let null = UnsafePointer<Void>(bitPattern:0);

          glUseProgram(program)

          // Upload the projection matrix
          let rect = self.projectionRect
          var P = Array(count:16, repeatedValue:GLfloat(0))
          ortho(&P, left: GLfloat(CGRectGetMinX(rect)), right: GLfloat(CGRectGetMaxX(rect)), bottom: GLfloat(CGRectGetMinY(rect)), top: GLfloat(CGRectGetMaxY(rect)), near: -1, far: 1)
          glUniformMatrix4fv(projectionLoc, 1, 0, P)

          // Draw the color wheel interior as a triangle fan (with per-vertex colors)...
          glBindBuffer(GLenum(GL_ARRAY_BUFFER), wheelVertexBuffer)
          if wheelChanged {
            updateWheelVertexBuffer()
          }
          glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), 0, GLsizei(sizeof(Vertex)), null)
          glVertexAttribPointer(1, 4, GLenum(GL_FLOAT), 0, GLsizei(sizeof(Vertex)), null.advancedBy(2*sizeof(GLfloat)))
          glEnableVertexAttribArray(1)
          glDrawArrays(GLenum(GL_TRIANGLE_FAN), 0, GLsizei(numberOfSlices + 2))
          glDisableVertexAttribArray(1)

          // and draw the perimeter as a line loop in the specified border color.
          if let color = borderColor {
            var r:GLfloat=0, g:GLfloat=0, b:GLfloat=0, a:GLfloat=0
            color.getGLRed(&r, green:&g, blue:&b, alpha:&a)
            glVertexAttrib4f(1, r, g, b, a)
            glDrawArrays(GLenum(GL_LINE_LOOP), 1, GLsizei(numberOfSlices))
          }

          // Draw the selected point as a white square (2-triangle strip)
          glBindBuffer(GLenum(GL_ARRAY_BUFFER), pointVertexBuffer)
          if pointChanged {
            updatePointVertexBuffer()
          }
          glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), 0, GLsizei(sizeof(GLfloat)*2), null)
          glVertexAttrib4f(1, 1.0, 1.0, 1.0, 1.0)
          glDrawArrays(GLenum(GL_TRIANGLE_STRIP), 0, 4)

          // Draw the selected point as a black line loop.
          glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), pointIndexBuffer)
          glVertexAttrib4f(1, 0.0, 0.0, 0.0, 1.0)
          glDrawElements(GLenum(GL_LINE_LOOP), 4, GLenum(GL_UNSIGNED_BYTE), null)
        }


      // UIControl

      override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool
        {
          self.processTouch(touch)
          return true
        }


      override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool
        {
          self.processTouch(touch)
          return true
        }

  }
