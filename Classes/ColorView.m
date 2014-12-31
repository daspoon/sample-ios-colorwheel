/*

  Created by David Spooner on 5/7/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import "ColorView.h"


@implementation GxColorView

@synthesize fillColor, borderColor, borderWidth;


- (id) initWithFrame:(CGRect)aRect
  {
    if ((self = [super initWithFrame:aRect]) == nil)
      return nil;

    borderWidth = 1.0;

    return self;
  }


- (void) dealloc
  {
    [fillColor release];
    [borderColor release];
    [super dealloc];
  }


- (void) drawRect:(CGRect)aRect
  {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect      rect = self.bounds;

    // Fill our bounds rectangle with the fill color, if specified
    if (fillColor) {
      [fillColor setFill];
      CGContextFillRect(ctx, CGRectInset(rect, borderWidth, borderWidth));
    }

    // Stroke our bounds rectangle with the border color, if specified.
    if (borderColor) {
      [borderColor setStroke];
      CGContextSetLineWidth(ctx, borderWidth);
      CGContextStrokeRect(ctx, rect);
    }
  }


- (void) setFillColor:(UIColor *)aColor
  {
    [aColor retain];
    [fillColor release];
    fillColor = aColor;

    [self setNeedsDisplay];
  }


- (void) setBorderColor:(UIColor *)aColor
  {
    [aColor retain];
    [borderColor release];
    borderColor = aColor;

    [self setNeedsDisplay];
  }

@end
