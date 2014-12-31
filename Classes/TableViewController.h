/*

  Created by David Spooner on 5/10/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

  The purpose of this view controller is simply to allow navigation to the color picker...

*/

#import "ColorPickerViewController.h"


@interface MyTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
  {
    GxColorPickerViewController *colorPickerViewController;
    NSMutableArray *colors;
    NSUInteger selectedRowIndex;
  }

@end
