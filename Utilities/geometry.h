/*

  Created by David Spooner on 10/12/09.
  Copyright 2009 Lambda Software Corporation. All rights reserved.

  Geometry-related utility functions.

*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
#import <CoreGraphics/CGGeometry.h>
#endif


inline static CGFloat GxRectAspectRatio(CGRect rect)
  { return CGRectGetWidth(rect)/CGRectGetHeight(rect); }


FOUNDATION_EXPORT CGRect GxFramedImageRect(CGRect inputRect, CGFloat outputAspectRatio, BOOL shrink=YES);
    // Return a rectangle with the specified aspect ratio derived from the given rectangle as follows:
    // if 'shrink' is YES then the result is the largest rectangle enclosed by inputRect; otherwise it
    // is the smallest rectangle enclosing inputRect.  In either case it is intended that the center
    // of the resulting rectangle is that of the given rectangle...

FOUNDATION_EXPORT CGRect GxInnerImageRect(CGRect frameRect, CGFloat aspectRatio);
    // Return the largest centered sub-rectangle of the given rectangle which has the
    // specified aspect ratio (viz. width/height).  This function is useful for sizing an
    // image to fit a given frame.

FOUNDATION_EXPORT CGRect GxOuterImageRect(CGRect innerRect, CGFloat aspectRatio);
    // Return the smallest rectangle which encloses the given rectangle and has the
    // specified aspect ratio (viz. width/height).  This function is useful for choosing
    // a view frame size for a given image.


FOUNDATION_EXPORT CGRect GxSliceCGRect(CGRect *rect, CGFloat amount, CGRectEdge edge);
    // A convenience build on CGRectDivide: the given rectangle is used as source and is updated
    // to reflect the remainder; the 'slice' rectangle is returned.


UIKIT_EXTERN CGRect GxOrientPortraitRect(CGRect rect, UIInterfaceOrientation orientation);
    // If the speciied orientation is not portrait then exchange the x and y coordinates of
    // the given rectangle; otherwise return the given rectangle unchanged.
