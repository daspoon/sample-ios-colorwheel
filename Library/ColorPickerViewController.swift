/*

  Copyright © 2010-2016 David Spooner; see License.txt

  A subclass of UIViewController which enableds editing a UIColor within a color wheel view.

*/

import UIKit


class ColorPickerViewController : UIViewController
  {

    @IBOutlet var colorView: ColorView!
    @IBOutlet var wheelView: ColorWheel!
    @IBOutlet var sliderView: UISlider!

    var point: CGPoint = CGPoint(x:0, y:0)
    var brightness: CGFloat = 0
    var alpha: CGFloat = 1


    init()
      {
        super.init(nibName:"ColorPickerViewController", bundle:nil)
      }


    required init?(coder: NSCoder)
      {
        super.init(coder:coder)
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
        let _ = self.view

        wheelView.selectedPoint = point
        wheelView.brightness = brightness

        colorView.fillColor = selectedColor

        sliderView.value = Float(brightness)
      }


    @IBAction func colorWheelSelectionDidChange(sender: ColorWheel)
      {
        self.willChangeValueForKey("selectedColor")
        self.point = sender.selectedPoint
        self.didChangeValueForKey("selectedColor")

        self.selectedColorDidChange()
      }


    @IBAction func sliderDidChange(sender: UISlider)
      {
        self.willChangeValueForKey("selectedColor")
        self.brightness = CGFloat(sender.value)
        self.didChangeValueForKey("selectedColor")

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
