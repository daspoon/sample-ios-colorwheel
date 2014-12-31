/*

  Created by David Spooner on 5/7/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

  A ColorView is a simple view which draws a given color within its bounds.

*/

#import <UIKit/UIKit.h>


@interface GxColorView : UIView
  {
    UIColor *fillColor;
    UIColor *borderColor;
    CGFloat borderWidth;
  }

@property (nonatomic, retain) UIColor *fillColor;
    // The color used to fill the view's bounds.  The default is nil, indicating that
    // no fill is performed.

@property (nonatomic, retain) UIColor *borderColor;
    // The color used to outline the view's bounds.  The default is nil, indicating 
    // that no border is drawn.

@property (nonatomic) CGFloat borderWidth;
    // The width of the border.  The default is 1.

@end

