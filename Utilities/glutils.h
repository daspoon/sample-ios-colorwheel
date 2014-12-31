/*

  Created by David Spooner on 4/16/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

  OpenGL-related utility functions.

*/

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>


GLuint GxCreateCompiledShader(GLenum type, GLchar **error_p, const GLchar *string, ...) NS_REQUIRES_NIL_TERMINATION;
    // Create and compile a shader of the given type (viz. GL_FRAGMENT_SHADER or GL_VERTEX_SHADER)
    // from the given NULL-terminated list of source strings.  If a compilation error occurs then 0
    // is returned and error_p is set the generated message and be freed by the caller.  The caller
    // is responsible for deleting the returned shader (via glDeleteShader).

GLuint GxCreateLinkedProgram(GLchar **error_p, GLuint shader, ...) NS_REQUIRES_NIL_TERMINATION;
    // Create and link a program from the given NULL-terminated list of shaders.  If a link error
    // occurs then error_p s set to the generated message and must be freed by the caller.  The
    // caller is responsible for deleting the returned program (via. glDeleteProgram).


void setOrtho(GLfloat P[16], CGFloat left, CGFloat right, CGFloat bottom, CGFloat top, CGFloat near, CGFloat far);
    // Calculate a projection matrix for an orthographic projection with the given bounds.


// The following are a convenience for using vertex arrays across GLES versions 1 and 2

inline static GLenum arrayFromIndex(GLuint index) {
    GLenum array[] = {GL_VERTEX_ARRAY, GL_COLOR_ARRAY};
    NSCAssert(index < sizeof(array)/sizeof(*array), @"invalid index");
    return array[index];
  }

inline static void enableVertexAttribArray(EAGLRenderingAPI API, GLuint index) {
    switch (API) {
      case kEAGLRenderingAPIOpenGLES1 : glEnableClientState(arrayFromIndex(index)); break;
      case kEAGLRenderingAPIOpenGLES2 : glEnableVertexAttribArray(index);           break;
    }
  }

inline static void disableVertexAttribArray(EAGLRenderingAPI API, GLuint index) {
    switch (API) {
      case kEAGLRenderingAPIOpenGLES1 : glDisableClientState(arrayFromIndex(index)); break;
      case kEAGLRenderingAPIOpenGLES2 : glDisableVertexAttribArray(index);           break;
    }
  }

inline static void vertexAttribPointer(EAGLRenderingAPI API, GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid *ptr) {
    switch (API) {
      case kEAGLRenderingAPIOpenGLES1 :
        switch (arrayFromIndex(index)) {
          case GL_VERTEX_ARRAY : glVertexPointer(size, type, stride, ptr); break;
          case GL_COLOR_ARRAY  : glColorPointer(size, type, stride, ptr);  break;
          default :
            NSCAssert(0, @"unhandled case");
        }
        break;
      case kEAGLRenderingAPIOpenGLES2 :
        glVertexAttribPointer(index, size, type, normalized, stride, ptr);
        break;
    }
  }

inline static void vertexAttrib4f(EAGLRenderingAPI API, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {
    switch (API) {
      case kEAGLRenderingAPIOpenGLES1 :
        switch (arrayFromIndex(index)) {
          case GL_COLOR_ARRAY : glColor4f(x, y, z, w); break;
          default :
            NSCAssert(0, @"unhandled case");
        }
        break;
      case kEAGLRenderingAPIOpenGLES2 :
        glVertexAttrib4f(index, x, y, z, w);
        break;
    }
  }

