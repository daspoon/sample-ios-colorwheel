/*

  Copyright © 2010-2016 David Spooner; see License.txt

*/

import UIKit


@UIApplicationMain


class ColorWheelAppDelegate : UIResponder, UIApplicationDelegate
  {

    @IBOutlet var window: UIWindow?


    func application(_ sender: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
      {
        let navigationController = UINavigationController(rootViewController: ColorWheelTableViewController())
        navigationController.navigationBar.isTranslucent = false
        
        window?.rootViewController = navigationController
        window?.makeKey()

        return true
      }

  }
