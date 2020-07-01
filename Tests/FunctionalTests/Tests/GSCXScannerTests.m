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

#import "GSCXScannerTestCase.h"

#import <XCTest/XCTest.h>

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXContinuousScannerGalleryViewController.h"
#import "GSCXRingViewArranger.h"
#import "GSCXScanResultsPageConstants.h"
#import "GSCXScannerResultDetailViewController.h"
#import "GSCXScannerScreenshotViewController.h"
#import "GSCXTestCheckNames.h"
#import "GSCXTestReportViewController.h"
#import "GSCXTestScannerViewController.h"
#import "GSCXTestSharingDelegate.h"
#import "GSCXTestUIAccessibilityElementViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Offset from the origin at which to tap the third ring view. Tapping the origin fails because
 * it taps on the edge of the third ring view, which isn't considered inside the ring's frame.
 */
static const CGPoint kGSCXTestOverlappingRingViewTapOffset = {10, 10};

/**
 * The title of the button used to dismiss the share scan report action sheet before iOS 13.
 */
NSString *const kGSCXTestCancelShareReportButtonTitlePreIOS13 = @"Cancel";

/**
 * The accessibility label of the button used to dismiss the share scan report action sheet at and
 * after iOS 13.
 */
NSString *const kGSCXTestCancelShareReportButtonAccessibilityLabelPostIOS13 = @"Close";

@interface GSCXScannerTests : GSCXScannerTestCase
@end

@implementation GSCXScannerTests

- (void)testScanWithNoIssuesShowsAlert {
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils dismissNoIssuesAlert];
}

- (void)testScanRootViewsWithAccessibilityIssuesPresentsScreenshot {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [[EarlGrey selectElementWithMatcher:grey_text(kGSCXScanResultsPageTitle)]
      assertWithMatcher:grey_notNil()];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testScreenshotPresentsRingViews {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertRingViewCount:3];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testTappingOnRingViewWithMultipleIssuesPresentsGalleryView {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [[GSCXScannerTestUtils selectRingViewAtIndex:0]
      assertWithMatcher:grey_accessibilityLabel(
                            @"2 issues for element with accessibility label Fail Checks 1 and 4")];
  [[GSCXScannerTestUtils selectRingViewAtIndex:0] performAction:grey_tap()];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:kGSCXScanResultsBackButtonTitle];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testTappingOnRingViewWithSingleIssuePresentsGalleryView {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [[GSCXScannerTestUtils selectRingViewAtIndex:1]
      assertWithMatcher:grey_accessibilityLabel(
                            @"1 issue for element with accessibility label Fails Check 2")];
  [[GSCXScannerTestUtils selectRingViewAtIndex:1] performAction:grey_tap()];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:kGSCXScanResultsBackButtonTitle];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testTappingOnOverlappingRingViewsEachWithSingleIssueGalleryViewForFirstIndex {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [[GSCXScannerTestUtils selectRingViewAtIndex:2]
      assertWithMatcher:
          grey_accessibilityLabel(
              @"1 issue for element with accessibility label Fails Check 3 and Overlaps")];
  [[GSCXScannerTestUtils selectRingViewAtIndex:2]
      performAction:grey_tapAtPoint(kGSCXTestOverlappingRingViewTapOffset)];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:kGSCXScanResultsBackButtonTitle];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testGalleryViewCanBeSwipedThrough {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [[GSCXScannerTestUtils selectRingViewAtIndex:1] performAction:grey_tap()];
  [[GSCXScannerTestUtils selectRingViewAtIndex:1] assertWithMatcher:grey_sufficientlyVisible()];
  [self gscxtest_swipeToPreviousGalleryPage];
  [[GSCXScannerTestUtils selectRingViewAtIndex:0] assertWithMatcher:grey_sufficientlyVisible()];
  [self gscxtest_swipeToNextGalleryPage];
  [[GSCXScannerTestUtils selectRingViewAtIndex:1] assertWithMatcher:grey_sufficientlyVisible()];
  [self gscxtest_swipeToNextGalleryPage];
  [[GSCXScannerTestUtils selectRingViewAtIndex:2] assertWithMatcher:grey_sufficientlyVisible()];
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:kGSCXScanResultsBackButtonTitle];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testUIAccessibilityElementFailsCheck {
  [GSCXScannerTestUtils openPage:[GSCXTestUIAccessibilityElementViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertRingViewCount:2];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testShareButtonPresentsActionSheetWithASCIIContent {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils tapShareReportButton];
  [GSCXScannerTestUtils tapCancelMockShareReportButton];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)testShareButtonPresentsActionSheetWithUTF8Content {
  [GSCXScannerTestUtils openPage:[GSCXTestReportViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils tapShareReportButton];
  [GSCXScannerTestUtils tapCancelMockShareReportButton];
  [GSCXScannerTestUtils dismissScreenshotView];
}

#pragma mark - Private

/**
 * Swipes the gallery detail scroll view to the previous page.
 */
- (void)gscxtest_swipeToPreviousGalleryPage {
  [[EarlGrey
      selectElementWithMatcher:grey_accessibilityID(
                                   kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier)]
      performAction:grey_swipeFastInDirection(kGREYDirectionRight)];
}

/**
 * Swipes the gallery detail scroll view to the next page.
 */
- (void)gscxtest_swipeToNextGalleryPage {
  [[EarlGrey
      selectElementWithMatcher:grey_accessibilityID(
                                   kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier)]
      performAction:grey_swipeFastInDirection(kGREYDirectionLeft)];
}


/**
 * @return @c YES if the operating system is at iOS 13.0 or later, @c NO otherwise.
 */
- (BOOL)gscxtest_isAtLeastVersionIOS13 {
  if (@available(iOS 13, *)) {
    return YES;
  } else {
    return NO;
  }
}

@end

NS_ASSUME_NONNULL_END
