/*

    Created by David Spooner on 2/3/10.
    Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import "UIColor-GxGraphics.h"


@implementation UIColor(GxGraphics)

- (void) getRed:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b alpha:(CGFloat *)a
  {
    CGColorRef color = self.CGColor;

    const CGFloat *components = CGColorGetComponents(color);
    size_t n_components = CGColorGetNumberOfComponents(color);

    switch (CGColorSpaceGetModel(CGColorGetColorSpace(color))) {
      case kCGColorSpaceModelMonochrome :
        if (r) *r = components[0];
        if (g) *g = components[0];
        if (b) *b = components[0];
        if (a) *a = n_components > 1 ? components[1] : 1.0;
        break;
      case kCGColorSpaceModelRGB :
        if (r) *r = components[0];
        if (g) *g = components[1];
        if (b) *b = components[2];
        if (a) *a = n_components > 3 ? components[3] : 1.0;
        break;
      default :
        NSAssert(0, @"unhandled case");
    }
  }

@end
