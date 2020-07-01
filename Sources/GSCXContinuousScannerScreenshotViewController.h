//
// Copyright 2020 Google Inc.
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

#import "GSCXScannerResult.h"
#import "GSCXSharingDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Accessibility identifier of the carousel displaying all scan results.
 */
FOUNDATION_EXTERN NSString *const kGSCXScannerResultCarouselAccessibilityIdentifier;

/**
 * Accessibility identifier of the button displaying the grid view.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerScreenshotGridButtonAccessibilityIdentifier;

/**
 * Accessibility identifier of the button displaying the next scan result.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerScreenshotNextButtonAccessibilityIdentifier;

/**
 * Accessibility identifier of the button displaying the previous scan result.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerScreenshotBackButtonAccessibilityIdentifier;

/**
 * Accessibility identifier of the button displaying the list view.
 */
FOUNDATION_EXTERN NSString
    *const kGSCXContinuousScannerScreenshotListBarButtonAccessibilityIdentifier;

/**
 * The title of the tab bar item for the list view grouping issues by which scan they occurred in.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerScreenshotListByScanTabBarItemTitle;

/**
 * The title of the tab bar item for the list view grouping issues by which accessibility check they
 * failed.
 */
FOUNDATION_EXTERN NSString *const kGSCXContinuousScannerScreenshotListByCheckTabBarItemTitle;

/**
 * Displays a screenshot of a scan result. Views with accessibility issues are highlighted. Displays
 * a carousel so users can quickly access other scans.
 */
@interface GSCXContinuousScannerScreenshotViewController : UIViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
/**
 * Initializes this object by loading the default xib with the given scan results.
 *
 * @param scannerResults The results of scans. Cannot be empty.
 * @param sharingDelegate Delegate for configuring the sharing process.
 * @return An initialized @c GSCXContinuousScannerScreenshotViewController object.
 */
- (instancetype)initWithScannerResults:(NSArray<GSCXScannerResult *> *)scannerResults
                       sharingDelegate:(id<GSCXSharingDelegate>)sharingDelegate;

/**
 * Displays the scanner result at @c index. Selects the result at @c index in the carousel.
 *
 * @param index The index of the scan result to display.
 * @param animated @c YES if the transition should be animated, @c NO otherwise.
 */
- (void)focusResultAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
