/*

  Copyright © 2010-2016 David Spooner; see License.txt

  Utility methods added to CGRect.

*/

import CoreGraphics


public extension CGRect
  {

    public var aspectRatio: CGFloat
      { return CGRectGetWidth(self)/CGRectGetHeight(self); }


    private static func withReferenceRect(rect: CGRect, aspectRatio: CGFloat, shrink: Bool) -> CGRect
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


    public static func withEnclosingRect(rect: CGRect, aspectRatio ratio: CGFloat) -> CGRect
      {
        // Return the receiver's largest centered sub-rectangle having the specified aspect ratio (viz. width/height).  This function is useful for sizing an image to fit a given view frame.

        return self.withReferenceRect(rect, aspectRatio:ratio, shrink:true)
      }


    public static func withIncsribedRect(rect: CGRect, aspectRatio ratio: CGFloat) -> CGRect
      {
        // The smallest rectangle enclosing the receiver and having the given aspect ratio (viz. width/height).  This function is useful for choosing a view frame size for a given image.

        return self.withReferenceRect(rect, aspectRatio:ratio, shrink:false)
      }

  }
