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

#import "GSCXScannerTestCase.h"

#import "third_party/objective_c/EarlGreyV2/CommonLib/Matcher/GREYElementMatcherBlock.h"
#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXTestConstraintsViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSLayoutConstraintGSCXUtilitiesTests : GSCXScannerTestCase
@end

@implementation NSLayoutConstraintGSCXUtilitiesTests

- (void)testConstraintUtilitiesProduceCorrectFrames {
  [GSCXScannerTestUtils openPage:[GSCXTestConstraintsViewController class]];
  [self gscxtest_assertElementWithAccessibilityIdentifier:
            kGSCXTestConstraintsMainViewAccessibilityIdentifier
                                                 hasFrame:CGRectMake(10, 10, 100, 300)];
  [self gscxtest_assertElementWithAccessibilityIdentifier:
            kGSCXTestConstraintsEntirelyCoveringViewAccessibilityIdentifier
                                                 hasFrame:CGRectMake(0, 0, 100, 300)];
  [self gscxtest_assertElementWithAccessibilityIdentifier:
            kGSCXTestConstraintsCenteredViewAccessibilityIdentifier
                                                 hasFrame:CGRectMake(20, 20, 80, 280)];
  [self gscxtest_assertElementWithAccessibilityIdentifier:
            kGSCXTestConstraintsAspectRatioViewAccessibilityIdentifier
                                                 hasFrame:CGRectMake(0, 310, 120, 60)];
}

#pragma mark - Private

- (void)gscxtest_assertElementWithAccessibilityIdentifier:(NSString *)accessibilityIdentifier
                                                 hasFrame:(CGRect)frame {
  id<GREYMatcher> matcher = [self gscxtest_matcherForFrame:frame];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(accessibilityIdentifier)]
      assertWithMatcher:matcher];
}

- (id<GREYMatcher>)gscxtest_matcherForFrame:(CGRect)frame {
  return [GREYElementMatcherBlock
      matcherWithMatchesBlock:^BOOL(id element) {
        if (![element respondsToSelector:@selector(frame)]) {
          return NO;
        }
        return CGRectEqualToRect([element frame], frame);
      }
      descriptionBlock:^(id<GREYDescription> description) {
        [description appendText:[NSString stringWithFormat:@"frame does not match %@",
                                                           NSStringFromCGRect(frame)]];
      }];
}

@end

NS_ASSUME_NONNULL_END
