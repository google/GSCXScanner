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

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
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
 * Scrolls the element matching @c scrollMatcher until the element matching @c elementMatcher is
 * interactable. Fails the test if no element matching @c elementMatcher can be found after
 * scrolling through the entire view. Immediately returns if the element is interactable without
 * scrolling.
 *
 * @param scrollMatcher Matches the element to scroll.
 * @param elementMatcher Matches the element to interact with.
 * @return A @c GREYInteraction instance representing an interaction with the element matching
 * @c elementMatcher.
 */
+ (GREYElementInteraction *)scrollElementWithMatcher:(id<GREYMatcher>)scrollMatcher
                                toElementWithMatcher:(id<GREYMatcher>)elementMatcher;

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
 * Taps the continuous scan button in the settings page.
 */
+ (void)tapStartContinuousScanningButton;

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
 * Selects a navigation bar button item with the given accessibility label and taps it.
 *
 * @param accessibilityLabel The accessibility label of the bar button item.
 */
+ (void)tapNavButtonWithAccessibilityLabel:(NSString *)accessibilityLabel;

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
 * Taps the share button to share a report of the scan.
 */
+ (void)tapShareReportButton;

/**
 * Taps the cancel button to dismiss the mocked share alert.
 */
+ (void)tapCancelMockShareReportButton;

/**
 * Taps the grid button in the continuous screenshot view to present the grid view.
 */
+ (void)tapGridButton;

/**
 * Taps the cell in the grid view at the given index.
 *
 * @param index The index of the cell to tap.
 */
+ (void)tapGridCellAtIndex:(NSUInteger)index;

/**
 * Taps the button in the continuous scan results view that displays the next scan result.
 */
+ (void)tapNextContinuousScanResultButton;

/**
 * Taps the button in the continuous scan results view that displays the previous scan result.
 */
+ (void)tapBackContinuousScanResultButton;

/**
 * Taps the list button in the continuous screenshot view to present the list view.
 */
+ (void)tapListButton;

/**
 * Taps the list section header at @c sectionIndex to expand or collapse it. Fails the test if no
 * section header exists at @c sectionIndex.
 *
 * @param sectionIndex The index of the section to toggle.
 */
+ (void)toggleListSectionAtIndex:(NSInteger)sectionIndex;

/**
 * Asserts the list section header at @c sectionIndex does or does not have the accessibility trait
 * @c accessibilityTrait. Fails the test if no header exists at @c sectionIndex or the header does
 * not have the accessibility trait when @c exists is @c YES or does have the accessibility trait
 * when @c exists is @c NO.
 *
 * @param sectionIndex The index of the section to match the header.
 * @param accessibilityTrait The accessibility trait the header must have.
 * @param @c YES to assert the header has the accessibility trait, @c NO to assert the header does
 * not have the accessibility trait.
 */
+ (void)assertListSectionAtIndex:(NSInteger)sectionIndex
              accessibilityTrait:(UIAccessibilityTraits)accessibilityTrait
                          exists:(BOOL)exists;

/**
 * Taps the tab bar button with the given title to present the associated view controller.
 *
 * @param title The title of the tab bar item to tap.
 */
+ (void)tapTabBarButtonWithTitle:(NSString *)title;

/**
 * Selects the ring view at the given index by matching the accessibility identifier generated by
 * + [GSCXRingViewArranger accessibilityIdentifierForRingViewAtIndex:].
 *
 * @param index The index of the ring view to be matched.
 * @return The result of selecting the given ring view.
 */
+ (GREYElementInteraction *)selectRingViewAtIndex:(NSInteger)index;

/**
 * Asserts the carousel has selected the cell at the given index. @c index is the index path of the
 * cell, not the absolute index of the cell on screen. Fails with an assertion if the cell is not
 * selected.
 *
 * @param index The index of the cell to assert. Corresponds to the cell's index path.
 */
+ (void)assertCarouselSelectedCellAtIndex:(NSInteger)index;

/**
 * Asserts that there are exactly the given number of rings on screen.
 *
 * @param count The exact number of rings that must exist to pass the test.
 */
+ (void)assertRingViewCount:(NSInteger)count;

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
 * Asserts that the continuous scan button can or cannot be interacted with.
 *
 * @param interactable @c YES to assert the continuous scan button can be interacted with, @c NO to
 * assert the continuous scan button cannot be interacted with.
 */
+ (void)assertContinuousScanButtonIsInteractable:(BOOL)interactable;

/**
 * Asserts that a label with text equal to @c checkName is either sufficiently visible or not
 * sufficiently visible.
 *
 * @param checkName The text of the label to search for.
 * @param isSufficientlyVisible @c YES to assert the element is sufficiently visible, @c NO to
 * assert the element is not sufficiently visible.
 */
+ (void)assertLabelForCheckNamed:(NSString *)checkName
           isSufficientlyVisible:(BOOL)isSufficientlyVisible;

/**
 * Asserts that a label with text equal to @c checkName is either sufficiently visible or not
 * sufficiently visible. Scrolls the element matching @c scrollMatcher until the label is
 * visible. If the label is not visible, even after scrolling, the test is failed.
 *
 * @param checkName The text of the label to search for.
 * @param isSufficientlyVisible @c YES to assert the element is sufficiently visible, @c NO to
 *  assert the element is not sufficiently visible.
 * @param scrollMatcher Matches the element to scroll to search for the label.
 */
+ (void)assertLabelForCheckNamed:(NSString *)checkName
           isSufficientlyVisible:(BOOL)isSufficientlyVisible
     scrollingElementWithMatcher:(id<GREYMatcher>)scrollMatcher;

/**
 * Asserts the number of sections in the list view is equal to @c sectionCount.
 *
 * @param sectionCount The expected number of sections in the list view.
 */
+ (void)assertListSectionCount:(NSInteger)sectionCount;

/**
 * Asserts the number of rows in section @c section in the list view is equal to @c rowCount.
 *
 * @param rowCount The expected number of rows in @c section.
 * @param section The section index to assert the row count of.
 */
+ (void)assertListRowCount:(NSInteger)rowCount inSection:(NSInteger)section;

/**
 * @return @c YES if the no issues found label settings item exists, @c NO otherwise.
 */
+ (BOOL)noIssuesFoundItemExists;

/**
 * @return @c YES if the report button settings item exists, @c NO otherwise.
 */
+ (BOOL)reportButtonItemExists;

/**
 * Pauses the test until the settings page is dismissed and triggers a scan. The user should assert
 * that the return value is @c YES if they depend on the scan occurring.
 *
 * @return @c YES if a scan was performed, @c NO otherwise.
 */
+ (BOOL)waitForContinuousScan;

/**
 * @return A matcher for elements whose @c isHidden value is @c YES.
 */
+ (id<GREYMatcher>)isHiddenMatcher;

@end
