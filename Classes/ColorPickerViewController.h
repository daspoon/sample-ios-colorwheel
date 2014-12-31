/*

  Created by David Spooner on 4/28/10.
  Copyright Lambda Software Corporation 2010. All rights reserved.

  A ColorPickerViewController provides an interface for selecting a color through
  the combination of a color wheel and brightness slider.

*/

#import "ColorWheelView.h"

@class GxColorView;


@interface GxColorPickerViewController : UIViewController <GxColorWheelViewDelegate>
  {
    GxColorView       *colorView;
    GxColorWheelView  *wheelView;
    UISlider          *sliderView;
    CGSize             borderSize;
    CGFloat            colorHeight;
    CGFloat            sliderHeight;
    UIColor           *selectedColor;
  }


@property (nonatomic, retain) UIColor *selectedColor;
    // The color displayed/chosen in the interface.

@property (nonatomic) CGSize borderSize;
    // Defines the margin between the receiver's content view and its component subviews.

@property (nonatomic) CGFloat colorHeight;
    // Defines the height of the upper view which presents the selected color.

@property (nonatomic) CGFloat sliderHeight;
    // Defines the height of the lower slider view which presents the brightness of
    // the selected color.

@end

