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
#import "GSCXScannerSettingsViewController.h"
#import "GSCXTestAppDelegate.h"
#import "GSCXTestScannerViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The number of seconds between scheduled scans. This must be greater than the default because the
 * default does not allow enough time for some tests to pass. Depending on the animation
 * synchronization, a scan may or may not occur in between certain actions. This causes flakiness.
 * Increasing the time interval between scans solves this.
 */
static const NSTimeInterval kGSCXContinuousScannerTestsTimeInterval = 4.0;

/**
 * The number of seconds to wait between polls when waiting on a condition. This prevents the main
 * thread from slowing due to repeated polls.
 */
static const NSTimeInterval kGSCXContinuousScannerTestsPollInterval = 0.5;

/**
 * The name of the @c GREYCondition instance waiting for the settings page to be dismissed.
 */
static NSString *const kGSCXContinuousScannerDismissSettingsConditionName = @"dismiss settings";

@interface GSCXContinuousScannerTests : XCTestCase

/**
 * Runs the test harness app.
 */
@property(strong, nonatomic) XCUIApplication *application;

@end

@implementation GSCXContinuousScannerTests

- (void)setUp {
  [super setUp];
  // Launch a new application for each test case because the continuous scanner has global state.
  // Scans from previous test cases would propagate to later test cases unless a new application is
  // launched for each test case.
  self.application = [[XCUIApplication alloc] init];
  [self.application launch];
}

- (void)tearDown {
  [self.application terminate];
  [super tearDown];
}

- (void)testContinuousScanningSwitchIsReachable {
  [GSCXScannerTestUtils assertContinuousScanSwitchIsInteractable:NO];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertContinuousScanSwitchIsInteractable:YES];
}

- (void)testNoIssuesFoundLabelExistsBeforeScanning {
  [GSCXScannerTestUtils tapSettingsButton];
  [self _assertNoIssuesFoundItemExists];
}

- (void)testContinuousScanningSwitchStatePersistsWhenReopeningSettings {
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertContinuousScanSwitchIsOn:NO];
  [GSCXScannerTestUtils toggleContinuousScanSwitch];
  [GSCXScannerTestUtils assertContinuousScanSwitchIsOn:YES];
  [GSCXScannerTestUtils dismissSettingsPage];

  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertContinuousScanSwitchIsOn:YES];
  [GSCXScannerTestUtils toggleContinuousScanSwitch];
  [GSCXScannerTestUtils assertContinuousScanSwitchIsOn:NO];
  [GSCXScannerTestUtils dismissSettingsPage];

  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertContinuousScanSwitchIsOn:NO];
}

- (void)testContinuousScannerDoesNotScanBeforeBeingScheduled {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [self _assertNoIssuesFoundItemExists];
  [self _assertReportButtonItemDoesNotExist];
  [GSCXScannerTestUtils toggleContinuousScanSwitch];
  [GSCXScannerTestUtils dismissSettingsPage];

  [GSCXScannerTestUtils tapSettingsButton];
  [self _assertNoIssuesFoundItemExists];
  [self _assertReportButtonItemDoesNotExist];
}

- (void)testContinuousScannerWorksWithZeroIssues {
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils toggleContinuousScanSwitch];
  [GSCXScannerTestUtils dismissSettingsPage];
  [self _waitForScan];
  [GSCXScannerTestUtils tapSettingsButton];
  [self _assertNoIssuesFoundItemExists];
  [self _assertReportButtonItemDoesNotExist];
}

- (void)testContinuousScannerCanFindIssues {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils toggleContinuousScanSwitch];
  [GSCXScannerTestUtils dismissSettingsPage];
  [self _waitForScan];
  [GSCXScannerTestUtils tapSettingsButton];
  [self _assertNoIssuesFoundItemDoesNotExist];
  [self _assertReportButtonItemExists];
}

- (void)testContinuousScanCanGenerateReport {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils toggleContinuousScanSwitch];
  [GSCXScannerTestUtils dismissSettingsPage];
  [self _waitForScan];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapReportButton];
  // TODO(144873587): Assert that specific text appears in the report. Once b/144873587 is fixed,
  // this test should be able to access the text in the report.
  [GSCXScannerTestUtils dismissContinuousScanReport];
  [GSCXScannerTestUtils dismissSettingsPage];
}

#pragma mark - Private

/**
 * Pauses the test until the settings page is dismissed and triggers a scan.
 */
- (void)_waitForScan {
  GREYCondition *waitToDismissSettings = [GREYCondition
      conditionWithName:kGSCXContinuousScannerDismissSettingsConditionName
                  block:^BOOL {
                    NSError *error;
                    [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES error:&error];
                    return error == nil;
                  }];
  BOOL wasSettingsDismissed =
      [waitToDismissSettings waitWithTimeout:kGSCXContinuousScannerTestsTimeInterval
                                pollInterval:kGSCXContinuousScannerTestsPollInterval];
  XCTAssert(wasSettingsDismissed);
  [(GSCXTestAppDelegate *)[[GREY_REMOTE_CLASS_IN_APP(UIApplication) sharedApplication] delegate]
      triggerScheduleScanEvent];
}

/**
 * Asserts that the no issues found settings item exists. Fails the test if it does not.
 */
- (void)_assertNoIssuesFoundItemExists {
  GREYAssert([GSCXScannerTestUtils noIssuesFoundItemExists],
             @"No issues found settings item should exist but does not.");
}

/**
 * Asserts that the no issues found settings item does not exist. Fails the test if it does.
 */
- (void)_assertNoIssuesFoundItemDoesNotExist {
  GREYAssertFalse([GSCXScannerTestUtils noIssuesFoundItemExists],
                  @"No issues found settings item should exist not but does.");
}

/**
 * Asserts that the report button settings item exists. Fails the test if it does not.
 */
- (void)_assertReportButtonItemExists {
  GREYAssert([GSCXScannerTestUtils reportButtonItemExists],
             @"Report button settings item should exist but does not.");
}

/**
 * Asserts that the report button settings item does not exist. Fails the test if it does.
 */
- (void)_assertReportButtonItemDoesNotExist {
  GREYAssertFalse([GSCXScannerTestUtils reportButtonItemExists],
                  @"Report button settings item should not exist but does.");
}

@end

NS_ASSUME_NONNULL_END
