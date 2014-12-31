/*

  Created by David Spooner on 5/10/10.
  Copyright 2010 Lambda Software Corporation. All rights reserved.

*/

#import "TableViewController.h"
#import "ColorView.h"


@implementation MyTableViewController

- (id) initWithNibName:(NSString *)aName bundle:(NSBundle *)aBundle
  {
    if ((self = [super initWithNibName:aName bundle:aBundle]) == nil)
      return nil;

    colors = [[NSMutableArray alloc] initWithObjects:
        [UIColor redColor],
        [UIColor greenColor],
        [UIColor blueColor],
        nil];

    return self;
  }


- (void) dealloc
  {
    [colors release];
    [colorPickerViewController release];
    [super dealloc];
  }


- (void) addAction:(id)sender
  {
    UITableView *tableView = self.tableView;
    [tableView beginUpdates];
    NSUInteger index = [colors count];
    [colors addObject:[UIColor lightGrayColor]];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    [tableView endUpdates];
  }


#pragma mark NSKeyValueObserving

- (void) observeValueForKeyPath:(NSString *)path ofObject:(id)object change:(NSDictionary *)change context:(void *)context
  {
    NSAssert(object == colorPickerViewController && [path isEqualToString:@"selectedColor"], @"unexpected observation");

    if (selectedRowIndex != NSNotFound) {
      [colors replaceObjectAtIndex:selectedRowIndex withObject:colorPickerViewController.selectedColor];
      [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedRowIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
  }


#pragma mark UIViewController

- (void) viewDidLoad
  {
    [super viewDidLoad];

    self.navigationItem.title = @"Colors";

    // Make the right navigation button the Edit button
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Add a toolbar with a right-justified button for taking a picture
    self.toolbarItems = [NSArray arrayWithObjects:
          [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
          [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)] autorelease],
          nil];

    UITableView *tableView = self.tableView;
    tableView.dataSource = self;
    tableView.delegate = self;

    colorPickerViewController = [[GxColorPickerViewController alloc] init];
    [colorPickerViewController addObserver:self forKeyPath:@"selectedColor" options:0 context:NULL];

    selectedRowIndex = NSNotFound;
  }


- (void) viewDidUnload
  {
    [super viewDidUnload];

    [colorPickerViewController removeObserver:self forKeyPath:@"selectedColor"];
    [colorPickerViewController release];
    colorPickerViewController = nil;

    selectedRowIndex = NSNotFound;
  }


#pragma mark UITableViewDataSource

- (NSInteger) tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section
  { return [colors count]; }


- (UITableViewCell *) tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)path
  {
    UITableViewCell *cell = [sender dequeueReusableCellWithIdentifier:@"Cell"];

    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
      cell.backgroundView = [[[GxColorView alloc] init] autorelease];
    }

    ((GxColorView *)cell.backgroundView).fillColor = [colors objectAtIndex:path.row];

    return cell;
  }


- (BOOL) tableView:(UITableView *)sender canEditRowAtIndexPath:(NSIndexPath *)path
  { return YES; }


- (void) tableView:(UITableView *)sender commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)path
  {
    switch (style) {
      case UITableViewCellEditingStyleNone :
        break;
      case UITableViewCellEditingStyleDelete :
        [colors removeObjectAtIndex:path.row];
        [sender deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
        break;
      default :
        NSAssert(0, @"unhandled case");
    }
  }


- (BOOL) tableView:(UITableView *)sender canMoveRowAtIndexPath:(NSIndexPath *)path
  { return NO; }


#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)path
  {
    selectedRowIndex = path.row;

    colorPickerViewController.selectedColor = [colors objectAtIndex:selectedRowIndex];

    [self.navigationController pushViewController:colorPickerViewController animated:YES];
  }

@end
