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
 *  Accuracy of floating point comparisons for GSCXRingView tests.
 */
static const CGFloat kRingViewTestsComparisonAccuracy = 0.00001;

/**
 *  Contains tests for GSCXRingView methods.
 */
@interface GSCXRingViewTests : XCTestCase

@property(nonatomic, assign) CGRect uiElementFrame;

/**
 *  Asserts that the four sides of @c rect are @c expectedDifference points away from the
 *  corresponding sides of @c otherRect.
 *
 *  @c rect The rect that surrounds @c otherRect.
 *  @c otherRect The otherRect used to calculate the surrounding rect.
 *  @c expectedDifference The distance between corresponding sides.
 */
- (void)_assertRect:(CGRect)rect containsRect:(CGRect)otherRect withAccuracy:(CGFloat)accuracy;

@end

@implementation GSCXRingViewTests

- (void)setUp {
  [super setUp];

  self.uiElementFrame = CGRectMake(10.0, 12.0, 20.0, 30.0);
}

- (void)testRingViewAroundFrameWithDefaultValuesCreatesCorrectFrame {
  CGFloat accuracy = kGSCXRingViewDefaultOuterWidth / 2.0;
  GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:self.uiElementFrame];
  [self _assertRect:ringView.frame containsRect:self.uiElementFrame withAccuracy:accuracy];
}

- (void)testRingViewAroundFrameWithCustomValuesCreatesCorrectFrame {
  CGFloat accuracy = 8.0;
  GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 20.0, 30.0)
                                                      innerWidth:8.0
                                                      outerWidth:16.0];
  [self _assertRect:ringView.frame containsRect:self.uiElementFrame withAccuracy:accuracy];
}

- (void)testRingViewAroundFrameInnerWidthGreaterThanOuterWidthFailsAssertion {
  XCTAssertThrows([GSCXRingView ringViewAroundFocusRect:CGRectMake(10.0, 12.0, 20.0, 30.0)
                                             innerWidth:16.0
                                             outerWidth:8.0]);
}

- (void)testSetInnerWidthOuterWidthSucceedsInnerWidthIsSmallerThanOuterWidth {
  GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:CGRectZero];
  [ringView setInnerWidth:1.0 outerWidth:8.0];
  XCTAssertEqualWithAccuracy(ringView.innerWidth, 1.0, kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(ringView.outerWidth, 8.0, kRingViewTestsComparisonAccuracy);
}

- (void)testSetInnerWidthOuterWidthSucceedsInnerWidthIsLargerThanOldOuterWidth {
  GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:CGRectZero];
  [ringView setInnerWidth:1.0 outerWidth:8.0];
  [ringView setInnerWidth:16.0 outerWidth:32.0];
  XCTAssertEqualWithAccuracy(ringView.innerWidth, 16.0, kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(ringView.outerWidth, 32.0, kRingViewTestsComparisonAccuracy);
}

- (void)testSetInnerWidthOuterWidthSucceedsOuterWidthIsSmallerThanOldInnerWidth {
  GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:CGRectZero];
  [ringView setInnerWidth:1.0 outerWidth:8.0];
  [ringView setInnerWidth:0.25 outerWidth:0.5];
  XCTAssertEqualWithAccuracy(ringView.innerWidth, 0.25, kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(ringView.outerWidth, 0.5, kRingViewTestsComparisonAccuracy);
}

- (void)testSetInnerWidthOuterWidthFailsOuterWidthIsSmallerThanInnerWidth {
  GSCXRingView *ringView = [GSCXRingView ringViewAroundFocusRect:CGRectZero];
  XCTAssertThrows([ringView setInnerWidth:8.0 outerWidth:4.0]);
}

#pragma mark - Private

- (void)_assertRect:(CGRect)rect containsRect:(CGRect)otherRect withAccuracy:(CGFloat)accuracy {
  XCTAssertEqualWithAccuracy(CGRectGetMinX(otherRect) - CGRectGetMinX(rect), accuracy,
                             kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(CGRectGetMinY(otherRect) - CGRectGetMinY(rect), accuracy,
                             kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(CGRectGetMaxX(rect) - CGRectGetMaxX(otherRect), accuracy,
                             kRingViewTestsComparisonAccuracy);
  XCTAssertEqualWithAccuracy(CGRectGetMaxY(rect) - CGRectGetMaxY(otherRect), accuracy,
                             kRingViewTestsComparisonAccuracy);
}

@end
