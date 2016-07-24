/*

  Copyright © 2010-2016 David Spooner; see License.txt

  Utility functions

*/

import UIKit


// Create a 4x4 orthographic projection matrix with the given parameters.

func ortho(inout P: [GLfloat], left:GLfloat, right:GLfloat, bottom:GLfloat, top:GLfloat, near:GLfloat, far:GLfloat)
  {
    P[0*4+0] = 2 / (right - left);
    P[1*4+0] = 0;
    P[2*4+0] = 0;
    P[3*4+0] = -(right + left) / (right - left);
    P[0*4+1] = 0;
    P[1*4+1] = 2 / (top - bottom);
    P[2*4+1] = 0;
    P[3*4+1] = -(top + bottom) / (top - bottom);
    P[0*4+2] = 0;
    P[1*4+2] = 0;
    P[2*4+2] = -2 / (far - near);
    P[3*4+2] = -(far + near) / (far - near);
    P[0*4+3] = 0;
    P[1*4+3] = 0;
    P[2*4+3] = 0;
    P[3*4+3] = 1;
  }
