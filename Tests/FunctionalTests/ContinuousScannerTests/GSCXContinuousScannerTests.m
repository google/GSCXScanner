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

#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/ContinuousScannerTests/GSCXContinuousScannerTestCase.h"

#import <XCTest/XCTest.h>

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXContinuousScannerScreenshotViewController.h"
#import "GSCXScannerSettingsViewController.h"
#import "GSCXTestAppDelegate.h"
#import "GSCXTestScannerViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScannerTests : GSCXContinuousScannerTestCase
@end

@implementation GSCXContinuousScannerTests

- (void)testContinuousScanningSwitchIsReachable {
  [GSCXScannerTestUtils assertContinuousScanButtonIsInteractable:NO];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertContinuousScanButtonIsInteractable:YES];
}

- (void)testContinuousScannerDoesNotScanBeforeBeingScheduled {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils dismissNoIssuesAlert];
}

- (void)testContinuousScannerWorksWithZeroIssues {
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils dismissNoIssuesAlert];
}

- (void)testContinuousScannerCanFindIssues {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [self gscxtest_assertResultsPageIsVisible];
}

- (void)testContinuousScanCanGenerateReport {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  // TODO: Assert that specific text appears in the report. Once fixed, this test
  // should be able to access the text in the report.
  [GSCXScannerTestUtils dismissContinuousScanReport];
}

#pragma mark - Private

/**
 * Asserts that the continuous scanner results page is visible.
 */
- (void)gscxtest_assertResultsPageIsVisible {
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXScannerResultCarouselAccessibilityIdentifier)]
      assertWithMatcher:grey_notNil()];
}

@end

NS_ASSUME_NONNULL_END
