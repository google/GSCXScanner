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

#import <WebKit/WebKit.h>

#import "GSCXContinuousScannerResultViewController.h"
#import "GSCXCornerConstraints.h"
#import "GSCXMasterScheduler.h"
#import "GSCXReport.h"
#import "GSCXScanner.h"
#import "GSCXScannerResultTableViewController.h"
#import "GSCXScannerScreenshotViewController.h"
#import "GSCXScannerSettingsItem.h"
#import "GSCXScannerSettingsItemConfiguring.h"
#import "GSCXScannerSettingsTableViewCell.h"
#import "GSCXScannerSettingsViewController.h"
#import "GSCXTouchActivitySource.h"
#import "UIViewController+GSCXAppearance.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier =
    @"kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier";

NSString *const kGSCXPerformScanAccessibilityIdentifier =
    @"kGSCXPerformScanAccessibilityIdentifier";

NSString *const kGSCXPerformScanTitle = @"Scan Current Screen";

NSString *const kGSCXDismissSettingsAccessibilityIdentifier =
    @"kGSCXDismissSettingsAccessibilityIdentifier";

NSString *const kGSCXDismissSettingsTitle = @"Dismiss";

NSString *const kGSCXScannerOverlayDismissButtonText = @"Dismiss";

/**
 * The title of the alert shown when a scan finds no accessibility issues.
 */
static NSString *const kGSCXNoIssuesAlertTitle = @"Zero Issues";

/**
 * The message of the alert shown when a scan finds no accessibility issues.
 */
static NSString *const kGSCXNoIssuesAlertMessage =
    @"No accessibility issues were found in this scan.";

/**
 * The title of the alert shown when a scan finds accessibility issues but the resulting screenshot
 * is nil.
 */
static NSString *const kGSCXNoScreenshotAlertTitle = @"No Screenshot";

/**
 * The message of the alert shown when a scan finds accessibility issues but the resulting
 * screenshot is nil.
 */
static NSString *const kGSCXNoScreenshotAlertMessage =
    @"Accessibility issues were found, but no screenshot could be generated.";

/**
 * The title of the alert shown when accessibility is not enabled.
 */
static NSString *const kGSCXAccessibilityNotEnabledAlertTitle = @"Accessibility Not Enabled";

/**
 * The message of the alert shown when accessibility is not enabled.
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

const CGFloat kGSCXSettingsCornerRadius = 4.0;

@interface GSCXScannerOverlayViewController ()

/**
 * The difference between the initial point of a gesture and the center of the settings button. This
 * value is subtracted from the current gesture's position to get the new center of the settings
 * button. This is necessary because otherwise the button's center will snap to the gesture's
 * location at the beginning of the gesture (because the user might not press directly at the
 * center).
 */
@property(assign, nonatomic) CGPoint settingsDragInitialOffset;
/**
 * The constraints of the settings button. Used to move the button to a different corner of the
 * screen if it obscures application UI.
 */
@property(strong, nonatomic) GSCXCornerConstraints *settingsConstraints;

/**
 * YES if accessibility is enabled, NO otherwise.
 */
@property(assign, nonatomic) BOOL accessibilityEnabled;

/**
 * YES if the accessibility is not enabled alert has already been shown, NO otherwise.
 */
@property(assign, nonatomic) BOOL accessibilityNotEnabledAlertShown;

/**
 * The view controller displaying the scanner settings.
 */
@property(strong, nonatomic) GSCXScannerSettingsViewController *settingsController;

/**
 * Presents an alert telling users that zero accessibility issues were found in the last scan.
 */
- (void)gscx_presentNoIssuesFoundAlert;

/**
 * Presents a screenshot highlighting all UI elements with accessibility issues found in the last
 * scan. If the result's screenshot is nil, presents a table of the results instead.
 *
 * @param result The result of a scan.
 */
- (void)gscx_presentScreenshotControllerForScanResult:(GSCXScannerResult *)result;

/**
 * Presents a table view of all accessibility issues found in a given scan.
 *
 * @return result The result of a scan.
 */
