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
#import "GSCXContinuousScannerScreenshotViewController.h"
#import "GSCXMasterScheduler.h"
#import "GSCXOverlayViewArranger.h"
#import "GSCXReport.h"
#import "GSCXScanResultsPageConstants.h"
#import "GSCXScanner.h"
#import "GSCXScannerScreenshotViewController.h"
#import "GSCXScannerSettingsItem.h"
#import "GSCXScannerSettingsItemConfiguring.h"
#import "GSCXScannerSettingsTableViewCell.h"
#import "GSCXScannerSettingsViewController.h"
#import "GSCXTouchActivitySource.h"
#import "UIView+GSCXAppearance.h"
#import "UIViewController+GSCXAppearance.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

// TODO: Localize these strings and load them from an external resource instead of
// hardcoding them.

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

/**
 * The title of the scanner settings button during a continuous scan.
 */
static NSString *const kGSCXSettingsButtonTitleContinuousScanningActive = @"Stop Scanning";

/**
 * The title of the scanner settings button when a continuous scan is not in progress.
 */
static NSString *const kGSCXSettingsButtonTitleContinuousScanningInactive = @"Scanner Menu";

@interface GSCXScannerOverlayViewController ()

/**
 * Manages the frame of the settings button. Moves the button to a different corner of the
 * screen if it obscures application UI and handles long press to move gestures.
 */
@property(strong, nonatomic) GSCXOverlayViewArranger *settingsButtonArranger;

/**
 * YES if accessibility is enabled, NO otherwise.
 */
@property(assign, nonatomic) BOOL accessibilityEnabled;

/**
 * YES if the accessibility is not enabled alert has already been shown, NO otherwise.
 */
@property(assign, nonatomic) BOOL accessibilityNotEnabledAlertShown;

/**
 * @c YES if the scanner UI should allow multiple results windows to be presented, @c NO otherwise.
 */
@property(assign, nonatomic, getter=isMultiWindowPresentation) BOOL multiWindowPresentation;

/**
 * A stack of settings view controllers displaying the scanner settings. If
 * @c multiWindowPresentation is @c YES, the settings button remains visible over results windows,
 * so multiple settings controllers can be presented. If @c NO, the settings button is not visible
 * over results windows, so this stack will never contain more than one view controller.
 */
@property(strong, nonatomic)
    NSMutableArray<GSCXScannerSettingsViewController *> *settingsControllers;

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
- (void)gscx_presentScreenshotControllerForScanResult:(GTXHierarchyResultCollection *)result;

/**
 * Presents an alert explaining that accessibility is not enabled and potential workarounds, if
 * any. Must only be called once. If called more than once, an exception is raised.
 */
- (void)gscx_presentAccessibilityNotEnabledAlert;

/**
 * Sets navigation item properties of @c viewController. The left bar button item dismisses the view
 * controller. The back bar button item is set so all view controllers pushed by @c viewController
 * have the same back button. The title is set so users know a results page has been displayed.
 *
 * @param viewController The view controller of which to populate the navigation item properties.
 */
