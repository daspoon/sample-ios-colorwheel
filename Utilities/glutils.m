/*

  Created by David Spooner on 4/16/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import "glutils.h"


void setOrtho(GLfloat P[16], CGFloat left, CGFloat right, CGFloat bottom, CGFloat top, CGFloat near, CGFloat far)
  {
    P[0*4+0] = 2 / (right - left);
    P[1*4+0] = 0;
    P[2*4+0] = 0;
    P[3*4+0] = - (right + left) / (right - left);
    P[0*4+1] = 0;
    P[1*4+1] = 2 / (top - bottom);
    P[2*4+1] = 0;
    P[3*4+1] = - (top + bottom) / (top - bottom);
    P[0*4+2] = 0;
    P[1*4+2] = 0;
    P[2*4+2] = -2 / (far - near);
    P[3*4+2] = - (far + near) / (far - near);
    P[0*4+3] = 0;
    P[1*4+3] = 0;
    P[2*4+3] = 0;
    P[3*4+3] = 1;
  }


GLuint GxCreateCompiledShader(GLenum type, GLchar **error_p, const GLchar *string, ...)
  {
    va_list ap;

    GLuint n_strings = 0;
    va_start(ap, string);
    for (const GLchar *s = string; s != nil; s = va_arg(ap, const GLchar *))
      ++n_strings;
    va_end(ap);

    const GLchar **strings = (const GLchar **)malloc(n_strings * sizeof(const GLchar *));
    va_start(ap, string);
    GLuint i = 0;
    for (const GLchar *s = string; s != nil; s = va_arg(ap, const GLchar *))
      strings[i++] = s;
    va_end(ap);

    GLuint shader = glCreateShader(type);
    glShaderSource(shader, n_strings, strings, NULL);
    glCompileShader(shader);

    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
      if (error_p) {
        GLint length = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
        *error_p = (GLchar *)malloc(length+1);
        glGetShaderInfoLog(shader, length, NULL, *error_p);
      }
      glDeleteShader(shader);
      shader = 0;
    }

    free(strings);

    return shader;
  }


GLuint GxCreateLinkedProgram(GLchar **error_p, GLuint shader, ...)
  {
    GLuint program = glCreateProgram();

    va_list ap;
    va_start(ap, shader);
    for (GLuint s = shader; s != 0; s = va_arg(ap, GLuint))
      glAttachShader(program, s);
    va_end(ap);

    glLinkProgram(program);

    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
      if (error_p) {
        GLint length;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &length);
        *error_p = (GLchar *)malloc(length+1);
        glGetProgramInfoLog(program, length, NULL, *error_p);
      }
      glDeleteProgram(program);
      program = 0;
    }

    return program;
  }
