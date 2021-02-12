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

#import "GSCXRingViewArranger.h"

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSCXRingViewArrangerTests : XCTestCase

/**
 * A blank image passed to @c GTXHierarchyResultCollection initializers.
 */
@property(strong, nonatomic) UIImage *dummyImage;

/**
 * Asserts that @c rect1 and @c rect2 are equal. Fails the test if not.
 *
 * @param rect1 The first rect to compare.
 * @param rect2 The second rect to compare.
 */
- (void)gscxtest_assertRect:(CGRect)rect1 equalToRect:(CGRect)rect2;

/**
 * Asserts that @c rect1 contains @c rect2. Fails the test if not.
 *
 * @param rect1 The rect that should contain @c rect2.
 * @param rect2 The rect that should be contained by @c rect1.
 */
- (void)gscxtest_assertRect:(CGRect)containerRect containsRect:(CGRect)rect;

@end

@implementation GSCXRingViewArrangerTests

- (void)setUp {
  [super setUp];
  self.dummyImage = [[UIImage alloc] init];
}

- (void)testRingViewsCanBeAddedForOneIssueNoTransform {
  GTXElementResultCollection *element =
      [self gscxtest_elementResultWithFrame:CGRectMake(10, 20, 30, 40)
                         accessibilityLabel:@"ax label"
                                 checkCount:1];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 100, 100);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:coordinates];
  XCTAssertEqual([arranger.ringViews count], 1);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  XCTAssertEqualObjects(arranger.ringViews[0].accessibilityLabel, nil);
  [arranger addAccessibilityAttributesToRingViews];
  XCTAssertEqualObjects(arranger.ringViews[0].accessibilityLabel,
                        @"1 issue for element with accessibility label ax label");
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(3, 18, 44, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(20, 30)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 1);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element);

  // Assert that points just outside the ring are not considered inside.
  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(2, 17)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);

  GTXHierarchyResultCollection *resultAtPoint3 =
      [arranger resultWithIssuesAtPoint:CGPointMake(48, 17)];
  XCTAssertEqual(resultAtPoint3.elementResults.count, 0);

  GTXHierarchyResultCollection *resultAtPoint4 =
      [arranger resultWithIssuesAtPoint:CGPointMake(2, 61)];
  XCTAssertEqual(resultAtPoint4.elementResults.count, 0);

  GTXHierarchyResultCollection *resultAtPoint5 =
      [arranger resultWithIssuesAtPoint:CGPointMake(48, 61)];
  XCTAssertEqual(resultAtPoint5.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesNoTransform {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(10, 20, 30, 40)
                         accessibilityLabel:@"ax label 1"
                                 checkCount:1];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(20, 10, 40, 30)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(2, 21, 96, 2)
                         accessibilityLabel:nil
                                 checkCount:2];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 100, 100);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:coordinates];
  XCTAssertEqual([arranger.ringViews count], 3);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  XCTAssertEqualObjects(arranger.ringViews[0].accessibilityLabel, nil);
  XCTAssertEqualObjects(arranger.ringViews[1].accessibilityLabel, nil);
  XCTAssertEqualObjects(arranger.ringViews[2].accessibilityLabel, nil);
  [arranger addAccessibilityAttributesToRingViews];
  XCTAssertEqualObjects(arranger.ringViews[0].accessibilityLabel,
                        @"1 issue for element with accessibility label ax label 1");
  XCTAssertEqualObjects(arranger.ringViews[1].accessibilityLabel,
                        @"1 issue for element with no accessibility label");
  XCTAssertEqualObjects(arranger.ringViews[2].accessibilityLabel,
                        @"2 issues for element with no accessibility label");
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(3, 18, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(18, 3, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(0, 0, 100, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];
}

- (void)testRingViewsCanBeAddedForOneIssueScaleTransformLarger {
  GTXElementResultCollection *element =
      [self gscxtest_elementResultWithFrame:CGRectMake(10, 20, 30, 40)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 200, 200);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 1);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(18, 38, 64, 84)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(20, 40)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 1);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element);

  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(15, 40)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesScaleTransformLarger {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(10, 20, 30, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(20, 10, 40, 30)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(2, 88, 97, 2)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 200, 200);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 3);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(18, 38, 64, 84)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(38, 18, 84, 64)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(2, 156, 198, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];
}

