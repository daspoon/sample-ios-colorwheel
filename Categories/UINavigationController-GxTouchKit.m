/*

  Created by David Spooner.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import "UINavigationController-GxTouchKit.h"
#import "geometry.h"


@implementation UINavigationController(GxTouchKit)

- (CGRect) contentRect
  {
    UIApplication         *application = [UIApplication sharedApplication];
    UIInterfaceOrientation orientation = application.statusBarOrientation;

    // Start with the screen bounds in the current device orientation.
    CGRect contentRect = GxOrientPortraitRect([UIScreen mainScreen].bounds, orientation);

    // Subtract the area occupied by the status bar, if visible
    if (application.statusBarHidden == NO)
      GxSliceCGRect(&contentRect, CGRectGetHeight(GxOrientPortraitRect(application.statusBarFrame, orientation)), CGRectMinYEdge);

    // Subtract the area occupied by our navigation bar, if visible...
    if (self.navigationBarHidden == NO)
      GxSliceCGRect(&contentRect, CGRectGetHeight(self.navigationBar.bounds), CGRectMinYEdge);

    // Subtract the area occupied by our toolbar, if visible...
    if (self.toolbarHidden == NO)
      GxSliceCGRect(&contentRect, CGRectGetHeight(self.toolbar.bounds), CGRectMaxYEdge);

    return contentRect;
  }

@end

