/*

  Copyright © 2010-2016 David Spooner; see License.txt

  Utility method added to EAGLContext.

*/

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>


@interface EAGLContext(GxCoreUI)

- (GLuint) createCompiledShader:(GLenum)type error:(NSString **)error_p withSourceStrings:(NSArray *)source;
    // Create and compile a shader of the given type (viz. GL_FRAGMENT_SHADER or GL_VERTEX_SHADER)
    // from the given NULL-terminated list of source strings.  If a compilation error occurs then 0
    // is returned and error_p is set the generated message and be freed by the caller.  The caller
    // is responsible for deleting the returned shader (via glDeleteShader).


- (GLuint) createLinkedProgramWithShaders:(NSArray *)shaders error:(NSString **)error_p;
    // Create and link a program from the given NULL-terminated list of shaders.  If a link error
    // occurs then error_p s set to the generated message and must be freed by the caller.  The
    // caller is responsible for deleting the returned program (via. glDeleteProgram).

@end
