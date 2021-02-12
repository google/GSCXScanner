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

#import "GSCXRingView.h"

/**
 * Accuracy of floating point comparisons for GSCXRingView tests.
 */
static const CGFloat kRingViewTestsComparisonAccuracy = 0.00001;

/**
 * Contains tests for GSCXRingView methods.
 */
@interface GSCXRingViewTests : XCTestCase
@end

@implementation GSCXRingViewTests

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrame {
  GSCXRingView *ringView =
      [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 44.0, 44.0)];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(8.0, 10.0, 48.0, 48.0)];
}

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrameWidthLargeAfterInset {
  GSCXRingView *ringView =
      [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 42.0, 44.0)];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(8.0, 10.0, 46.0, 48.0)];
}

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrameWidthSmall {
  GSCXRingView *ringView =
      [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 30.0, 44.0)];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(3.0, 10.0, 44.0, 48.0)];
}

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrameHeightLargeAfterInset {
  GSCXRingView *ringView =
      [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 44.0, 42.0)];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(8.0, 10.0, 48.0, 46.0)];
}

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrameHeightSmall {
  GSCXRingView *ringView =
      [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 44.0, 20.0)];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(8.0, 00.0, 48.0, 44.0)];
}

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrameWidthAndHeightLargeAfterInset {
  GSCXRingView *ringView =
      [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 42.0, 42.0)];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(8.0, 10.0, 46.0, 46.0)];
}

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrameWidthAndHeightTooSmall {
  GSCXRingView *ringView =
      [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 20.0, 30.0)];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(-2.0, 5.0, 44.0, 44.0)];
}

- (void)testRingViewAroundFrameWithCustomValuesCreatesCorrectFrame {
  GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 20.0, 30.0)
                                                       ringWidth:16.0];
  [self gscxtest_assertRect:ringView.frame equalsRect:CGRectMake(-2.0, 4.0, 44.0, 46.0)];
}

#pragma mark - Private

- (void)gscxtest_assertRect:(CGRect)rect equalsRect:(CGRect)otherRect {
  XCTAssertEqualWithAccuracy(CGRectGetMinX(rect), CGRectGetMinX(otherRect),
                             kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(CGRectGetMaxX(rect), CGRectGetMaxX(otherRect),
                             kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(CGRectGetMinY(rect), CGRectGetMinY(otherRect),
                             kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(CGRectGetMaxY(rect), CGRectGetMaxY(otherRect),
                             kRingViewTestsComparisonAccuracy);
}

@end
