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

#import "GSCXContinuousScannerListTabBarViewController.h"

#import <XCTest/XCTest.h>

#import "GSCXContinuousScannerScreenshotViewController.h"
#import "GSCXTestScannerViewController.h"
#import "GSCXTestUIAccessibilityElementViewController.h"
#import "GSCXTestViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScannerListTabBarViewControllerTests : XCTestCase
@end

@implementation GSCXContinuousScannerListTabBarViewControllerTests

- (void)setUp {
  [super setUp];
  [[[XCUIApplication alloc] init] launch];
}

- (void)testCanSwitchBetweenGroupingMethodsWithTabsOneScan {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [self gscxtest_testCanSwitchBetweenGroupingMethodsWithScanCount:1 uniqueIssuesPerScan:4];
}

- (void)testCanSwitchBetweenGroupingMethodsWithTabsManyScans {
  [GSCXScannerTestUtils openPage:[GSCXTestUIAccessibilityElementViewController class]];
  [self gscxtest_testCanSwitchBetweenGroupingMethodsWithScanCount:3 uniqueIssuesPerScan:2];
}

#pragma mark - Private

/**
 * Tests the tab bar list view can switch between tabs. Performs @c scanCount scans on the current
 * screen, then opens the list view and performs assertions. Fails the test if the list view can't
 * be opened or if the wrong number of sections are in each tab.
 *
 * @param scanCount The number of scans to perform before opening the list view.
 * @param uniqueIssuesPerScan The number of unique accessibility issues in the screen to be scanned.
 */
- (void)gscxtest_testCanSwitchBetweenGroupingMethodsWithScanCount:(NSInteger)scanCount
                                              uniqueIssuesPerScan:(NSInteger)uniqueIssuesPerScan {
  [self gscxtest_openIssuesListByScanningNumberOfTimes:scanCount];
  [GSCXScannerTestUtils assertListSectionCount:scanCount];
  [GSCXScannerTestUtils
      tapTabBarButtonWithTitle:kGSCXContinuousScannerScreenshotListByCheckTabBarItemTitle];
  [GSCXScannerTestUtils assertListSectionCount:uniqueIssuesPerScan];
  [GSCXScannerTestUtils
      tapTabBarButtonWithTitle:kGSCXContinuousScannerScreenshotListByScanTabBarItemTitle];
  [GSCXScannerTestUtils assertListSectionCount:scanCount];
  [GSCXScannerTestUtils
      tapTabBarButtonWithTitle:kGSCXContinuousScannerScreenshotListByCheckTabBarItemTitle];
}

/**
 * Performs @c scanCount scans on the current screen, then opens the list view. Fails the test if
 * the list view cannot be opened.
 *
 * @param scanCount The number of scans to perform.
 */
- (void)gscxtest_openIssuesListByScanningNumberOfTimes:(NSInteger)scanCount {
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  for (NSInteger i = 0; i < scanCount; i++) {
    XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  }
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapListButton];
}

@end

NS_ASSUME_NONNULL_END
