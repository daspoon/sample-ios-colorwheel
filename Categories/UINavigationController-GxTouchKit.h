/*

  Created by David Spooner.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import <UIKit/UIKit.h>


@interface UINavigationController(GxTouchKit)

- (CGRect) contentRect;
    // Return the portion of the screen minus the visible navigation controls -- i.e. the status bar,
    // the navigation bar, and the toolbar.

@end

