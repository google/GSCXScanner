//
// Copyright 2019 Google Inc.
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

#import "GSCXScanner.h"
#import "GSCXScannerSettingsItemConfiguring.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The accessibility identifier of the scanner settings table view.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerSettingsTableAccessibilityIdentifier;

/**
 * The text of the settings item that begins a continuous scan.
 */
FOUNDATION_EXTERN NSString *const kGSCXSettingsContinuousScanButtonText;

/**
 * The accessibility identifier of the settings item that begins a continuous scan.
 */
FOUNDATION_EXTERN NSString *const kGSCXSettingsContinuousScanButtonAccessibilityIdentifier;

/**
 * The text of the settings item displayed when no issues have been found.
 */
FOUNDATION_EXTERN NSString *const kGSCXSettingsNoIssuesFoundText;

/**
 * The title of the settings item button displayed when accessibility issues have been found.
 */
FOUNDATION_EXTERN NSString *const kGSCXSettingsReportButtonTitle;

/**
 * The accessibility identifier of the settings item button displayed when accessibility issues have
 * been found.
 */
FOUNDATION_EXTERN NSString *const kGSCXSettingsReportButtonAccessibilityIdentifier;

/**
 * Displays settings to enable and disable continuous scanning, manually perform scans, and view
 * scan results.
 */
@interface GSCXScannerSettingsViewController : UIViewController

/**
 * A handler called when this view controller dismisses itself.
 */
@property(copy, nonatomic, nullable) void (^dismissBlock)(GSCXScannerSettingsViewController *);

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 * Initializes this instance with the given initial frame used for animations. Uses the default nib.
 *
 * @param frame The frame of the blur view, in this view controller's coordinates. If this view
 * controller is being presented in a different coordinate system than the presenting view
 * controller, it is the presenter's responsibility to translate the frame appropriately.
 * @param items An array of @c GSCXScannerSettingsItemConfiguring instances used to populate the
 * table.
 * @return A @c GSCXScannerSettingsViewController instance initialized with the given initial frame
 * and list of items.
 */
- (instancetype)initWithInitialFrame:(CGRect)frame
                               items:(NSArray<id<GSCXScannerSettingsItemConfiguring>> *)items
                             scanner:(GSCXScanner *)scanner;

/**
 * Animates the view controller from its initial frame into a modal view. If the user has enabled
 * "reduce motion" in the Settings app, the transition occurs instantly without animation. It is the
 * responsibility of the presenting view controller to call this method.
 *
 * @param completion An optional completion block to run when the animation has finished. The
 * parameter passed to the block is @c YES if the animation completed successfully or @c NO if it
 * hasn't.
 */
- (void)animateInWithCompletion:(nullable void (^)(BOOL))completion;

/**
 * Animates the view controller from a full screen modal to its initial frame. If the user has
 * enabled "reduce motion" in the Settings app, the transition occurs instantly without animation.
 * It is the responsibility of the presenting view controller to call this method.
 *
 * @param completion An optional completion block to run when the animation has finished. The
 * parameter passed to the block is @c YES if the animation completed successfully or @c NO if it
 * hasn't.
 */
- (void)animateOutWithCompletion:(nullable void (^)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
