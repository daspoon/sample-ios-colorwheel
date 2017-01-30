/*

  Copyright © 2010-2016 David Spooner; see License.txt

  Utility methods added to CGRect.

*/

import CoreGraphics


public extension CGRect
  {

    public var aspectRatio: CGFloat
      { return self.width/self.height; }


    fileprivate static func withReferenceRect(_ rect: CGRect, aspectRatio: CGFloat, shrink: Bool) -> CGRect
      {
        assert(aspectRatio > 0, "invalid argument")

        if (aspectRatio >= rect.aspectRatio) == shrink {
          let size = CGSize(width: rect.width, height: rect.width / aspectRatio)
          let origin = CGPoint(x: rect.minX, y: rect.minY + 0.5 * (rect.height - size.height))
          return CGRect(origin:origin, size:size)
        }
        else {
          let size = CGSize(width: rect.height * aspectRatio, height: rect.height)
          let origin = CGPoint(x: rect.minX + 0.5 * (rect.width - size.width), y: rect.minY)
          return CGRect(origin:origin, size:size)
        }
      }


    public static func withEnclosingRect(_ rect: CGRect, aspectRatio ratio: CGFloat) -> CGRect
      {
        // Return the receiver's largest centered sub-rectangle having the specified aspect ratio (viz. width/height).  This function is useful for sizing an image to fit a given view frame.

        return self.withReferenceRect(rect, aspectRatio:ratio, shrink:true)
      }


    public static func withIncsribedRect(_ rect: CGRect, aspectRatio ratio: CGFloat) -> CGRect
      {
        // The smallest rectangle enclosing the receiver and having the given aspect ratio (viz. width/height).  This function is useful for choosing a view frame size for a given image.

        return self.withReferenceRect(rect, aspectRatio:ratio, shrink:false)
      }

  }
