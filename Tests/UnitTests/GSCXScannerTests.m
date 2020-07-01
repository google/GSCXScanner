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
#import <XCTest/XCTest.h>

#import "GSCXScanner.h"
#import "GSCXTestCheck.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

static const CGRect kGSCXScannerTestsRootViewFrame = {{10, 100}, {1, 1}};

static const CGRect kGSCXScannerTestsFailingElementFrame1 = {{1, 2}, {3, 4}};

static const CGRect kGSCXScannerTestsFailingElementFrame2 = {{5, 6}, {7, 8}};

@interface GSCXScannerTests : XCTestCase <GSCXScannerDelegate>

/**
 * A GTXChecking object that marks elements as having accessibility issues if their tag is equal to
 * @c kGSCXScannerDummyCheckTag.
 */
@property(strong, nonatomic) id<GTXChecking> dummyCheck;

/**
 * Provides the implementation for the scannerWillBeginScan: method. Tests can set
 * this property to control the functionality of the delegate.
 */
@property(assign, nonatomic) void (^scannerWillBeginScanBlock)(GSCXScanner *);

/**
 * Provides the implementation for the scanner:didFinishScanWithResult: method. Tests can
 * set this property to control the functionality of the delegate.
 */
@property(assign, nonatomic) void (^scannerDidFinishScanWithResult)
    (GSCXScanner *, GSCXScannerResult *);

/**
 * Returns a UIView whose @c isAccessible property is YES and whose tag is
 * @c kGSCXScannerDummyCheckTag, so it fails @c dummyCheck.
 */
+ (UIView *)gscxtest_checkFailingAccessibleView;

@end

@implementation GSCXScannerTests

- (void)setUp {
  [super setUp];
  self.dummyCheck = [GSCXTestCheck testCheck];
}

- (void)testScanRootViewsDoesNotInvokeDelegateMethodsWhenDelegateIsNil {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  __block BOOL scannerWillBeginScanWasCalled = NO;
  __block BOOL scannerDidFinishScanWithResultWasCalled = NO;
  self.scannerWillBeginScanBlock = ^(GSCXScanner *scanner) {
    scannerWillBeginScanWasCalled = YES;
  };
  self.scannerDidFinishScanWithResult = ^(GSCXScanner *scanner, GSCXScannerResult *result) {
    scannerDidFinishScanWithResultWasCalled = YES;
  };

  UIView *rootView = [[UIView alloc] initWithFrame:CGRectZero];
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [window addSubview:rootView];
  [scanner scanRootViews:@[ rootView ]];

  XCTAssertFalse(scannerWillBeginScanWasCalled);
  XCTAssertFalse(scannerDidFinishScanWithResultWasCalled);
}

- (void)testScanRootViewsInvokesDelegateMethodsInCorrectOrder {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  scanner.delegate = self;
  __block BOOL scannerWillBeginScanWasCalled = NO;
  __block BOOL scannerDidFinishScanWithResultWasCalled = NO;
  __weak GSCXScannerTests *weakSelf = self;
  self.scannerWillBeginScanBlock = ^(GSCXScanner *scanner) {
    // Shadow self with a local variable self because XCTAssert macros use self, which causes a
    // retain cycle because the block captures a reference to it.
    GSCXScannerTests *self = weakSelf;
    XCTAssertFalse(scannerWillBeginScanWasCalled);
    XCTAssertFalse(scannerDidFinishScanWithResultWasCalled);
    scannerWillBeginScanWasCalled = YES;
  };
  self.scannerDidFinishScanWithResult = ^(GSCXScanner *scanner, GSCXScannerResult *result) {
    GSCXScannerTests *self = weakSelf;
    XCTAssertTrue(scannerWillBeginScanWasCalled);
    XCTAssertFalse(scannerDidFinishScanWithResultWasCalled);
    scannerDidFinishScanWithResultWasCalled = YES;
  };

  UIView *rootView = [[UIView alloc] initWithFrame:CGRectZero];
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [window addSubview:rootView];
  [scanner scanRootViews:@[ rootView ]];

  XCTAssertTrue(scannerWillBeginScanWasCalled);
  XCTAssertTrue(scannerDidFinishScanWithResultWasCalled);

  scanner.delegate = nil;
}

- (void)testScanRootViewsWithNoAccessibilityIssuesCreatesEmptyResult {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [[UIView alloc] initWithFrame:kGSCXScannerTestsRootViewFrame];
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [window addSubview:rootView];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 0ul);
}

- (void)testScanRootViewsWithSingleAccessibilityIssueCreatesResultWithSingleIssue {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [[UIView alloc] initWithFrame:kGSCXScannerTestsRootViewFrame];
  UIView *viewWithIssue = [GSCXScannerTests gscxtest_checkFailingAccessibleView];
  [rootView addSubview:viewWithIssue];
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [window addSubview:rootView];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  CGRect expectedFrame = rootView.accessibilityFrame;
  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 1ul);
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXTestCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], expectedFrame));
}

