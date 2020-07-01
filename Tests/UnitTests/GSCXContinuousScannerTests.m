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

#import "GSCXContinuousScanner.h"

#import "GSCXActivitySourceMonitoring.h"
#import "GSCXContinuousScannerDelegate.h"
#import "GSCXContinuousScannerScheduling.h"
#import "third_party/objective_c/GSCXScanner/Tests/Common/GSCXManualScheduler.h"
#import "GSCXScannerTestsUtils.h"
#import "GSCXTestActivitySource.h"
#import "GSCXTestCheck.h"

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The accessibility identifier of the view with issues in the first view hierarchy.
 */
static NSString *const kGSCXContinuousScannerTestAccessibilityIdentifier1 =
    @"kGSCXContinuousScannerTestAccessibilityIdentifier1";

/**
 * The accessibility identifier of the view with issues in the second view hierarchy.
 */
static NSString *const kGSCXContinuousScannerTestAccessibilityIdentifier2 =
    @"kGSCXContinuousScannerTestAccessibilityIdentifier2";

@interface GSCXContinuousScannerTests : XCTestCase <GSCXContinuousScannerDelegate>

/**
 * The root view of a view hierarchy containing accessibility issues.
 */
@property(strong, nonatomic) UIView *rootViewWithIssues;

/**
 * The root view of a view hierarchy not containing accessibility issues.
 */
@property(strong, nonatomic) UIView *rootViewWithoutIssues;

/**
 * The root view of a view hierarchy containing accessibility issues, separate from
 * @c rootViewWithIssues.
 */
@property(strong, nonatomic) UIView *alternateRootViewWithIssues;

/**
 * The views the continuous scanner object should scan. It is the responsibility of each test case
 * to set this value before the first time the continuous scanner object performs a scan.
 */
@property(strong, nonatomic) NSArray<UIView *> *rootViewsToScan;

/**
 * An array of issues found in the view hierarchy with root @c rootViewWithIssues.
 */
@property(strong, nonatomic) NSArray<GSCXScannerIssue *> *issuesWithRootView;

/**
 * An array of issues found in the view hierarchy with root @c alternateRootViewWithIssues.
 */
@property(strong, nonatomic) NSArray<GSCXScannerIssue *> *issuesWithAlternateRootView;

/**
 * An array of issues found in the view hierarchies with roots @c rootViewWithIssues and
 * @c alternateRootViewWithIssues.
 */
@property(strong, nonatomic) NSArray<GSCXScannerIssue *> *issuesWithRootViewAndAlternateRootView;

/**
 * The underlying scanner used to scan views for accessiblity issues. The only registered check is a
 * @c GSCXTestCheck instance.
 */
@property(strong, nonatomic) GSCXScanner *manualScanner;

/**
 * A stubbed @c GSCXContinuousScannerScheduling instance. Tests can manually force scans to be
 * scheduled by calling @c triggerScheduleScanEvent.
 */
@property(strong, nonatomic) GSCXManualScheduler *scheduler;

/**
 * An array of scan results. When constructing a continuous scanner object, set this test case as
 * the delegate. When scans are performed, the results are appended to this list.
 */
@property(strong, nonatomic) NSArray<GSCXScannerResult *> *scanResults;

/**
 * The continuous scanner object under test.
 */
@property(strong, nonatomic) GSCXContinuousScanner *scanner;

@end

@implementation GSCXContinuousScannerTests

