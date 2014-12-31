/*

  Created by David Spooner on 4/14/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import "utilities.h"


CGRect GxOrientPortraitRect(CGRect rect, UIInterfaceOrientation orientation)
  {
    if (UIInterfaceOrientationIsPortrait(orientation) == NO) {
      CGFloat t;
      t = rect.origin.x; rect.origin.x = rect.origin.y; rect.origin.y = t;
      t = rect.size.width; rect.size.height = rect.size.width; rect.size.height = t;
    }
    return rect;
  }

