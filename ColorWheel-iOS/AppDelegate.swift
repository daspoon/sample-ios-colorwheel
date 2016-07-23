/*

  Created by David Spooner

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
