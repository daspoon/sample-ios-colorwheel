/*

  Created by David Spooner on 4/28/10.
  Copyright Lambda Software Corporation 2010. All rights reserved.

*/

#import "ColorPickerViewController.h"
#import "ColorWheelView.h"
#import "ColorView.h"
#import "UINavigationController-GxTouchKit.h"
#import "geometry.h"


@implementation GxColorPickerViewController

@synthesize selectedColor, borderSize, colorHeight, sliderHeight;


- (id) initWithNibName:(NSString *)aName bundle:(NSBundle *)aBundle
  {
    if ((self = [super initWithNibName:aName bundle:aBundle]) == nil)
      return nil;

    borderSize = CGSizeMake(8, 8);
    colorHeight = 40;
    sliderHeight = 32;

    return self;
  }


- (id) init
  { return [self initWithNibName:nil bundle:nil]; }


- (void) selectedColorDidChange
  {
    // Convert our selectedColor to a point on the unit circle and a brightness, and our
    // component views accordingly...

    CGPoint point;
    CGFloat brightness;
    if (selectedColor != nil)
      [GxColorWheelView getPoint:&point andBrighness:&brightness forColor:selectedColor];
    else {
      point = CGPointMake(0, 0);
      brightness = 0;
    }

    wheelView.selectedPoint = point;
    wheelView.brightness = brightness;

    colorView.fillColor = selectedColor;

    sliderView.value = brightness;
  }


- (void) setSelectedColor:(UIColor *)aColor
  {
    [aColor retain];
    [selectedColor release];
    selectedColor = aColor;

    [self selectedColorDidChange];
  }


#pragma mark GxColorWheelViewDelegate

- (void) colorWheelSelectionDidChange:(GxColorWheelView *)sender
  {
    // Update our selected color in response to selection in the color wheel view.
    self.selectedColor = sender.selectedColor;
  }


#pragma mark Actions

- (void) sliderDidChange:(UISlider *)sender
  {
    // Update the wheel's brightness and then update our selectedColor accordingly.
    wheelView.brightness = sender.value;

    [self colorWheelSelectionDidChange:wheelView];
  }


#pragma mark UIViewController

- (void) loadView
  {
    // Calculate the frames of each of our subviews based on the bounds of the screen:
    //  - first inset the screen rect by the desired border;
    //  - then slice off portions at top and bottom for the color and slider views;
    //  - then inset the remainder by the border height to frame the wheel view.
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect   tempRect = CGRectInset(screenRect, borderSize.width, borderSize.height);
    CGRect  colorRect = GxSliceCGRect(&tempRect, colorHeight, CGRectMinYEdge);
    CGRect sliderRect = GxSliceCGRect(&tempRect, sliderHeight, CGRectMaxYEdge);
    CGRect  wheelRect = CGRectInset(tempRect, 0, borderSize.height);

    // Build the view hierarchy; the retained references to each subview will be released
    // in -viewDidUnload.
    UIView *contentView = [[UIView alloc] initWithFrame:screenRect];
    [contentView addSubview:(colorView = [[GxColorView alloc] initWithFrame:colorRect])];
    [contentView addSubview:(wheelView = [[GxColorWheelView alloc] initWithFrame:wheelRect/* context:[[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1] autorelease]*/])];
    [contentView addSubview:(sliderView = [[UISlider alloc] initWithFrame:sliderRect])];
    self.view = contentView;
    [contentView release];

    // Set the autoresizing mask for each view appropriately to preserve the layout.
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    colorView.autoresizingMask   = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    wheelView.autoresizingMask   = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    sliderView.autoresizingMask  = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
  }


- (void) viewDidLoad
  {
    [super viewDidLoad];

    // Set the background color of the content view arbitrarily, and set the background color of
    // the wheel view to be transparent (so that our view's background color shows through).
    self.view.backgroundColor = [UIColor blackColor];
    wheelView.backgroundColor = [UIColor clearColor];

    // Register to observe changes to the brightness slider
    [sliderView addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];

    // Register to observe changes to the color wheel selection
    wheelView.delegate = self;

    // Update our subviews to match our selectedColor
    [self selectedColorDidChange];
  }


- (void) viewDidUnload
  {
    [super viewDidUnload];

    [sliderView removeTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];

    wheelView.delegate = nil;

    [wheelView release];  wheelView = nil;
    [colorView release];  colorView = nil;
    [sliderView release]; sliderView = nil;
  }


- (void) viewWillAppear:(BOOL)animated
  {
    [super viewWillAppear:animated];

    // Set the frame of our content view according to the available space...
    UINavigationController *navigationController = self.navigationController;
    self.view.frame = navigationController ? [navigationController contentRect] : [UIScreen mainScreen].applicationFrame;
  }


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
  { return YES; }

@end
