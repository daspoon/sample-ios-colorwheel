/*

  Copyright © 2010-2016 David Spooner; see License.txt

*/

import UIKit


@UIApplicationMain


class ColorWheelAppDelegate : UIResponder, UIApplicationDelegate
  {

    @IBOutlet var window: UIWindow?


    func application(sender: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
      {
        let navigationController = UINavigationController(rootViewController: ColorWheelTableViewController())
        navigationController.navigationBar.translucent = false
        
        window?.rootViewController = navigationController
        window?.makeKeyWindow()

        return true
      }

  }
