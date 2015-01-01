/*

  Created by David Spooner

*/

import UIKit


class GxColorPickerViewController : UIViewController
  {

    @IBOutlet var colorView: GxColorView!
    @IBOutlet var wheelView: GxColorWheelView!
    @IBOutlet var sliderView: UISlider!

    var point: CGPoint = CGPoint(x:0, y:0)
    var brightness: CGFloat = 0
    var alpha: CGFloat = 1


    override convenience init()
      {
        self.init(nibName:"ColorPickerViewController", bundle:nil)
      }


    class func keyPathsForValuesAffectingSelectedColor() -> NSSet
      {
        return NSSet(array:["point", "brightness", "alpha"])
      }


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

          if self.isViewLoaded() {
            self.selectedColorDidChange()
          }
        }
      }


    func selectedColorDidChange()
      {
        var v = self.view

        wheelView.selectedPoint = point
        wheelView.brightness = brightness

        colorView.fillColor = selectedColor

        sliderView.value = Float(brightness)
      }


    @IBAction func colorWheelSelectionDidChange(sender: GxColorWheelView)
      {
        self.point = sender.selectedPoint
        self.selectedColorDidChange()
      }


    @IBAction func sliderDidChange(sender: UISlider)
      {
        self.brightness = CGFloat(sender.value)
        self.selectedColorDidChange()
      }


    // UIViewController

    override func viewDidLoad()
      {
        assert(colorView != nil && wheelView != nil && sliderView != nil, "unconnected outlets")

        super.viewDidLoad()

        self.selectedColorDidChange()
      }

  }
