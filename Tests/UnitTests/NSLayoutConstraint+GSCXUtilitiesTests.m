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

#import "NSLayoutConstraint+GSCXUtilities.h"

#import <XCTest/XCTest.h>

#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSLayoutConstraintGSCXUtilitiesTests : XCTestCase

/**
 * A dummy view to make constraints with.
 */
@property(strong, nonatomic) UIView *view1;

/**
 * A separate dummy view to make constraints with.
 */
@property(strong, nonatomic) UIView *view2;

@end

@implementation NSLayoutConstraintGSCXUtilitiesTests

- (void)setUp {
  [super setUp];
  self.view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  self.view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
}

- (void)testConstrainAnchorsOfViewEqualToSafeAreaAllNoThrowsException {
  XCTAssertThrows([NSLayoutConstraint gscx_constrainAnchorsOfView:self.view1
                                            equalToSafeAreaOfView:self.view2
                                                          leading:NO
                                                         trailing:NO
                                                              top:NO
                                                           bottom:NO
                                                         constant:0.0
                                                        activated:NO]);
}

- (void)testConstrainAnchorsOfViewEqualToSafeAreaAllCombinationsReturnCorrectConstraints {
  // The first 4 bits in i represent whether the corresponding anchor is YES or NO. Iterating
  // through 16 covers all combinations. Skip 0 because the flags cannot all be NO.
  // Bit 0: leading
  // Bit 1: trailing
  // Bit 2: top
  // Bit 3: bottom
  NSInteger numberOfCombinations = 1 << 4;
  for (NSInteger i = 1; i < numberOfCombinations; i++) {
    BOOL leading = (i & (1 << 0)) ? YES : NO;
    BOOL trailing = (i & (1 << 1)) ? YES : NO;
    BOOL top = (i & (1 << 2)) ? YES : NO;
    BOOL bottom = (i & (1 << 3)) ? YES : NO;
    NSArray<NSLayoutConstraint *> *constraints =
        [NSLayoutConstraint gscx_constrainAnchorsOfView:self.view1
                                  equalToSafeAreaOfView:self.view2
                                                leading:leading
                                               trailing:trailing
                                                    top:top
                                                 bottom:bottom
                                               constant:0.0
                                              activated:NO];
    XCTAssertEqual([self gscxtest_array:constraints hasConstraintOnAnchor:NSLayoutAttributeLeading],
                   leading);
    XCTAssertEqual([self gscxtest_array:constraints
                       hasConstraintOnAnchor:NSLayoutAttributeTrailing],
                   trailing);
    XCTAssertEqual([self gscxtest_array:constraints hasConstraintOnAnchor:NSLayoutAttributeTop],
                   top);
    XCTAssertEqual([self gscxtest_array:constraints hasConstraintOnAnchor:NSLayoutAttributeBottom],
                   bottom);
  }
}

#pragma mark - Private

/**
 * Determines if @c constraints contains an element where both views' attributes are @c anchor.
 *
 * @param constraints An array of constraints.
 * @param anchor The anchor to test for. Crashes with an assertion if it is not one of
 *  @c NSLayoutAttributeLeading, @c NSLayoutAttributeTrailing, @c NSLayoutAttributeTop,
 *  @c NSLayoutAttributeBottom.
 * @return @c YES if one of the elements in @c constraints has @c anchor for both attributes, @c NO
 *  otherwise.
 */
- (BOOL)gscxtest_array:(NSArray<NSLayoutConstraint *> *)constraints
    hasConstraintOnAnchor:(NSLayoutAttribute)anchor {
  GTX_ASSERT(anchor == NSLayoutAttributeLeading || anchor == NSLayoutAttributeTrailing ||
                 anchor == NSLayoutAttributeTop || anchor == NSLayoutAttributeBottom,
             @"anchor must be leading, trailing, top, or bottom");
  for (NSLayoutConstraint *constraint in constraints) {
    if (constraint.firstAttribute == anchor && constraint.secondAttribute == anchor) {
      return YES;
    }
  }
  return NO;
}

@end

NS_ASSUME_NONNULL_END
