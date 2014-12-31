/*

  Created by David Spooner on 10/12/09.
  Copyright 2009 Lambda Software Corporation. All rights reserved.

  Utility functions for converting between RGB and HSV color spaces.  Note that
  all color components (including hue) are expected to be in the range [0..1].

*/

#import <Foundation/Foundation.h>


void GxConvertRGBToHSB(float r, float g, float b, float &h, float &s, float &v);

void GxConvertHSBToRGB(float h, float s, float v, float &r, float &g, float &b);

