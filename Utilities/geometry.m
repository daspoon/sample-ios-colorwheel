/*

  Created by David Spooner on 11/19/09.
  Copyright 2009 Lambda Software Corporation. All rights reserved.

*/

#import "geometry.h"


CGRect GxFramedImageRect(CGRect inputRect, CGFloat outputAspectRatio, BOOL shrink)
  {
    CGRect outputRect;

    if (outputAspectRatio <= 0)
      return inputRect;

    if ((outputAspectRatio >= GxRectAspectRatio(inputRect)?1:0) == (shrink?1:0)) {
      outputRect.size.width  = inputRect.size.width;
      outputRect.size.height = inputRect.size.width / outputAspectRatio;
      outputRect.origin.x    = inputRect.origin.x;
      outputRect.origin.y    = inputRect.origin.y + 0.5 * (inputRect.size.height - outputRect.size.height);
    }
    else {
      outputRect.size.height = inputRect.size.height;
      outputRect.size.width  = inputRect.size.height * outputAspectRatio;
      outputRect.origin.y    = inputRect.origin.y;
      outputRect.origin.x    = inputRect.origin.x + 0.5 * (inputRect.size.width - outputRect.size.width);
    }

    NSCAssert(CGRectContainsRect((shrink?inputRect:outputRect), (shrink?outputRect:inputRect)), @"oops");

    return outputRect;
  }


CGRect GxInnerImageRect(CGRect outerRect, CGFloat aspectRatio)
  { return GxFramedImageRect(outerRect, aspectRatio, YES); }


CGRect GxOuterImageRect(CGRect innerRect, CGFloat aspectRatio)
  { return GxFramedImageRect(innerRect, aspectRatio, NO); }


CGRect GxSliceCGRect(CGRect *rect, CGFloat amount, CGRectEdge edge)
  {
    NSCAssert(rect != NULL, @"invalid argument");
    CGRect slice, remainder;
    CGRectDivide(*rect, &slice, &remainder, amount, edge);
    *rect = remainder;
    return slice;
  }


CGRect GxOrientPortraitRect(CGRect rect, UIInterfaceOrientation orientation)
  {
    if (UIInterfaceOrientationIsPortrait(orientation) == NO) {
      CGFloat t;
      t = rect.origin.x; rect.origin.x = rect.origin.y; rect.origin.y = t;
      t = rect.size.width; rect.size.height = rect.size.width; rect.size.height = t;
    }
    return rect;
  }
