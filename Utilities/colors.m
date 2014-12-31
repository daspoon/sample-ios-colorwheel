/*

  Created by David Spooner on 10/12/09.
  Copyright 2009 Lambda Software Corporation. All rights reserved.

*/

#import "colors.h"


void GxConvertRGBToHSB(float r, float g, float b, float &h, float &s, float &v)
  {
  // Adapted from "3D Computer Graphics", by Alan Watt, second edition pp. 418-419
    float min  = fminf(r, fminf(g, b));
    float max  = fmaxf(r, fmaxf(g, b));
    float diff = max - min;

    v = max;
    s = max != 0 ? diff / max : 0;

    if (s == 0)
      h = NAN;
    else {
      float r_dist = (max - r) / diff;
      float g_dist = (max - g) / diff;
      float b_dist = (max - b) / diff;
      if (r == max)
        h = b_dist - g_dist;
      else if (g == max)
        h = 2 + r_dist - b_dist;
      else // if (b == max)
        h = 4 + g_dist - r_dist;
      h *= 60;
      if (h < 0)
        h += 360;
      h /= 360;
    }
  }


void GxConvertHSBToRGB(float h, float s, float v, float &r, float &g, float &b)
  {
  // Adapted from "3D Computer Graphics", by Alan Watt, second edition pp. 418-419
    if (s == 0)
      r = g = b = v;
    else {
      if (h == 1) h = 0;
      h = h * 360 / 60;
      int i = floor(h);
      float f = h - i;
      float p = v * (1 - s);
      float q = v * (1 - (s * f));
      float t = v * (1 - (s * (1 - f)));
      switch (i) {
        case 0 : r = v; g = t; b = p; break;
        case 1 : r = q; g = v; b = p; break;
        case 2 : r = p; g = v; b = t; break;
        case 3 : r = p; g = q; b = v; break;
        case 4 : r = t; g = p; b = v; break;
        case 5 : r = v; g = p; b = q; break;
      }
    }
  }
