/*

  Copyright © 2010-2016 David Spooner; see License.txt

  A subclass of UIViewController which enableds editing a UIColor within a color wheel view.

*/

import UIKit


class ColorPickerViewController : UIViewController
  {

    dynamic var point: CGPoint = CGPoint(x:0, y:0)
      // A point within the unit circle defining the hue and saturation of the selected color.

    dynamic var brightness: CGFloat = 0
      // A value in [0..1] defining the selected color's brightness.

    dynamic var alpha: CGFloat = 1
      // The selected color's transparency.


    @IBOutlet var colorView: ColorView!
    @IBOutlet var wheelView: ColorWheel!
    @IBOutlet var sliderView: UISlider!


    init()
      {
        super.init(nibName:"ColorPickerViewController", bundle:nil)
      }


    class func keyPathsForValuesAffectingSelectedColor() -> Set<String>
      { return ["point", "brightness", "alpha"] }

    var selectedColor: UIColor
      {
        get {
          let h = (CGFloat(M_PI) + atan2(-point.y, -point.x)) / (2 * CGFloat(M_PI));
          let s = sqrt(point.x*point.x + point.y*point.y);

          return UIColor(hue:h, saturation:s, brightness:brightness, alpha:alpha)
        }

        set(color) {
          var h:CGFloat=0, s:CGFloat=0, v:CGFloat=0
          color.getHue(&h, saturation:&s, brightness:&v, alpha:&alpha)
          if s == 0 {
            point = CGPoint(x:0, y:0)
          }
          else {
            let a = h * 2 * CGFloat(M_PI)
            point.x = cos(a) * s
            point.y = sin(a) * s
          }
          brightness = v

          selectedColorDidChange()
        }
      }


    func selectedColorDidChange()
      {
        // Invoked whenever our selected color changes. Update the UI if loaded.

        guard isViewLoaded else { return }

        wheelView.selectedPoint = point
        wheelView.brightness = brightness

        colorView.fillColor = selectedColor

        sliderView.value = Float(brightness)
      }


    @IBAction func colorWheelSelectionDidChange(_ sender: ColorWheel)
      {
        // Invoked in response to changing the selected point within the color wheel view.

        point = sender.selectedPoint

        selectedColorDidChange()
      }


    @IBAction func sliderDidChange(_ sender: UISlider)
      {
        // Invoked in response to changing the value of the brightness slider.

        brightness = CGFloat(sender.value)

        selectedColorDidChange()
      }


    @IBAction func alphaSliderDidChange(_ sender: UISlider)
      {
        // Invoked in response to change the value of the alpha slider.

        alpha = CGFloat(sender.value)

        selectedColorDidChange()
      }


    // UIViewController

    override func viewDidLoad()
      {
        assert(colorView != nil && wheelView != nil && sliderView != nil, "unconnected outlets")

        super.viewDidLoad()

        // Update the UI to reflect the current color selection.
        selectedColorDidChange()
      }


    // MARK: - NSCoder

    required init?(coder: NSCoder)
      {
        super.init(coder:coder)
      }

  }
