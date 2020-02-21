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

#import <XCTest/XCTest.h>

#import "GSCXTestPage.h"

/**
 * Contains shared functionality to interact with the test app in all integration tests.
 */
@interface GSCXScannerTestUtils : NSObject

/**
 * Navigates to the original app screen so the next test case starts from a valid state.
 */
+ (void)navigateToRootPage;

/**
 * Opens the given page by tapping on the corresponding cell on the main table view.
 */
+ (void)openPage:(Class<GSCXTestPage>)pageClass;

/**
 * Taps the settings button to present the settings page.
 */
+ (void)tapSettingsButton;

/**
 * Taps the dismiss settings button to dismiss the settings page.
 */
+ (void)dismissSettingsPage;

/**
 * Taps the settings button to make the perform scan button visible. Then, taps the perform scan
 * button to scan the app's view hierarchy.
 */
+ (void)tapPerformScanButton;

/**
 * Toggles the continuous scan switch in the settings page.
 */
+ (void)toggleContinuousScanSwitch;

/**
 * Taps the report button in the settings page. Fails the test if the report button does not exist.
 */
+ (void)tapReportButton;

/**
 * Taps the cancel button for the no issues found alert.
 */
+ (void)dismissNoIssuesAlert;

/**
 * Taps the dismiss bar button item on the screenshot view to return to the main application.
 */
+ (void)dismissScreenshotView;

/**
 * Taps the dismiss bar button item on the continuous scan report to return to the settings page.
 */
+ (void)dismissContinuousScanReport;

/**
 * Presents an alert in a new window with window level UIWindowLevelAlert to mimic system alert
 * behavior. Actual system alerts cannot be used because they only appear once per app (for example,
 * requesting location permissions only presents an alert once. Any other time, even after closing
 * and restarting the app, will not present the alert).
 */
+ (void)presentMockSystemAlert;

/**
 * Dismisses the mock system alert by tapping its cancel button.
 */
+ (void)dismissMockSystemAlert;

/**
 * Asserts that the settings button can or cannot be interacted with.
 *
 * @param interactable YES to assert the settings button can be interacted with, NO to assert the
 * settings button cannot be interacted with.
 */
+ (void)assertSettingsButtonIsInteractable:(BOOL)interactable;

/**
 * Asserts that the settings button can or cannot be interacted with. Returns the result in the out
 * parameter @c error.
 *
 * @param interactable YES to assert the settings button can be interacted with, NO to assert the
 * settings button cannot be interacted with.
 * @param error A pointer to an @c NSError variable. If the settings button is interactable when
 * @c interactable is @c NO or vice versa, the test does not crash, but @c error is set to an
 * @c NSError instance describing the error. Otherwise, @c error is unchanged.
 */
+ (void)assertSettingsButtonIsInteractable:(BOOL)interactable
                                     error:(NSError *__autoreleasing *)error;

/**
 * Asserts that the perform scan button can or cannot be interacted with.
 *
 * @param interactable YES to assert the perform scan button can be interacted with, NO to assert
 * the perform scan button cannot be interacted with.
 */
+ (void)assertPerformScanButtonIsInteractable:(BOOL)interactable;

/**
 * Asserts that the continuous scan switch can or cannot be interacted with.
 *
 * @param interactable @c YES to assert the continuous scan switch can be interacted with, @c NO to
 * assert the continuous scan switch cannot be interacted with.
 */
+ (void)assertContinuousScanSwitchIsInteractable:(BOOL)interactable;

/**
 * Asserts that the continuous scan switch is on or off.
 *
 * @param isOn @c YES to assert the continuous scan switch is on, @c NO to assert the continuous
 * scan switch is off.
 */
+ (void)assertContinuousScanSwitchIsOn:(BOOL)isOn;

/**
 * @return @c YES if the no issues found label settings item exists, @c NO otherwise.
 */
+ (BOOL)noIssuesFoundItemExists;

/**
 * @return @c YES if the report button settings item exists, @c NO otherwise.
 */
+ (BOOL)reportButtonItemExists;

@end
