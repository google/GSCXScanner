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

#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/ContinuousScannerTests/GSCXContinuousScannerTestCase.h"

#import <XCTest/XCTest.h>

#import "GSCXContinuousScannerScreenshotViewController.h"
#import "GSCXScanResultsPageConstants.h"
#import "GSCXScannerResultCarousel.h"
#import "GSCXScannerScreenshotViewController.h"
#import "GSCXTestCheckNames.h"
#import "GSCXTestEnvironmentVariables.h"
#import "GSCXTestScannerViewController.h"
#import "GSCXTestSharingDelegate.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Exposes private methods so they can be used in tests.
 */
@interface GSCXContinuousScannerScreenshotViewController (ExposedForTesting)

+ (NSString *)gscx_scanNumberTextForScanAtIndex:(NSUInteger)scanIndex;
+ (NSString *)gscx_issueCountTextForIssueCount:(NSUInteger)issueCount;

@end

@interface GSCXContinuousScannerScreenshotViewControllerTests : GSCXContinuousScannerTestCase
@end

@implementation GSCXContinuousScannerScreenshotViewControllerTests

- (void)testScreenshotViewPresentsScanResults {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertRingViewCount:3];
  [GSCXScannerTestUtils assertCarouselSelectedCellAtIndex:0];
  [[self gscxtest_selectCarouselCellAtIndex:1] performAction:grey_tap()];
  [GSCXScannerTestUtils assertRingViewCount:3];
  [GSCXScannerTestUtils assertCarouselSelectedCellAtIndex:1];
  [[GSCXScannerTestUtils selectRingViewAtIndex:0] performAction:grey_tap()];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:kGSCXScanResultsBackButtonTitle];
  [[GSCXScannerTestUtils selectRingViewAtIndex:1] performAction:grey_tap()];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:kGSCXScanResultsBackButtonTitle];
  [[GSCXScannerTestUtils selectRingViewAtIndex:2] performAction:grey_tap()];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:NO];
}

- (void)testScreenshotViewCanShareResults {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapShareReportButton];
  [GSCXScannerTestUtils tapCancelMockShareReportButton];
}

- (void)testNextAndBackButtonsUpdateResults {
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  // Scan twice on different pages so there are multiple scans to display, each with a different
  // number of issues.
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [self gscxtest_assertScanNumberLabelHasIndex:0 issueCountLabelHasIssueCount:0];
  [GSCXScannerTestUtils tapNextContinuousScanResultButton];
  [self gscxtest_assertScanNumberLabelHasIndex:1 issueCountLabelHasIssueCount:4];
  // Test that tapping the next button when on the last scan result wraps to the beginning.
  [GSCXScannerTestUtils tapNextContinuousScanResultButton];
  [self gscxtest_assertScanNumberLabelHasIndex:0 issueCountLabelHasIssueCount:0];
  // Test that tapping the back button when on the first scan result wraps to the end.
  [GSCXScannerTestUtils tapBackContinuousScanResultButton];
  [self gscxtest_assertScanNumberLabelHasIndex:1 issueCountLabelHasIssueCount:4];
  [GSCXScannerTestUtils tapBackContinuousScanResultButton];
  [self gscxtest_assertScanNumberLabelHasIndex:0 issueCountLabelHasIssueCount:0];
}

#pragma mark - Private

/**
 * Selects a cell in the carousel view at the given index. @c index is the index path of the cell,
 * not the absolute index of the cell on screen. For example, if the user has scrolled so the first
 * visible cell has index path 4, @c index should be @c 4, not @c 0.
 *
 * @param index The index of the cell to select. Corresponds to the cell's index path.
 * @return The result of selecting the given cell.
 */
- (GREYElementInteraction *)gscxtest_selectCarouselCellAtIndex:(NSInteger)index {
  NSString *accessibilityIdentifier =
      [GSCXScannerResultCarousel accessibilityIdentifierForCellAtIndex:index];
  return [EarlGrey selectElementWithMatcher:grey_accessibilityID(accessibilityIdentifier)];
}

/**
 * Asserts that the scan index label displays text corresponding to @c scanIndex and the issue count
 * label displays text corresponding to @c issueCount. Fails the test if either are false.
 *
 * @param scanIndex The index of the currently displayed scan.
 * @param issueCount The number of issues in the currently displayed scan.
 */
- (void)gscxtest_assertScanNumberLabelHasIndex:(NSInteger)scanIndex
                  issueCountLabelHasIssueCount:(NSInteger)issueCount {
  NSString *scanLabelText =
      [GSCXContinuousScannerScreenshotViewController gscx_scanNumberTextForScanAtIndex:scanIndex];
  NSString *issueCountText =
      [GSCXContinuousScannerScreenshotViewController gscx_issueCountTextForIssueCount:issueCount];
  [[EarlGrey selectElementWithMatcher:grey_text(scanLabelText)] assertWithMatcher:grey_notNil()];
  [[EarlGrey selectElementWithMatcher:grey_text(issueCountText)] assertWithMatcher:grey_notNil()];
}

@end

NS_ASSUME_NONNULL_END