- (void)gscx_presentTableControllerForScanResult:(GSCXScannerResult *)result;

/**
 * Presents an alert explaining that accessibility is not enabled and potential workarounds, if
 * any. Must only be called once. If called more than once, an exception is raised.
 */
- (void)gscx_presentAccessibilityNotEnabledAlert;

/**
 * Sets the left navigation item of @c viewController to a button that dismisses the results window
 * when tapped.
 *
 * @param viewController The view controller of which to set the left navigation item.
 */
- (void)gscx_replaceLeftNavigationItemWithDismissButton:(UIViewController *)viewController;

/**
 * Dismisses the view controller presented in the results window, then dismisses the results
 * window.
 *
 * @param sender The object initiating the dismissal.
 */
- (void)gscx_dismissResultsWindow:(nullable id)sender;

/**
 * Dismisses the settings page and performs a scan for accessibility issues on the application.
 *
 * @param sender The object initiating this event.
 */
- (void)gscx_performScanButtonPressed:(id)sender;

/**
 * Scans the application for accessibility issues. Presents a view controller detailing issues or an
 * alert saying no issues occurred if there were none.
 */
- (void)gscx_performScan;

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

  self.settingsButton.accessibilityIdentifier =
      kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier;
  self.settingsButtonBlur.layer.borderWidth = 1.0;
  self.settingsButtonBlur.layer.cornerRadius = kGSCXSettingsCornerRadius;
  self.settingsButtonBlur.translatesAutoresizingMaskIntoConstraints = NO;
  self.settingsButtonBlur.clipsToBounds = YES;
  [self gscx_setSettingsButtonColorForCurrentAppearance];
  self.settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.settingsConstraints = [GSCXCornerConstraints constraintsWithView:self.settingsButtonBlur
                                                              container:self];
  self.settingsButton.accessibilityCustomActions =
      self.settingsConstraints.rotateAccessibilityActions;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  if (!self.accessibilityEnabled && !self.accessibilityNotEnabledAlertShown) {
    [self gscx_presentAccessibilityNotEnabledAlert];
  }
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  [self gscx_setSettingsButtonColorForCurrentAppearance];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(nullable void (^)(void))completion {
  // If a view controller is presented in this window, it can't be interacted with. This window is
  // hardcoded to only allow touch events on the perform scan button. All view controllers must be
  // presented in a results window.
  [self.resultsWindowCoordinator presentViewController:viewControllerToPresent
                                              animated:flag
                                            completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(nullable void (^)(void))completion {
  [self.resultsWindowCoordinator dismissViewControllerAnimated:flag completion:completion];
}

- (IBAction)gscx_settingsButtonPressed:(id)sender {
  id<GSCXScannerSettingsItemConfiguring> resultsItem = nil;
  if (self.continuousScanner.issueCount == 0) {
    resultsItem = [GSCXScannerSettingsItem textItemWithText:kGSCXSettingsNoIssuesFoundText];
  } else {
    resultsItem = [GSCXScannerSettingsItem
            buttonItemWithTitle:kGSCXSettingsReportButtonTitle
                         target:self
                         action:@selector(gscx_presentContinuousScanResults)
        accessibilityIdentifier:kGSCXSettingsReportButtonAccessibilityIdentifier];
  }
  NSArray<id<GSCXScannerSettingsItemConfiguring>> *items = @[
    // TODO(b/142816796): Add a text item that acts as the title of the modal so users know they
    // have entered the scanner settings page. textItemWithText will need to be updated to allow
    // custom formatting. Otherwise, the text and the buttons will look too similar, confusing
    // users.
    [GSCXScannerSettingsItem buttonItemWithTitle:kGSCXPerformScanTitle
                                          target:self
                                          action:@selector(gscx_performScanButtonPressed:)
                         accessibilityIdentifier:kGSCXPerformScanAccessibilityIdentifier],
    [GSCXScannerSettingsItem
            switchItemWithLabel:kGSCXSettingsContinuousScanSwitchText
                           isOn:[self.continuousScanner isScanning]
                         target:self
                         action:@selector(gscx_continuousScanEnabledValueChanged:)
        accessibilityIdentifier:kGSCXSettingsContinuousScanSwitchAccessibilityIdentifier],
    resultsItem
  ];
  GSCXScannerSettingsViewController *settingsController =
      [[GSCXScannerSettingsViewController alloc] initWithInitialFrame:self.settingsButtonBlur.frame
                                                                items:items
                                                              scanner:self.scanner];
  settingsController.modalPresentationStyle = UIModalPresentationFullScreen;
  __weak __typeof__(self) weakSelf = self;
  settingsController.dismissBlock = ^(GSCXScannerSettingsViewController *settingsController) {
    [weakSelf gscx_dismissSettingsControllerWithCompletion:nil];
  };
  self.settingsController = settingsController;
  [self presentViewController:settingsController
                     animated:NO
                   completion:^{
                     self.view.hidden = YES;
                     [settingsController animateInWithCompletion:nil];
                   }];
}

- (IBAction)gscx_dragSettingsButton:(UIGestureRecognizer *)gestureRecognizer {
  NSParameterAssert([gestureRecognizer isKindOfClass:[UIGestureRecognizer class]]);
  CGPoint location = [gestureRecognizer locationInView:self.view];
  switch (gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan:
      self.settingsDragInitialOffset = CGPointMake(location.x - self.settingsButtonBlur.center.x,
                                                   location.y - self.settingsButtonBlur.center.y);
      break;

    default:
      self.settingsButtonBlur.center = CGPointMake(location.x - self.settingsDragInitialOffset.x,
                                                   location.y - self.settingsDragInitialOffset.y);
      break;
  }
}

#pragma mark - GSCXContinuousScannerDelegate

- (NSArray<UIView *> *)rootViewsToScan {
  return [self.resultsWindowCoordinator windowsToScan];
}

- (void)continuousScanner:(GSCXContinuousScanner *)scanner
    didPerformScanWithResult:(GSCXScannerResult *)result {
  // Currently a no-op. May update the settings button UI in the future.
}

#pragma mark - Private

- (void)gscx_setSettingsButtonColorForCurrentAppearance {
  self.settingsButtonBlur.effect =
      [UIBlurEffect effectWithStyle:[self gscx_blurEffectStyleForCurrentAppearance]];
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      [self.settingsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      self.settingsButtonBlur.layer.borderColor = [[UIColor whiteColor] CGColor];
      return;
    }
  }
  // Before iOS 12, only light mode existed.
  [self.settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  self.settingsButtonBlur.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)gscx_presentNoIssuesFoundAlert {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:kGSCXNoIssuesAlertTitle
                                          message:kGSCXNoIssuesAlertMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
  id<GSCXResultsWindowCoordinating> resultsWindowCoordinator = self.resultsWindowCoordinator;
  [alert addAction:[UIAlertAction actionWithTitle:kGSCXNoIssuesDismissButtonText
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction *action) {
                                            [resultsWindowCoordinator dismissResultsWindow];
                                          }]];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)gscx_presentScreenshotControllerForScanResult:(GSCXScannerResult *)result {
  if (result.screenshot == nil) {
    [self gscx_presentTableControllerForScanResult:result];
    return;
  }
  GSCXScannerScreenshotViewController *screenshotController =
      [[GSCXScannerScreenshotViewController alloc]
          initWithNibName:@"GSCXScannerScreenshotViewController"
                   bundle:[NSBundle bundleForClass:[GSCXScannerScreenshotViewController class]]
               scanResult:result
          sharingDelegate:self.sharingDelegate];
  [self gscx_replaceLeftNavigationItemWithDismissButton:screenshotController];
  UINavigationController *navController =
      [[UINavigationController alloc] initWithRootViewController:screenshotController];
  navController.delegate = screenshotController;
  [self presentViewController:navController animated:true completion:nil];
}

- (void)gscx_presentTableControllerForScanResult:(GSCXScannerResult *)result {
  GSCXScannerResultTableViewController *tableController =
      [[GSCXScannerResultTableViewController alloc]
          initWithNibName:@"GSCXScannerResultTableViewController"
                   bundle:[NSBundle bundleForClass:[GSCXScannerResultTableViewController class]]];
  tableController.scanResult = result;
  [self gscx_replaceLeftNavigationItemWithDismissButton:tableController];
  UINavigationController *navController =
      [[UINavigationController alloc] initWithRootViewController:tableController];
  [self.resultsWindowCoordinator
      presentViewController:navController
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

- (void)gscx_presentAccessibilityNotEnabledAlert {
  GTX_ASSERT(!self.accessibilityNotEnabledAlertShown,
             @"The accessibility is not enabled alert cannot be shown multiple times.");
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:kGSCXAccessibilityNotEnabledAlertTitle
                                          message:kGSCXAccessibilityNotEnabledAlertMessage
                                   preferredStyle:UIAlertControllerStyleAlert];
  id<GSCXResultsWindowCoordinating> resultsWindowCoordinator = self.resultsWindowCoordinator;
  [alert addAction:[UIAlertAction actionWithTitle:kGSCXNoIssuesDismissButtonText
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction *action) {
                                            [resultsWindowCoordinator dismissResultsWindow];
                                          }]];
  [self presentViewController:alert animated:YES completion:nil];
  self.accessibilityNotEnabledAlertShown = YES;
}

- (void)gscx_replaceLeftNavigationItemWithDismissButton:(UIViewController *)viewController {
  viewController.navigationItem.leftBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:kGSCXScannerOverlayDismissButtonText
                                       style:UIBarButtonItemStyleDone
                                      target:self
                                      action:@selector(gscx_dismissResultsWindow:)];
}

