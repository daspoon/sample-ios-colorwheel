/*

  Created by David Spooner

  A UITableViewController subclass to present a list of colors for inspection by GxColorPickerViewController.

*/

import UIKit


class ColorWheelTableViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate
  {

    var colorPickerViewController: GxColorPickerViewController?
    var colors: [UIColor] = []
    var selectedRow: NSInteger = 0


    convenience init()
      {
        self.init(style: UITableViewStyle.Plain)

        colors = [ UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor() ]

        colorPickerViewController = GxColorPickerViewController()
        colorPickerViewController!.addObserver(self, forKeyPath:"selectedColor", options:NSKeyValueObservingOptions.allZeros, context:nil)

        self.title = "Colors"
      }


    deinit
      {
        colorPickerViewController?.removeObserver(self, forKeyPath:"selectedColor")
      }


    func add(sender: UIBarButtonItem)
      {
        // Add a new element to the end of the list
        colors.append(UIColor.lightGrayColor())

        // Inform the table view of the row insertion
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow:colors.count-1, inSection:0)], withRowAnimation:UITableViewRowAnimation.Fade);
      }


    // NSKeyValueObserving

    override func observeValueForKeyPath(path: String, ofObject sender: AnyObject, change: [NSObject:AnyObject], context:UnsafeMutablePointer<Void>)
      {
        // Update the corresponding list element
        colors[selectedRow] = colorPickerViewController!.selectedColor

        // Ask the table view to reload the effected row
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:selectedRow, inSection:0)], withRowAnimation:UITableViewRowAnimation.Fade)
      }


    // UIViewController

    override func viewDidLoad()
      {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge.None

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.Add, target:self, action:"add:")
      }


    // UITableViewDataSource

    override func tableView(sender: UITableView, numberOfRowsInSection section: Int) -> Int
      {
        return colors.count
      }


    override func tableView(sender: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell
      {
        var cell = sender.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        if cell == nil {
          cell = UITableViewCell(style:UITableViewCellStyle.Default, reuseIdentifier:"cell")
          cell!.backgroundView = GxColorView()
        }

        (cell!.backgroundView as! GxColorView).fillColor = colors[path.row] as UIColor

        return cell!
      }


    override func tableView(sender: UITableView, commitEditingStyle style: UITableViewCellEditingStyle, forRowAtIndexPath path: NSIndexPath)
      {
        assert(style == UITableViewCellEditingStyle.Delete, "unexpected argument")

        // Remove the indicated list element
        colors.removeAtIndex(path.row);

        // Inform the table view of the row removal
        sender.deleteRowsAtIndexPaths([path], withRowAnimation:UITableViewRowAnimation.Fade);
      }


    // UITableViewDelegate

    override func tableView(sender: UITableView, didSelectRowAtIndexPath path: NSIndexPath)
      {
        // Retain the selected row for posterity
        selectedRow = path.row;

        // Set the current color of the color picker
        colorPickerViewController!.selectedColor = colors[selectedRow]

        // Navigate to the color picker view
        self.navigationController?.pushViewController(colorPickerViewController!, animated:true)
      }

  }
