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

#import <UIKit/UIKit.h>

#import "GSCXContinuousScanner.h"
#import "GSCXContinuousScannerDelegate.h"
#import "GSCXResultsWindowCoordinating.h"
#import "GSCXScanner.h"
#import "GSCXSharingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The accessibility identifier of the button displaying the settings page.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier;

/**
 * The accessibility identifier of the button that performs a scan.
 */
FOUNDATION_EXTERN NSString *const kGSCXPerformScanAccessibilityIdentifier;

/**
 * The title of the button that performs a scan.
 */
FOUNDATION_EXTERN NSString *const kGSCXPerformScanTitle;

/**
 * The accessibility identifier of the button that dismisses the settings page.
 */
FOUNDATION_EXTERN NSString *const kGSCXDismissSettingsAccessibilityIdentifier;

/**
 * The title of the button that dismisses the settings page.
 */
FOUNDATION_EXTERN NSString *const kGSCXDismissSettingsTitle;

/**
 * The text of the bar button item that dismisses the results window and returns to the main
 * application.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerOverlayDismissButtonText;

/**
 * The text of the button dismissing the alert shown when a scan finds no accessibility issues.
 */
FOUNDATION_EXTERN NSString *const kGSCXNoIssuesDismissButtonText;

/**
 * The corner radius of the rounded corners of the settings button.
 */
FOUNDATION_EXTERN const CGFloat kGSCXSettingsCornerRadius;

/**
 * Contains the UI for manually triggering a scan on an application.
 */
@interface GSCXScannerOverlayViewController : UIViewController <GSCXContinuousScannerDelegate>

/**
 * The scanner used to check the application for issues. It is the responsibility of this object's
 * owner to set this before it is used.
 */
@property(strong, nonatomic, nullable) GSCXScanner *scanner;

/**
 * Scans the application for accessibility issues in the background without explicit user
 * interaction. This object's owner must set this before it is used.
 */
@property(strong, nonatomic, nullable) GSCXContinuousScanner *continuousScanner;

/**
 * Used to present and dismiss the results of scans.
 */
@property(strong, nonatomic) id<GSCXResultsWindowCoordinating> resultsWindowCoordinator;

/**
 * A button displaying the settings page on tap.
 */
@property(weak, nonatomic, nullable) IBOutlet UIButton *settingsButton;

/**
 * A dark blur wrapping the settings button to visually differentiate the scanner overlay UI from
 * the application UI.
 */
@property(weak, nonatomic) IBOutlet UIVisualEffectView *settingsButtonBlur;

/**
 * Controls how scan reports are shared.
 */
@property(strong, nonatomic) id<GSCXSharingDelegate> sharingDelegate;

- (instancetype)initWithNibName:(nullable NSString *)nibName
                         bundle:(nullable NSBundle *)bundle NS_UNAVAILABLE;

/**
 * Initializes this object by loading from a xib file from a given bundle. The user provides
 * whether accessibility is enabled or not.
 *
 * @param nibName The name of the xib file to load from (without the ".xib" extension).
 * @param bundle The bundle the xib file is located in, or nil if it's in the main bundle.
 * @param accessibilityEnabled YES if accessibility is enabled, NO otherwise.
 * @param isMultiWindowPresentation @c YES if the scanner UI should allow multiple results windows
 * to be presented, @c NO otherwise.
 * @return An initialized GSCXScannerOverlayViewController object.
 */
- (instancetype)initWithNibName:(nullable NSString *)nibName
                         bundle:(nullable NSBundle *)bundle
           accessibilityEnabled:(BOOL)accessibilityEnabled
      isMultiWindowPresentation:(BOOL)isMultiWindowPresentation NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
