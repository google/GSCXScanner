//
// Copyright 2018 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "GSCXScannerOverlayViewController.h"

#import "GSCXCornerConstraints.h"
#import "GSCXScanner.h"
#import "GSCXScannerResultTableViewController.h"
#import "GSCXScannerScreenshotViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The title of the alert shown when a scan finds no accessibility issues.
 */
static NSString *const kGSCXNoIssuesAlertTitle = @"Zero Issues";
/**
 *  The message of the alert shown when a scan finds no accessibility issues.
 */
static NSString *const kGSCXNoIssuesAlertMessage =
    @"No accessibility issues were found in this scan.";
/**
 *  The title of the alert shown when a scan finds accessibility issues but the resulting screenshot
 *  is nil.
 */
static NSString *const kGSCXNoScreenshotAlertTitle = @"No Screenshot";
/**
 *  The message of the alert shown when a scan finds accessibility issues but the resulting
 *  screenshot is nil.
 */
static NSString *const kGSCXNoScreenshotAlertMessage =
    @"Accessibility issues were found, but no screenshot could be generated.";
/**
 *  The title of the alert shown when accessibility is not enabled.
 */
static NSString *const kGSCXAccessibilityNotEnabledAlertTitle = @"Accessibility Not Enabled";
/**
 *  The message of the alert shown when accessibility is not enabled.
 */
#if TARGET_OS_SIMULATOR
static NSString *const kGSCXAccessibilityNotEnabledAlertMessage =
    @"GSCXScanner requires accessibility to be enabled. Check the device logs to determine why "
    @"accessibility could not be enabled.";
#else
static NSString *const kGSCXAccessibilityNotEnabledAlertMessage =
    @"GSCXScanner requires accessibility to be enabled. Turn on VoiceOver to enable accessibility. "
    @"It is recommended that you enable VoiceOver through the accessibility shortcut (see "
    @"go/voiceover-setup).";
#endif
NSString *const kGSCXNoIssuesDismissButtonText = @"Ok";
NSString *const kGSCXPerformScanAccessibilityIdentifier =
    @"kGSCXPerformScanAccessibilityIdentifier";

@interface GSCXScannerOverlayViewController ()

/**
 *  The difference between the initial point of a long press gesture and the center of the perform
 *  scan button. This value is subtracted from the long press to get the new center of the perform
 *  scan button. This is necessary because otherwise the button's center will snap to the gesture's
 *  location at the beginning of the gesture (because the user might not press directly at the
 *  center).
 */
@property(assign, nonatomic) CGPoint performScanDragInitialOffset;
/**
 *  The constraints of the perform scan button. Used to move the button to a different corner of the
 *  screen if it obscures application UI.
 */
@property(strong, nonatomic) GSCXCornerConstraints *performScanConstraints;
/**
 *  YES if accessibility is enabled, NO otherwise.
 */
@property(assign, nonatomic) BOOL accessibilityEnabled;
/**
 *  YES if the accessibility is not enabled alert has already been shown, NO otherwise.
 */
@property(assign, nonatomic) BOOL accessibilityNotEnabledAlertShown;

/**
 *  Presents an alert telling users that zero accessibility issues were found in the last scan.
 */
- (void)_presentNoIssuesFoundAlert;
/**
 *  Presents a screenshot highlighting all UI elements with accessibility issues found in the last
 *  scan. If the result's screenshot is nil, presents a table of the results instead.
 *
 *  @param result The result of a scan.
 */
- (void)_presentScreenshotControllerForScanResult:(GSCXScannerResult *)result;
/**
 *  Presents a table view of all accessibility issues found in a given scan.
 *
 *  @return result The result of a scan.
 */
- (void)_presentTableControllerForScanResult:(GSCXScannerResult *)result;
/**
 *  Presents an alert explaining that accessibility is not enabled and potential workarounds, if
 *  any. Must only be called once. If called more than once, an exception is raised.
 */
- (void)_presentAccessibilityNotEnabledAlert;

@end

@implementation GSCXScannerOverlayViewController

