/*

  Copyright © 2010-2016 David Spooner; see License.txt

  A UIView subclass which draws a given color within its bounds.

*/

import UIKit


@IBDesignable
class ColorView : UIView
  {

    var fillColor: UIColor? { didSet { setNeedsDisplay() } }
    var borderColor: UIColor?  { didSet { setNeedsDisplay() } }
    var borderWidth: CGFloat = 1  { didSet { setNeedsDisplay() } }


    override func draw(_ dirtyRect: CGRect)
      {
        let bounds = self.bounds
        let context = UIGraphicsGetCurrentContext()

        if let color = fillColor {
          color.setFill()
          context?.fill(bounds)
        }

        if let color = borderColor {
          color.setStroke()
          context?.setLineWidth(borderWidth)
          context?.stroke(bounds)
        }
      }

  }