- (void)setUpRootViews {
  // Views without a window are ignored.
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];

  self.rootViewWithIssues = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  UIView *subRootViewWithIssues = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
  subRootViewWithIssues.isAccessibilityElement = YES;
  subRootViewWithIssues.tag = kGSCXTestCheckFailingElementTag;
  subRootViewWithIssues.accessibilityIdentifier =
      kGSCXContinuousScannerTestAccessibilityIdentifier1;
  [self.rootViewWithIssues addSubview:subRootViewWithIssues];
  [window addSubview:self.rootViewWithIssues];

  self.rootViewWithoutIssues = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  UIView *subRootViewWithoutIssues = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  subRootViewWithoutIssues.isAccessibilityElement = YES;
  [self.rootViewWithoutIssues addSubview:subRootViewWithoutIssues];
  [window addSubview:self.rootViewWithoutIssues];

  self.alternateRootViewWithIssues = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  UIView *subMiddleViewWithIssues = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
  [self.alternateRootViewWithIssues addSubview:subMiddleViewWithIssues];
  [window addSubview:self.alternateRootViewWithIssues];
  UIView *subAlternateRootViewWithIssues =
      [[UIView alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
  subAlternateRootViewWithIssues.isAccessibilityElement = YES;
  subAlternateRootViewWithIssues.tag = kGSCXTestCheckFailingElementTag;
  subAlternateRootViewWithIssues.accessibilityIdentifier =
      kGSCXContinuousScannerTestAccessibilityIdentifier2;
  [subMiddleViewWithIssues addSubview:subAlternateRootViewWithIssues];

  self.rootViewsToScan = @[];
}

- (void)setUpIssues {
  // GTX adds additional information to the description after running checks. This happens
  // internally, so there is no way to access this change. Thus, we have to duplicate it here and
  // hardcode the extra text. This makes the tests brittle. Changes in GTX could break these tests.
  NSString *testDescription = [NSString
      stringWithFormat:@"Check \"%@\" failed, %@", kGSCXTestCheckName, kGSCXTestCheckDescription];
  self.issuesWithRootView = @[ [GSCXScannerIssue
          issueWithCheckNames:@[ kGSCXTestCheckName ]
            checkDescriptions:@[ testDescription ]
               elementAddress:0
                 elementClass:[UIView class]
          frameInScreenBounds:CGRectZero
           accessibilityLabel:nil
      accessibilityIdentifier:kGSCXContinuousScannerTestAccessibilityIdentifier1] ];
  self.issuesWithAlternateRootView = @[ [GSCXScannerIssue
          issueWithCheckNames:@[ kGSCXTestCheckName ]
            checkDescriptions:@[ testDescription ]
               elementAddress:0
                 elementClass:[UIView class]
          frameInScreenBounds:CGRectZero
           accessibilityLabel:nil
      accessibilityIdentifier:kGSCXContinuousScannerTestAccessibilityIdentifier2] ];
  self.issuesWithRootViewAndAlternateRootView = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXTestCheckName ]
                        checkDescriptions:@[ testDescription ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:CGRectZero
                       accessibilityLabel:nil
                  accessibilityIdentifier:kGSCXContinuousScannerTestAccessibilityIdentifier1],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXTestCheckName ]
                        checkDescriptions:@[ testDescription ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:CGRectZero
                       accessibilityLabel:nil
                  accessibilityIdentifier:kGSCXContinuousScannerTestAccessibilityIdentifier2]
  ];
}

- (void)setUpScanner {
  id<GTXChecking> dummyCheck = [GSCXTestCheck testCheck];
  self.manualScanner = [GSCXScanner scannerWithChecks:@[ dummyCheck ] blacklists:@[]];
  self.scheduler = [[GSCXManualScheduler alloc] init];
  self.scanResults = @[];
  self.scanner = [GSCXContinuousScanner scannerWithScanner:self.manualScanner
                                                  delegate:self
                                                 scheduler:self.scheduler];
}

- (void)setUp {
  [super setUp];

  [self setUpRootViews];
  [self setUpIssues];
  [self setUpScanner];
}

- (void)testContinuousScannerPerformsScanOnlyWhenScanning {
  self.rootViewsToScan = @[ self.rootViewWithIssues ];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 0);
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 1);
  XCTAssertEqual([self.scanResults[0] issueCount], 1);
}

- (void)testContinuousScannerPerformsScanWhenScanningMultipleRootViews {
  self.rootViewsToScan = @[ self.rootViewWithIssues, self.alternateRootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 2);
  XCTAssertEqual([self.scanResults[0] issueCount], 2);
}

- (void)testContinuousScannerPerformsScanWhenScanningNoIssues {
  self.rootViewsToScan = @[ self.rootViewWithoutIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 0);
  XCTAssertEqual([self.scanResults[0] issueCount], 0);
}

- (void)testContinuousScannerPerformsScanWhenScanningOneWithIssuesOneWithoutIssues {
  self.rootViewsToScan = @[ self.rootViewWithIssues, self.rootViewWithoutIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 1);
  XCTAssertEqual([self.scanResults[0] issueCount], 1);
}

- (void)testContinuousScannerPerformsScanWhenScanningManyWithIssuesOneWithoutIssues {
  self.rootViewsToScan =
      @[ self.rootViewWithIssues, self.rootViewWithoutIssues, self.alternateRootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 2);
  XCTAssertEqual([self.scanResults[0] issueCount], 2);
}

- (void)testContinuousScannerPerformsScanWhenScanningNotWhenStoppedScanning {
  self.rootViewsToScan = @[ self.rootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  [self.scanner stopScanning];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 1);
  XCTAssertEqual([self.scanResults[0] issueCount], 1);
}

