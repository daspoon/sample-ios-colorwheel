/*

  Created by David Spooner on 4/28/10.
  Copyright Lambda Software Corporation 2010. All rights reserved.

*/

#import "AppDelegate.h"
#import "TableViewController.h"
#import "ColorPickerViewController.h"

#define SHOW_NAVIGATION YES

  
@implementation ColorWheelAppDelegate

@synthesize window;


- (void) dealloc
  {
    [navigationController release];
    [window release];
    [super dealloc];
  }


#pragma mark UIApplicationDelegate

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
  {
    // Create a navigation controller with a table view controller as its root...
    UITableViewController *tableViewController = [[[MyTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    navigationController.toolbarHidden = NO;

    [window addSubview:navigationController.view];
    [window makeKeyWindow];

    return YES;
  }

@end
