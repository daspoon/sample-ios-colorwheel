/*

  Copyright © 2010-2016 David Spooner; see License.txt

  Utility method added to UIColor.

*/

import UIKit


public extension UIColor
  {

    public func getGL(red r: inout GLfloat, green g: inout GLfloat, blue b: inout GLfloat, alpha a: inout GLfloat)
      {
        var r2:CGFloat=0, g2:CGFloat=0, b2:CGFloat=0, a2:CGFloat=0
        self.getRed(&r2, green:&g2, blue:&b2, alpha:&a2)
        r = GLfloat(r2)
        g = GLfloat(g2)
        b = GLfloat(b2)
        a = GLfloat(a2)
      }

  }