- (void)gscx_dismissResultsWindow:(nullable id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)gscx_dismissSettingsControllerWithCompletion:(nullable void (^)(void))completion {
  __weak __typeof__(self) weakSelf = self;
  [self.settingsController animateOutWithCompletion:^(BOOL finished) {
    __typeof__(self) strongSelf = weakSelf;
    strongSelf.view.hidden = NO;
    [strongSelf dismissViewControllerAnimated:NO completion:completion];
  }];
}

- (void)gscx_performScanButtonPressed:(id)sender {
  __weak __typeof__(self) weakSelf = self;
  [self gscx_dismissSettingsControllerWithCompletion:^{
    [weakSelf gscx_performScan];
  }];
}

/**
 * Enables or disables continuous scanning based on the value of @c sender.
 *
 * @param sender A @c UISwitch instance. If @c sender.isOn is @c YES, continuous scanning is
 * enabled. Otherwise, continuous scanning is disabled.
 */
- (void)gscx_continuousScanEnabledValueChanged:(UISwitch *)sender {
  BOOL isEnabled = [sender isOn];
  if (isEnabled && ![self.continuousScanner isScanning]) {
    [self.continuousScanner startScanning];
  } else if (!isEnabled && [self.continuousScanner isScanning]) {
    [self.continuousScanner stopScanning];
  }
}

/**
 * Presents a report of all continuous scan results.
 */
- (void)gscx_presentContinuousScanResults {
  GSCXReport *report =
      [[GSCXReport alloc] initWithResults:self.continuousScanner.uniqueScanResults];
  GSCXContinuousScannerResultViewController *viewController =
      [[GSCXContinuousScannerResultViewController alloc]
          initWithNibName:@"GSCXContinuousScannerResultViewController"
                   bundle:[NSBundle
                              bundleForClass:[GSCXContinuousScannerResultViewController class]]
                   report:report
          sharingDelegate:self.sharingDelegate];
  [self gscx_replaceLeftNavigationItemWithDismissButton:viewController];
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:viewController];
  // Set the delegate to disable autorotation.
  navigationController.delegate = viewController;
  navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)gscx_performScan {
  GSCXScannerResult *result =
      [self.scanner scanRootViews:[self.resultsWindowCoordinator windowsToScan]];
  if (result.issueCount > 0) {
    [self gscx_presentScreenshotControllerForScanResult:result];
  } else {
    [self gscx_presentNoIssuesFoundAlert];
  }
}

@end

NS_ASSUME_NONNULL_END
