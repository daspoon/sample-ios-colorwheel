/*

  Created by David Spooner

*/

import CoreGraphics


extension CGRect
  {

    var aspectRatio: CGFloat
      { return CGRectGetWidth(self)/CGRectGetHeight(self); }


    static func withReferenceRect(rect: CGRect, aspectRatio: CGFloat, shrink: Bool) -> CGRect
      {
        assert(aspectRatio > 0, "invalid argument")

        if (aspectRatio >= rect.aspectRatio) == shrink {
          let size = CGSizeMake(CGRectGetWidth(rect), CGRectGetWidth(rect) / aspectRatio)
          let origin = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + 0.5 * (CGRectGetHeight(rect) - size.height))
          return CGRect(origin:origin, size:size)
        }
        else {
          let size = CGSizeMake(CGRectGetHeight(rect) * aspectRatio, CGRectGetHeight(rect))
          let origin = CGPointMake(CGRectGetMinX(rect) + 0.5 * (CGRectGetWidth(rect) - size.width), CGRectGetMinY(rect))
          return CGRect(origin:origin, size:size)
        }
      }


    static func withEnclosingRect(rect: CGRect, aspectRatio ratio: CGFloat) -> CGRect
      {
        // The largest centered sub-rectangle of the given rectangle which has the specified aspect ratio (viz. width/height).  This function is useful for sizing an image to fit a given view frame.
        return self.withReferenceRect(rect, aspectRatio:ratio, shrink:true)
      }


    static func withIncsribedRect(rect: CGRect, aspectRatio ratio: CGFloat) -> CGRect
      {
        // The smallest rectangle enclosing the given rectangle and having the given aspect ratio (viz. width/height).  This function is useful for choosing a view frame size for a given image.
        return self.withReferenceRect(rect, aspectRatio:ratio, shrink:false)
      }

  }
