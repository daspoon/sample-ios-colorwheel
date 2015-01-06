/*

  Created by David Spooner

*/

#import "EAGLContext-GxCoreUI.h"


@implementation EAGLContext(GxCoreUI)

- (GLuint) createCompiledShader:(GLenum)type error:(NSString **)error_p withSourceStrings:(NSArray *)source
  {
    GLuint n_strings = [source count];
    const GLchar **strings = (const GLchar **)malloc(n_strings * sizeof(const GLchar *));
    for (GLuint i = 0; i < n_strings; ++i) {
      strings[i] = [source[i] UTF8String];
    }

    GLuint shader = glCreateShader(type);
    glShaderSource(shader, n_strings, strings, NULL);
    glCompileShader(shader);

    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
      if (error_p) {
        GLint length = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
        NSMutableData *data = [NSMutableData dataWithLength:(length+1)];
        glGetShaderInfoLog(shader, length, NULL, (GLchar *)data.mutableBytes);
        *error_p = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      }
      glDeleteShader(shader);
      shader = 0;
    }

    free(strings);

    return shader;
  }


- (GLuint) createLinkedProgramWithShaders:(NSArray *)shaders error:(NSString **)error_p
  {
    GLuint program = glCreateProgram();

    [shaders enumerateObjectsUsingBlock:
        ^(NSNumber *shader, NSUInteger index, BOOL *stop) {
            glAttachShader(program, shader.integerValue);
        }];

    glLinkProgram(program);

    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
      if (error_p) {
        GLint length;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
        NSMutableData *data = [NSMutableData dataWithLength:(length+1)];
        glGetProgramInfoLog(program, length, NULL, (GLchar *)data.mutableBytes);
        *error_p = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      }
      glDeleteProgram(program);
      program = 0;
    }

    return program;
  }

@end
