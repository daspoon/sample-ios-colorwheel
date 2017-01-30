/*

  Copyright © 2010-2016 David Spooner; see License.txt

  A UITableViewController subclass to present a list of colors for inspection by ColorPickerViewController.

*/

import UIKit


class ColorWheelTableViewController : UITableViewController
  {

    var colorPickerViewController: ColorPickerViewController?
    var colors: [UIColor] = []
    var selectedRow: NSInteger = 0


    convenience init()
      {
        self.init(style: UITableViewStyle.plain)

        colors = [ UIColor.red, UIColor.green, UIColor.blue ]

        colorPickerViewController = ColorPickerViewController()
        colorPickerViewController!.addObserver(self, forKeyPath:"selectedColor", options:NSKeyValueObservingOptions(), context:nil)

        self.title = "Colors"
      }


    deinit
      {
        colorPickerViewController?.removeObserver(self, forKeyPath:"selectedColor")
      }


    func add(_ sender: UIBarButtonItem)
      {
        // Add a new element to the end of the list
        colors.append(UIColor.lightGray)

        // Inform the table view of the row insertion
        self.tableView.insertRows(at: [IndexPath(row:colors.count-1, section:0)], with:UITableViewRowAnimation.fade);
      }


    // NSKeyValueObserving

    override func observeValue(forKeyPath path: String?, of sender: Any?, change: [NSKeyValueChangeKey:Any]?, context:UnsafeMutableRawPointer?)
      {
        // Update the corresponding list element
        colors[selectedRow] = colorPickerViewController!.selectedColor

        // Ask the table view to reload the effected row
        self.tableView.reloadRows(at: [IndexPath(row:selectedRow, section:0)], with:UITableViewRowAnimation.fade)
      }


    // UIViewController

    override func viewDidLoad()
      {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.add, target:self, action:#selector(ColorWheelTableViewController.add(_:)))
      }


    // UITableViewDataSource

    override func tableView(_ sender: UITableView, numberOfRowsInSection section: Int) -> Int
      {
        return colors.count
      }


    override func tableView(_ sender: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell
      {
        var cell = sender.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
          cell = UITableViewCell(style:UITableViewCellStyle.default, reuseIdentifier:"cell")
          cell!.backgroundView = ColorView()
        }

        (cell!.backgroundView as! ColorView).fillColor = colors[path.row] as UIColor

        return cell!
      }


    override func tableView(_ sender: UITableView, commit style: UITableViewCellEditingStyle, forRowAt path: IndexPath)
      {
        assert(style == UITableViewCellEditingStyle.delete, "unexpected argument")

        // Remove the indicated list element
        colors.remove(at: path.row);

        // Inform the table view of the row removal
        sender.deleteRows(at: [path], with:UITableViewRowAnimation.fade);
      }


    // UITableViewDelegate

    override func tableView(_ sender: UITableView, didSelectRowAt path: IndexPath)
      {
        // Retain the selected row for posterity
        selectedRow = path.row;

        // Set the current color of the color picker
        colorPickerViewController!.selectedColor = colors[selectedRow]

        // Navigate to the color picker view
        self.navigationController?.pushViewController(colorPickerViewController!, animated:true)
      }

  }