- (void)testScanRootViewsWithMultipleAccessibilityIssuesCreatesResultWithMultipleIssues {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [[UIView alloc] initWithFrame:kGSCXScannerTestsRootViewFrame];
  UIView *viewWithIssue1 = [GSCXScannerTests gscxtest_checkFailingAccessibleView];
  UIView *viewWithIssue2 = [GSCXScannerTests gscxtest_checkFailingAccessibleView];
  viewWithIssue2.frame = kGSCXScannerTestsFailingElementFrame2;
  [rootView addSubview:viewWithIssue1];
  [rootView addSubview:viewWithIssue2];
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [window addSubview:rootView];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  CGRect expectedFrame1 = viewWithIssue1.accessibilityFrame;
  CGRect expectedFrame2 = viewWithIssue2.accessibilityFrame;
  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 2ul);
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXTestCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], expectedFrame1));
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:1], kGSCXTestCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:1], expectedFrame2));
}

- (void)testScanRootViewsWithAccessibilityIssueOnRootView {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [GSCXScannerTests gscxtest_checkFailingAccessibleView];
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [window addSubview:rootView];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  CGRect expectedFrame = rootView.accessibilityFrame;
  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 1ul);
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXTestCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], expectedFrame));
}

- (void)testDeregisteringRegisteredCheckDoesNotCheckElements {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  [scanner deregisterCheck:self.dummyCheck];
  [self gscxtest_assertIssueCountOnViewWithIssue:0 withScanner:scanner];
}

- (void)testCanReregisterDeregisteredCheck {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  [scanner deregisterCheck:self.dummyCheck];
  [scanner registerCheck:self.dummyCheck];
  [self gscxtest_assertIssueCountOnViewWithIssue:1 withScanner:scanner];
}

- (void)testDeregisteringUnregisteredCheckDoesNothing {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner deregisterCheck:self.dummyCheck];
  [self gscxtest_assertIssueCountOnViewWithIssue:0 withScanner:scanner];
}

- (void)testBlacklistDoesSkipElement {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  id<GTXBlacklisting> blacklist = [GTXBlacklistBlock
      blacklistWithBlock:^BOOL(id _Nonnull element, NSString *_Nonnull checkName) {
        return YES;
      }];
  [scanner registerBlacklist:blacklist];
  [self gscxtest_assertIssueCountOnViewWithIssue:0 withScanner:scanner];
}

- (void)testDeregisteringBlacklistDoesNotSkipElement {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  id<GTXBlacklisting> blacklist = [GTXBlacklistBlock
      blacklistWithBlock:^BOOL(id _Nonnull element, NSString *_Nonnull checkName) {
        return YES;
      }];
  [scanner registerBlacklist:blacklist];
  [scanner deregisterBlacklist:blacklist];
  [self gscxtest_assertIssueCountOnViewWithIssue:1 withScanner:scanner];
}

- (void)testCanReregisterDeregisteredBlacklist {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  id<GTXBlacklisting> blacklist = [GTXBlacklistBlock
      blacklistWithBlock:^BOOL(id _Nonnull element, NSString *_Nonnull checkName) {
        return YES;
      }];
  [scanner registerBlacklist:blacklist];
  [scanner deregisterBlacklist:blacklist];
  [scanner registerBlacklist:blacklist];
  [self gscxtest_assertIssueCountOnViewWithIssue:0 withScanner:scanner];
}

- (void)testDeregisteringUnregisteredBlacklistDoesNothing {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  id<GTXBlacklisting> blacklist = [GTXBlacklistBlock
      blacklistWithBlock:^BOOL(id _Nonnull element, NSString *_Nonnull checkName) {
        return YES;
      }];
  [scanner deregisterBlacklist:blacklist];
  [self gscxtest_assertIssueCountOnViewWithIssue:1 withScanner:scanner];
}

#pragma mark - GSCXScannerDelegate

- (void)scannerWillBeginScan:(GSCXScanner *)scanner {
  self.scannerWillBeginScanBlock(scanner);
}

- (void)scanner:(GSCXScanner *)scanner didFinishScanWithResult:(GSCXScannerResult *)scanResult {
  self.scannerDidFinishScanWithResult(scanner, scanResult);
}

#pragma mark - Private

+ (UIView *)gscxtest_checkFailingAccessibleView {
  UIView *viewWithIssue = [[UIView alloc] initWithFrame:kGSCXScannerTestsFailingElementFrame1];
  viewWithIssue.tag = kGSCXTestCheckFailingElementTag;
  viewWithIssue.isAccessibilityElement = YES;
  return viewWithIssue;
}

/**
 * Constructs a view hierarchy containing a view failing @c self.dummyCheck and runs @c scanner on
 * it. Passes the test if the number of issues found is equal to @c count, fails otherwise.
 *
 * @param count The number of issues @c scanner should find in the view hierarchy.
 * @param scanner Scans the view hierarchy for accessibility issues.
 */
- (void)gscxtest_assertIssueCountOnViewWithIssue:(NSUInteger)count
                                     withScanner:(GSCXScanner *)scanner {
  UIView *rootView = [[UIView alloc] initWithFrame:kGSCXScannerTestsRootViewFrame];
  UIView *viewWithIssue = [GSCXScannerTests gscxtest_checkFailingAccessibleView];
  [rootView addSubview:viewWithIssue];
  UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
  [window addSubview:rootView];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  XCTAssertEqual(result.issueCount, count);
}

@end

NS_ASSUME_NONNULL_END