- (void)testRingViewsCanBeAddedForOneIssueScaleTransformSmaller {
  GTXElementResultCollection *element =
      [self gscxtest_elementResultWithFrame:CGRectMake(28, 24, 32, 40)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 100, 100);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 200, 200)];
  XCTAssertEqual([arranger.ringViews count], 1);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(0, 0, 44, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(5, 10)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 1);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element);

  // Outside the transformed view's frame, but inside the expanded ring view's.
  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(25, 35)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 1);

  GTXHierarchyResultCollection *resultAtPoint3 =
      [arranger resultWithIssuesAtPoint:CGPointMake(45, 45)];
  XCTAssertEqual(resultAtPoint3.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesScaleTransformSmaller {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(28, 24, 32, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(28, 30, 40, 32)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(4, 100, 192, 4)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 100, 100);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 200, 200)];
  XCTAssertEqual([arranger.ringViews count], 3);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(0, 0, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(2, 1, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(0, 29, 100, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];
}

- (void)testRingViewsCanBeAddedForOneIssueOffsetTransformLarger {
  GTXElementResultCollection *element =
      [self gscxtest_elementResultWithFrame:CGRectMake(10, 20, 30, 40)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element ]
                                                        screenshot:self.dummyImage];
  // Use a scroll view to create a view whose bounds do not have origin {0, 0}.
  UIScrollView *superview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  superview.contentSize = CGSizeMake(1000, 1000);
  superview.contentOffset = CGPointMake(100, 100);
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 1);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(103, 118, 44, 44)];
  [self gscxtest_assertRect:CGRectMake(100, 100, 100, 100)
               containsRect:arranger.ringViews[0].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(110, 120)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 1);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element);

  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(15, 40)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesOffsetTransformLarger {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(10, 20, 30, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(20, 10, 40, 30)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(2, 77, 96, 2)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  // Use a scroll view to create a view whose bounds do not have origin {0, 0}.
  UIScrollView *superview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  superview.contentSize = CGSizeMake(1000, 1000);
  superview.contentOffset = CGPointMake(100, 100);
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 3);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(103, 118, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(118, 103, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(100, 156, 100, 44)];
  CGRect coordinates = CGRectMake(100, 100, 100, 100);
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];
}

- (void)testRingViewsCanBeAddedForOneIssueOffsetTransformSmaller {
  GTXElementResultCollection *element =
      [self gscxtest_elementResultWithFrame:CGRectMake(110, 120, 30, 40)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 100, 100);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(100, 100, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 1);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(3, 18, 44, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(10, 20)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 1);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element);

  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(120, 130)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesOffsetTransformSmaller {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(110, 120, 30, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(120, 110, 40, 30)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(102, 121, 96, 2)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 100, 100);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(100, 100, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 3);
  XCTAssertEqualObjects(superview.subviews, arranger.ringViews);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(3, 18, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(18, 3, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(0, 0, 100, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];
}

- (void)testRingViewsCanBeAddedForMultipleIssuesOffsetLargerScaleSmaller {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(28, 24, 32, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(24, 28, 40, 32)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(104, 104, 92, 4)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  // Use a scroll view to create a view whose bounds do not have origin {0, 0}.
  UIScrollView *superview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  superview.contentSize = CGSizeMake(1000, 1000);
  superview.contentOffset = CGPointMake(100, 100);
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 200, 200)];
  XCTAssertEqual([arranger.ringViews count], 3);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(100, 100, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(100, 100, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(150, 131, 50, 44)];
  CGRect coordinates = CGRectMake(100, 100, 100, 100);
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(110, 110)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 2);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element1);
  XCTAssertEqual(resultAtPoint1.elementResults[1], element2);

  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(15, 25)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesOffsetLargerScaleLarger {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(10, 20, 30, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(20, 10, 40, 30)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(4, 10, 92, 2)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  // Use a scroll view to create a view whose bounds do not have origin {0, 0}.
  UIScrollView *superview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  superview.contentSize = CGSizeMake(1000, 1000);
  superview.contentOffset = CGPointMake(100, 100);
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(0, 0, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 3);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(118, 138, 64, 84)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(138, 118, 84, 64)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(106, 100, 188, 44)];
  CGRect coordinates = CGRectMake(100, 100, 200, 200);
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(140, 145)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 2);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element1);
  XCTAssertEqual(resultAtPoint1.elementResults[1], element2);

  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(15, 25)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesOffsetSmallerScaleSmaller {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(128, 124, 32, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(124, 128, 40, 32)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(124, 142, 92, 4)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 100, 100);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(100, 100, 200, 200)];
  XCTAssertEqual([arranger.ringViews count], 3);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(0, 0, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(0, 0, 44, 44)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(10, 0, 50, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(5, 10)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 2);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element1);
  XCTAssertEqual(resultAtPoint1.elementResults[1], element2);

  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(125, 125)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);
}

