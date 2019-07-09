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
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

static NSString *const kGSCXScannerTestsDummyCheckName = @"kGSCXScannerTestsDummyCheckName";
static const NSInteger kGSCXScannerTestsFailingElementTag = 127;
static const CGRect kGSCXScannerTestsRootViewFrame = {{10, 100}, {1, 1}};
static const CGRect kGSCXScannerTestsFailingElementFrame1 = {{1, 2}, {3, 4}};
static const CGRect kGSCXScannerTestsFailingElementFrame2 = {{5, 6}, {7, 8}};

@interface GSCXScannerTests : XCTestCase <GSCXScannerDelegate>

/**
 *  A GTXChecking object that marks elements as having accessibility issues if their tag is equal to
 *  @c kGSCXScannerDummyCheckTag.
 */
@property(strong, nonatomic) id<GTXChecking> dummyCheck;
/**
 *  Provides the implementation for the scannerWillBeginScan: method. Tests can set this property to
 *  control the functionality of the delegate.
 */
@property(assign, nonatomic) void (^scannerWillBeginScanBlock)(GSCXScanner *);
/**
 *  Provides the implementation for the scanner:didFinishScanWithResult: method. Tests can set this
 *  property to control the functionality of the delegate.
 */
@property(assign, nonatomic) void (^scannerDidFinishScanWithResult)
    (GSCXScanner *, GSCXScannerResult *);

/**
 *  Returns a UIView whose @c isAccessible property is YES and whose tag is
 *  @c kGSCXScannerDummyCheckTag, so it fails @c dummyCheck.
 */
+ (UIView *)_checkFailingAccessibleView;

@end

@implementation GSCXScannerTests

- (void)setUp {
  [super setUp];

  self.dummyCheck = [GTXCheckBlock
      GTXCheckWithName:kGSCXScannerTestsDummyCheckName
                 block:^(id element, GTXErrorRefType _Nullable errorOrNil) {
                   if ([element tag] == kGSCXScannerTestsFailingElementTag) {
                     [NSError gtx_logOrSetGTXCheckFailedError:errorOrNil
                                                      element:element
                                                         name:kGSCXScannerTestsDummyCheckName
                                                  description:@"Dummy check failed."];
                     return NO;
                   } else {
                     return YES;
                   }
                 }];
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
  [scanner scanRootViews:@[ rootView ]];

  XCTAssertFalse(scannerWillBeginScanWasCalled);
  XCTAssertFalse(scannerDidFinishScanWithResultWasCalled);
}

- (void)testScanRootViewsInvokesDelegateMethodsInCorrectOrder {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];
  scanner.delegate = self;
  __block BOOL scannerWillBeginScanWasCalled;
  __block BOOL scannerDidFinishScanWithResultWasCalled;
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
  [scanner scanRootViews:@[ rootView ]];

  XCTAssertTrue(scannerWillBeginScanWasCalled);
  XCTAssertTrue(scannerDidFinishScanWithResultWasCalled);

  scanner.delegate = nil;
}

- (void)testScanRootViewsWithNoAccessibilityIssuesCreatesEmptyResult {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [[UIView alloc] initWithFrame:kGSCXScannerTestsRootViewFrame];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 0ul);
}

- (void)testScanRootViewsWithSingleAccessibilityIssueCreatesResultWithSingleIssue {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [[UIView alloc] initWithFrame:kGSCXScannerTestsRootViewFrame];
  UIView *viewWithIssue = [GSCXScannerTests _checkFailingAccessibleView];
  [rootView addSubview:viewWithIssue];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  CGRect expectedFrame = rootView.accessibilityFrame;
  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 1ul);
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerTestsDummyCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], expectedFrame));
}

- (void)testScanRootViewsWithMultipleAccessibilityIssuesCreatesResultWithMultipleIssues {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [[UIView alloc] initWithFrame:kGSCXScannerTestsRootViewFrame];
  UIView *viewWithIssue1 = [GSCXScannerTests _checkFailingAccessibleView];
  UIView *viewWithIssue2 = [GSCXScannerTests _checkFailingAccessibleView];
  viewWithIssue2.frame = kGSCXScannerTestsFailingElementFrame2;
  [rootView addSubview:viewWithIssue1];
  [rootView addSubview:viewWithIssue2];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  CGRect expectedFrame1 = viewWithIssue1.accessibilityFrame;
  CGRect expectedFrame2 = viewWithIssue2.accessibilityFrame;
  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 2ul);
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerTestsDummyCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], expectedFrame1));
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:1], kGSCXScannerTestsDummyCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:1], expectedFrame2));
}

- (void)testScanRootViewsWithAccessibilityIssueOnRootView {
  GSCXScanner *scanner = [GSCXScanner scanner];
  [scanner registerCheck:self.dummyCheck];

  UIView *rootView = [GSCXScannerTests _checkFailingAccessibleView];
  GSCXScannerResult *result = [scanner scanRootViews:@[ rootView ]];

  CGRect expectedFrame = rootView.accessibilityFrame;
  XCTAssertEqual(result, scanner.lastScanResult);
  XCTAssertEqual(result.issueCount, 1ul);
  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerTestsDummyCheckName);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], expectedFrame));
}

#pragma mark - GSCXScannerDelegate

- (void)scannerWillBeginScan:(GSCXScanner *)scanner {
  self.scannerWillBeginScanBlock(scanner);
}

- (void)scanner:(GSCXScanner *)scanner didFinishScanWithResult:(GSCXScannerResult *)scanResult {
  self.scannerDidFinishScanWithResult(scanner, scanResult);
}

#pragma mark - Private

+ (UIView *)_checkFailingAccessibleView {
  UIView *viewWithIssue = [[UIView alloc] initWithFrame:kGSCXScannerTestsFailingElementFrame1];
  viewWithIssue.tag = kGSCXScannerTestsFailingElementTag;
  viewWithIssue.isAccessibilityElement = YES;
  return viewWithIssue;
}

@end

NS_ASSUME_NONNULL_END