- (void)testContinuousScannerClearsAndPerformsScanWhenRestartingScanning {
  self.rootViewsToScan = @[ self.rootViewWithIssues ];
  [self.scanner startScanning];
  XCTAssertEqual(self.scanResults.count, 0);
  [self.scheduler triggerScheduleScanEvent];
  // A scan event occurred while the continuous scanner is scheduling. A scan should occur.
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 1);
  XCTAssertEqual([self.scanResults[0] issueCount], 1);
  [self.scanner stopScanning];
  [self.scheduler triggerScheduleScanEvent];
  // A scan event occurred while the continuous scanner is not scheduling. No scan should occur.
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 1);
  XCTAssertEqual([self.scanResults[0] issueCount], 1);
  [self.scanner startScanning];
  // Starting scanning should clear out the previous scan results.
  XCTAssertEqual(self.scanResults.count, 0);
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 1);
  XCTAssertEqual(self.scanner.issueCount, 1);
  XCTAssertEqual([self.scanResults[0] issueCount], 1);
}

- (void)testContinuousScannerPerformsScanMultipleElementsWithMultipleIssues {
  id<GTXChecking> dummyCheck1 = [GSCXTestCheck testCheck];
  id<GTXChecking> dummyCheck2 = [GSCXTestCheck duplicateTestCheck];
  self.manualScanner = [GSCXScanner scannerWithChecks:@[ dummyCheck1, dummyCheck2 ] blacklists:@[]];
  self.scheduler = [[GSCXManualScheduler alloc] init];
  self.scanResults = @[];
  self.scanner = [GSCXContinuousScanner scannerWithScanner:self.manualScanner
                                                  delegate:self
                                                 scheduler:self.scheduler];
  self.rootViewsToScan = @[ self.rootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  self.rootViewsToScan = @[ self.rootViewWithoutIssues ];
  [self.scheduler triggerScheduleScanEvent];
  self.rootViewsToScan =
      @[ self.rootViewWithIssues, self.rootViewWithoutIssues, self.alternateRootViewWithIssues ];
  [self.scheduler triggerScheduleScanEvent];
  XCTAssertEqual(self.scanResults.count, 3);
  XCTAssertEqual(self.scanner.issueCount, 6);
  XCTAssertEqual([self.scanResults[0] issueCount], 2);
  XCTAssertEqual([self.scanResults[1] issueCount], 0);
  XCTAssertEqual([self.scanResults[2] issueCount], 4);
}

- (void)testContinuousScannerUniqueIssuesOneResultEmpty {
  self.rootViewsToScan = @[ self.rootViewWithoutIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = @[];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testContinuousScannerUniqueIssuesManyResultsEmpty {
  self.rootViewsToScan = @[ self.rootViewWithoutIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = @[];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testContinuousScannerUniqueIssuesOneResultOneIssue {
  self.rootViewsToScan = @[ self.rootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = self.issuesWithRootView;
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testContinuousScannerUniqueIssuesOneResultMultipleIssues {
  self.rootViewsToScan =
      @[ self.rootViewWithIssues, self.rootViewWithoutIssues, self.alternateRootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = self.issuesWithRootViewAndAlternateRootView;
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testContinuousScannerUniqueIssuesMultipleResultsOneIssuePerResultSame {
  self.rootViewsToScan = @[ self.rootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = self.issuesWithRootView;
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testContinuousScannerUniqueIssuesMultipleResultsOneIssuePerResultDifferent {
  self.rootViewsToScan = @[ self.rootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  self.rootViewsToScan = @[ self.alternateRootViewWithIssues ];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = self.issuesWithRootViewAndAlternateRootView;
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testContinuousScannerUniqueIssuesMultipleResultsMultipleIssuePerResultSame {
  self.rootViewsToScan = @[ self.rootViewWithIssues, self.alternateRootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = self.issuesWithRootViewAndAlternateRootView;
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testContinuousScannerUniqueIssuesMultipleResultsMultipleIssuesPerResultDifferent {
  self.rootViewsToScan = @[ self.rootViewWithIssues, self.rootViewWithIssues ];
  [self.scanner startScanning];
  [self.scheduler triggerScheduleScanEvent];
  self.rootViewsToScan = @[ self.alternateRootViewWithIssues, self.alternateRootViewWithIssues ];
  [self.scheduler triggerScheduleScanEvent];
  NSArray<GSCXScannerIssue *> *result = [self.scanner uniqueIssues];
  NSArray<GSCXScannerIssue *> *expected = self.issuesWithRootViewAndAlternateRootView;
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

#pragma mark - GSCXContinuousScannerDelegate

- (void)continuousScannerWillStart:(GSCXContinuousScanner *)scanner {
  self.scanResults = @[];
}

- (void)continuousScanner:(GSCXContinuousScanner *)scanner
    didPerformScanWithResult:(GSCXScannerResult *)result {
  self.scanResults = [self.scanResults arrayByAddingObject:result];
}

@end

NS_ASSUME_NONNULL_END