- (void)testRingViewsCanBeAddedForMultipleIssuesOffsetSmallerScaleLarger {
  GTXElementResultCollection *element1 =
      [self gscxtest_elementResultWithFrame:CGRectMake(110, 120, 30, 40)];
  GTXElementResultCollection *element2 =
      [self gscxtest_elementResultWithFrame:CGRectMake(120, 110, 40, 30)];
  GTXElementResultCollection *element3 =
      [self gscxtest_elementResultWithFrame:CGRectMake(104, 110, 92, 2)];
  GTXHierarchyResultCollection *result =
      [[GTXHierarchyResultCollection alloc] initWithElementResults:@[ element1, element2, element3 ]
                                                        screenshot:self.dummyImage];
  CGRect coordinates = CGRectMake(0, 0, 200, 200);
  UIView *superview = [[UIView alloc] initWithFrame:coordinates];
  GSCXRingViewArranger *arranger = [[GSCXRingViewArranger alloc] initWithResult:result];
  [arranger addRingViewsToSuperview:superview fromCoordinates:CGRectMake(100, 100, 100, 100)];
  XCTAssertEqual([arranger.ringViews count], 3);
  // Ring views add a 2-point outline to each side of the frame. The origin will be two points less
  // and the size will be 4 points more.
  [self gscxtest_assertRect:arranger.ringViews[0].frame equalToRect:CGRectMake(18, 38, 64, 84)];
  [self gscxtest_assertRect:arranger.ringViews[1].frame equalToRect:CGRectMake(38, 18, 84, 64)];
  [self gscxtest_assertRect:arranger.ringViews[2].frame equalToRect:CGRectMake(6, 0, 188, 44)];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[0].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[1].frame];
  [self gscxtest_assertRect:coordinates containsRect:arranger.ringViews[2].frame];

  GTXHierarchyResultCollection *resultAtPoint1 =
      [arranger resultWithIssuesAtPoint:CGPointMake(40, 45)];
  XCTAssertEqual(resultAtPoint1.elementResults.count, 2);
  XCTAssertEqual(resultAtPoint1.elementResults[0], element1);
  XCTAssertEqual(resultAtPoint1.elementResults[1], element2);

  GTXHierarchyResultCollection *resultAtPoint2 =
      [arranger resultWithIssuesAtPoint:CGPointMake(105, 105)];
  XCTAssertEqual(resultAtPoint2.elementResults.count, 0);
}

#pragma mark - Private

/**
 * Constructs a @c GTXElementResultCollection instance with @c frame for @c accessibilityFrame and
 * default values for the other parameters on @c elementReference.
 *
 * @param frame The value for @c accessibilityFrame.
 * @return A @c GTXElementResultCollection instance.
 */
- (GTXElementResultCollection *)gscxtest_elementResultWithFrame:(CGRect)frame {
  return [self gscxtest_elementResultWithFrame:frame accessibilityLabel:nil checkCount:1];
}

/**
 * Constructs a @c GTXElementResultCollection instance with  @c frame for @c accessibilityFrame
 * @c accessibilityLabel for @c accessibilityLabel, and default values for the other parameters on
 * @c elementReference.
 *
 * @param frame The value for the @c accessibilityFrame.
 * @param accessibilityLabel Optional. The value for the @c accessibilityLabel parameter.
 * @param checkCount The number of checks
 * @return A @c GTXElementResultCollection instance.
 */
- (GTXElementResultCollection *)gscxtest_elementResultWithFrame:(CGRect)frame
                                             accessibilityLabel:
                                                 (nullable NSString *)accessibilityLabel
                                                     checkCount:(NSUInteger)checkCount {
  NSMutableArray<GTXCheckResult *> *checkResults = [[NSMutableArray alloc] init];
  for (NSUInteger i = 0; i < checkCount; i++) {
    NSString *name = [NSString stringWithFormat:@"Check %lu", (unsigned long)i];
    NSString *description = [NSString stringWithFormat:@"Description %lu", (unsigned long)i];
    [checkResults addObject:[[GTXCheckResult alloc] initWithCheckName:name
                                                     errorDescription:description]];
  }
  GTXElementReference *elementReference =
      [[GTXElementReference alloc] initWithElementAddress:1
                                             elementClass:[UIView class]
                                       accessibilityLabel:accessibilityLabel
                                  accessibilityIdentifier:nil
                                       accessibilityFrame:frame
                                       elementDescription:@"Element Description"];
  return [[GTXElementResultCollection alloc] initWithElement:elementReference
                                                checkResults:checkResults];
}

- (void)gscxtest_assertRect:(CGRect)rect1 equalToRect:(CGRect)rect2 {
  XCTAssert(CGRectEqualToRect(rect1, rect2), @"Rect 1 %@ != Rect 2 %@", NSStringFromCGRect(rect1),
            NSStringFromCGRect(rect2));
}

- (void)gscxtest_assertRect:(CGRect)containerRect containsRect:(CGRect)rect {
  XCTAssert(CGRectContainsRect(containerRect, rect), @"Container Rect %@ does not contain Rect %@",
            NSStringFromCGRect(containerRect), NSStringFromCGRect(rect));
}

@end

NS_ASSUME_NONNULL_END
