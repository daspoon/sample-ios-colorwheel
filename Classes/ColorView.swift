/*

  Created by David Spooner

  A UIView subclass which draws a given color within its bounds.

*/

import UIKit


@IBDesignable
class GxColorView : UIView
  {

    var fillColor: UIColor? { didSet { setNeedsDisplay() } }
    var borderColor: UIColor?  { didSet { setNeedsDisplay() } }
    var borderWidth: CGFloat = 1  { didSet { setNeedsDisplay() } }


    override func drawRect(dirtyRect: CGRect)
      {
        let bounds = self.bounds
        var context = UIGraphicsGetCurrentContext()

        if let color = fillColor {
          color.setFill()
          CGContextFillRect(context, bounds)
        }

        if let color = borderColor {
          color.setStroke()
          CGContextSetLineWidth(context, borderWidth)
          CGContextStrokeRect(context, bounds)
        }
      }

  }