- (void)gscx_updateNavigationItemForResultsViewController:(UIViewController *)viewController;

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
           accessibilityEnabled:(BOOL)accessibilityEnabled
      isMultiWindowPresentation:(BOOL)isMultiWindowPresentation {
  self = [super initWithNibName:nibName bundle:bundle];
  if (self) {
    _accessibilityEnabled = accessibilityEnabled;
    _multiWindowPresentation = isMultiWindowPresentation;
    _settingsControllers = [[NSMutableArray alloc] init];
  }
  return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  return [self initWithNibName:nil bundle:nil accessibilityEnabled:NO isMultiWindowPresentation:NO];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.settingsButton.accessibilityIdentifier =
      kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier;
  self.settingsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
  self.settingsButton.titleLabel.adjustsFontForContentSizeCategory = YES;
  self.settingsButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  self.settingsButtonBlur.layer.borderWidth = 1.0;
  self.settingsButtonBlur.layer.cornerRadius = kGSCXSettingsCornerRadius;
  self.settingsButtonBlur.translatesAutoresizingMaskIntoConstraints = NO;
  self.settingsButtonBlur.clipsToBounds = YES;
  [self gscx_setSettingsAttributedTitleToText:kGSCXSettingsButtonTitleContinuousScanningInactive];
  [self gscx_setSettingsButtonColorForCurrentAppearance];
  self.settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.settingsButtonArranger =
      [[GSCXOverlayViewArranger alloc] initWithView:self.settingsButtonBlur container:self];
  self.settingsButton.accessibilityCustomActions =
      self.settingsButtonArranger.rotateAccessibilityActions;
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

#pragma mark - GSCXContinuousScannerDelegate

- (NSArray<UIView *> *)rootViewsToScan {
  return [self.resultsWindowCoordinator windowsToScan];
}

#pragma mark - Private

- (IBAction)gscx_settingsButtonPressed:(id)sender {
  if ([self.continuousScanner isScanning]) {
    [self gscx_stopContinuousScanningAndPresentResults];
    return;
  }
  // TODO: Add a text item that acts as the title of the modal so users know they
  // have entered the scanner settings page. textItemWithText will need to be updated to allow
  // custom formatting. Otherwise, the text and the buttons will look too similar, confusing
  // users.
  NSMutableArray<id<GSCXScannerSettingsItemConfiguring>> *items = [[NSMutableArray alloc] init];
  [items addObject:[GSCXScannerSettingsItem
                           buttonItemWithTitle:kGSCXPerformScanTitle
                                        target:self
                                        action:@selector(gscx_performScanButtonPressed:)
                       accessibilityIdentifier:kGSCXPerformScanAccessibilityIdentifier]];
  // Allowing continuous scans while in the continuous scans results page causes a poor user
  // experience. Only allow manual scanning while in results pages.
  if ([self.resultsWindowCoordinator presentedWindowCount] == 0) {
    [items
        addObject:
            [GSCXScannerSettingsItem
                    buttonItemWithTitle:kGSCXSettingsContinuousScanButtonText
                                 target:self
                                 action:@selector(gscx_startContinuousScanningFromSettingsPage)
                accessibilityIdentifier:kGSCXSettingsContinuousScanButtonAccessibilityIdentifier]];
  }
  GSCXScannerSettingsViewController *settingsController =
      [[GSCXScannerSettingsViewController alloc] initWithInitialFrame:self.settingsButtonBlur.frame
                                                                items:items
                                                              scanner:self.scanner];
  settingsController.modalPresentationStyle = UIModalPresentationFullScreen;
  __weak __typeof__(self) weakSelf = self;
  settingsController.dismissBlock = ^(GSCXScannerSettingsViewController *settingsController) {
    [weakSelf gscx_dismissSettingsControllerWithCompletion:nil];
  };
  [self.settingsControllers addObject:settingsController];
  [self presentViewController:settingsController
                     animated:NO
                   completion:^{
                     __typeof__(self) strongSelf = weakSelf;
                     if (strongSelf) {
                       if (!strongSelf.isMultiWindowPresentation) {
                         strongSelf.view.hidden = YES;
                       }
                       [settingsController animateInWithCompletion:nil];
                     }
                   }];
}

- (IBAction)gscx_dragSettingsButton:(UIGestureRecognizer *)gestureRecognizer {
  [self.settingsButtonArranger handleDragForGestureRecognizer:gestureRecognizer];
}

- (void)gscx_setSettingsButtonColorForCurrentAppearance {
  self.settingsButtonBlur.effect =
      [UIBlurEffect effectWithStyle:[self gscx_blurEffectStyleForCurrentAppearance]];
  // Set the title to the current text to set the color without changing the text.
  [self gscx_setSettingsAttributedTitleToText:self.settingsButton.titleLabel.attributedText.string];
  if (@available(iOS 12.0, *)) {
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
      self.settingsButtonBlur.layer.borderColor = [[UIColor whiteColor] CGColor];
      return;
    }
  }
  // Before iOS 12, only light mode existed.
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

- (void)gscx_presentScreenshotControllerForScanResult:(GTXHierarchyResultCollection *)result {
  GSCXScannerScreenshotViewController *screenshotController =
      [[GSCXScannerScreenshotViewController alloc]
          initWithNibName:@"GSCXScannerScreenshotViewController"
                   bundle:[NSBundle bundleForClass:[GSCXScannerScreenshotViewController class]]
               scanResult:result
          sharingDelegate:self.sharingDelegate];
  [self gscx_updateNavigationItemForResultsViewController:screenshotController];
  UINavigationController *navController =
      [[UINavigationController alloc] initWithRootViewController:screenshotController];
  navController.modalPresentationStyle = UIModalPresentationFullScreen;
  navController.navigationBar.translucent = NO;
  [self presentViewController:navController animated:true completion:nil];
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

- (void)gscx_updateNavigationItemForResultsViewController:(UIViewController *)viewController {
  viewController.navigationItem.title = kGSCXScanResultsPageTitle;
  viewController.navigationItem.backBarButtonItem =
      [[UIBarButtonItem alloc] initWithTitle:kGSCXScanResultsBackButtonTitle
                                       style:UIBarButtonItemStylePlain
                                      target:nil
                                      action:nil];
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
  GSCXScannerSettingsViewController *settingsController = [self.settingsControllers lastObject];
  GTX_ASSERT(settingsController != nil,
             @"Cannot dismiss settings controller with no visible settings controllers.");
  [self.settingsControllers removeLastObject];
  [settingsController animateOutWithCompletion:^(BOOL finished) {
    __typeof__(self) strongSelf = weakSelf;
    if (strongSelf) {
      if (!strongSelf.isMultiWindowPresentation) {
        strongSelf.view.hidden = NO;
      }
      [strongSelf dismissViewControllerAnimated:NO completion:completion];
    }
  }];
}

- (void)gscx_performScanButtonPressed:(id)sender {
  __weak __typeof__(self) weakSelf = self;
  [self gscx_dismissSettingsControllerWithCompletion:^{
    [weakSelf gscx_performScan];
  }];
}

/**
 * Dismisses the settings page and begins a continuous scan.
 */
- (void)gscx_startContinuousScanningFromSettingsPage {
  __weak __typeof__(self) weakSelf = self;
  [self gscx_dismissSettingsControllerWithCompletion:^{
    [weakSelf gscx_startContinuousScanning];
  }];
}

/**
 * Presents a report of all continuous scan results.
 */
- (void)gscx_presentContinuousScanResults {
  GSCXContinuousScannerScreenshotViewController *viewController =
      [[GSCXContinuousScannerScreenshotViewController alloc]
          initWithScannerResults:self.continuousScanner.scanResults
                 sharingDelegate:self.sharingDelegate];
  [self gscx_updateNavigationItemForResultsViewController:viewController];
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:viewController];
  navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
  navigationController.navigationBar.translucent = NO;
  [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)gscx_performScan {
  GTXHierarchyResultCollection *result =
      [self.scanner scanRootViews:[self.resultsWindowCoordinator windowsToScan]];
  if ([result checkResultCount] > 0) {
    [self gscx_presentScreenshotControllerForScanResult:result];
  } else {
    [self gscx_presentNoIssuesFoundAlert];
  }
}

/**
 * Begins a continuous scan. Crashes with an assertion if a continuous scan is already in progress.
 */
- (void)gscx_startContinuousScanning {
  GTX_ASSERT(![self.continuousScanner isScanning],
             @"Cannot start scanning while already scanning.");
  [self.continuousScanner startScanning];
  [self gscx_setSettingsAttributedTitleToText:kGSCXSettingsButtonTitleContinuousScanningActive];
}

/**
 * Stops continuous scanning and presents the results, if any. Presents an alert if no accessibility
 * issues were found while continuous scanning occurred. Crashes with an assertion if a continuous
 * scan is not in progress.
 */
- (void)gscx_stopContinuousScanningAndPresentResults {
  GTX_ASSERT([self.continuousScanner isScanning], @"Cannot stop scanning while not scanning.");
  [self gscx_setSettingsAttributedTitleToText:kGSCXSettingsButtonTitleContinuousScanningInactive];
  [self.continuousScanner stopScanning];
  if ([self.continuousScanner issueCount] == 0) {
    [self gscx_presentNoIssuesFoundAlert];
    return;
  }
  [self gscx_presentContinuousScanResults];
}

/**
 * Sets the text of the settings button to an attributed text with @c text and the default
 * attributes for font and color.
 *
 * @param text The title for the settings button.
 */
- (void)gscx_setSettingsAttributedTitleToText:(NSString *)text {
  NSDictionary<NSString *, id> *attributes = @{
    NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
    NSForegroundColorAttributeName : [self gscx_textColorForCurrentAppearance]
  };
  NSAttributedString *title = [[NSAttributedString alloc] initWithString:text
                                                              attributes:attributes];
  [self.settingsButton setAttributedTitle:title forState:UIControlStateNormal];
}

@end

NS_ASSUME_NONNULL_END
