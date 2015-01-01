/*

  Created by David Spooner

*/

import UIKit


@UIApplicationMain


class ColorWheelAppDelegate : UIResponder, UIApplicationDelegate
  {

    var window: UIWindow?


    func application(sender: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
      {
        window = sender.keyWindow

        var navigationController = UINavigationController(rootViewController: ColorWheelTableViewController())
        navigationController.navigationBar.translucent = false
        
        window!.rootViewController = navigationController
        window!.makeKeyWindow()

        return true
      }

  }