- (instancetype)initWithNibName:(nullable NSString *)nibName
                         bundle:(nullable NSBundle *)bundle
           accessibilityEnabled:(BOOL)accessibilityEnabled {
  self = [super initWithNibName:nibName bundle:bundle];
  if (self) {
    _accessibilityEnabled = accessibilityEnabled;
  }
  return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  return [self initWithNibName:nil bundle:nil accessibilityEnabled:NO];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.performScanButton.accessibilityIdentifier = kGSCXPerformScanAccessibilityIdentifier;
  self.performScanButton.layer.borderWidth = 1.0;
  self.performScanButton.layer.borderColor = [[UIColor blackColor] CGColor];
  self.performScanButton.layer.cornerRadius = 4.0;
  self.performScanButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.performScanConstraints = [GSCXCornerConstraints constraintsWithView:self.performScanButton
                                                                 container:self];
  self.performScanButton.accessibilityCustomActions =
      self.performScanConstraints.rotateAccessibilityActions;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (!self.accessibilityEnabled && !self.accessibilityNotEnabledAlertShown) {
    [self _presentAccessibilityNotEnabledAlert];
  }
}

- (IBAction)performScanButtonPressed:(id)sender {
  GSCXScannerResult *result =
      [self.scanner scanRootViews:[[UIApplication sharedApplication] windows]];
  if (result.issueCount > 0) {
    [self _presentScreenshotControllerForScanResult:result];
  } else {
    [self _presentNoIssuesFoundAlert];
  }
}

- (IBAction)longPressGestureRecognized:(id)sender {
  NSParameterAssert([sender isKindOfClass:[UILongPressGestureRecognizer class]]);
  UILongPressGestureRecognizer *longPressRecognizer = (UILongPressGestureRecognizer *)sender;

  CGPoint location = [longPressRecognizer locationInView:self.view];
  switch (longPressRecognizer.state) {
    case UIGestureRecognizerStateBegan:
      self.performScanDragInitialOffset = CGPointMake(location.x - self.performScanButton.center.x,
                                                      location.y - self.performScanButton.center.y);
      break;

    default:
      self.performScanButton.center = CGPointMake(location.x - self.performScanDragInitialOffset.x,
                                                  location.y - self.performScanDragInitialOffset.y);
      break;
  }
}

#pragma mark - GSCXWindowOverlayViewController

- (BOOL)isTransparentOverlay {
  return YES;
}

#pragma mark - Private

- (void)_presentNoIssuesFoundAlert {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:kGSCXNoIssuesAlertTitle
                                          message:kGSCXNoIssuesAlertMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:kGSCXNoIssuesDismissButtonText
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)_presentScreenshotControllerForScanResult:(GSCXScannerResult *)result {
  if (result.screenshot == nil) {
    [self _presentTableControllerForScanResult:result];
    return;
  }
  GSCXScannerScreenshotViewController *screenshotController =
      [[GSCXScannerScreenshotViewController alloc]
          initWithNibName:@"GSCXScannerScreenshotViewController"
                   bundle:[NSBundle bundleForClass:[GSCXScannerScreenshotViewController class]]];
  screenshotController.scanResult = result;
  UINavigationController *navController =
      [[UINavigationController alloc] initWithRootViewController:screenshotController];
  navController.delegate = screenshotController;
  [self presentViewController:navController animated:true completion:nil];
}

- (void)_presentTableControllerForScanResult:(GSCXScannerResult *)result {
  GSCXScannerResultTableViewController *tableController =
      [[GSCXScannerResultTableViewController alloc]
          initWithNibName:@"GSCXScannerResultTableViewController"
                   bundle:[NSBundle bundleForClass:[GSCXScannerResultTableViewController class]]];
  tableController.scanResult = result;
  UINavigationController *navController =
      [[UINavigationController alloc] initWithRootViewController:tableController];
  [tableController replaceLeftNavigationItemWithDismissButton];
  [self presentViewController:navController
                     animated:true
                   completion:^() {
                     UIAlertController *alert =
                         [UIAlertController alertControllerWithTitle:kGSCXNoScreenshotAlertTitle
                                                             message:kGSCXNoScreenshotAlertMessage
                                                      preferredStyle:UIAlertControllerStyleAlert];
                     [alert addAction:[UIAlertAction actionWithTitle:kGSCXNoIssuesDismissButtonText
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil]];
                     [tableController presentViewController:alert animated:YES completion:nil];
                   }];
}

- (void)_presentAccessibilityNotEnabledAlert {
  NSAssert(!self.accessibilityNotEnabledAlertShown,
           @"The accessibility is not enabled alert cannot be shown multiple times.");
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:kGSCXAccessibilityNotEnabledAlertTitle
                                          message:kGSCXAccessibilityNotEnabledAlertMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:kGSCXNoIssuesDismissButtonText
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
  [self presentViewController:alert animated:YES completion:nil];
  self.accessibilityNotEnabledAlertShown = YES;
}

@end

NS_ASSUME_NONNULL_END
