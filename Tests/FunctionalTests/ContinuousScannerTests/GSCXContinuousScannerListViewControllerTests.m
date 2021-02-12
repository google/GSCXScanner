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

#import "GSCXContinuousScannerListViewController.h"

#import <XCTest/XCTest.h>

#import "GSCXScannerIssueExpandableTableViewDelegate.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/ContinuousScannerTests/GSCXContinuousScannerTestCase.h"
#import "GSCXTestCheckNames.h"
#import "GSCXTestScannerViewController.h"
#import "GSCXTestUIAccessibilityElementViewController.h"
#import "GSCXTestViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerIssueExpandableTableViewDelegate (ExposedForTesting)

+ (NSString *)gscx_accessibilityIdentifierForHeaderInSection:(NSInteger)section;

@end

@interface GSCXContinuousScannerListViewControllerTests : GSCXContinuousScannerTestCase
@end

@implementation GSCXContinuousScannerListViewControllerTests

- (void)testListViewWithOneSectionCanBeToggled {
  NSArray<NSString *> *allCheckNames =
      @[ kGSCXTestCheckName1, kGSCXTestCheckName2, kGSCXTestCheckName3, kGSCXTestCheckName4 ];
  [GSCXScannerTestUtils openPage:[GSCXTestUIAccessibilityElementViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapListButton];
  [GSCXScannerTestUtils assertListSectionCount:1];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:0];
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:NO];
  [GSCXScannerTestUtils toggleListSectionAtIndex:0];
  [GSCXScannerTestUtils assertListRowCount:2 inSection:0];
  // GSCXTestUIAccessibilityElementViewController contains elements with issues kGSCXTestCheckName2
  // and kGSCXTestCheckName3.
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils toggleListSectionAtIndex:0];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:0];
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:NO];
}

- (void)testListViewWithTwoSectionsCanBeToggledIndependently {
  NSArray<NSString *> *allCheckNames =
      @[ kGSCXTestCheckName1, kGSCXTestCheckName2, kGSCXTestCheckName3, kGSCXTestCheckName4 ];
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  // Scan twice so the list view has multiple sections.
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapListButton];
  // GSCXScannerTestViewController contains elements with all 4 issues.
  [GSCXScannerTestUtils assertListSectionCount:2];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:0];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:1];
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:NO];
  [GSCXScannerTestUtils toggleListSectionAtIndex:0];
  [GSCXScannerTestUtils assertListRowCount:3 inSection:0];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:1];
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:YES];
  [GSCXScannerTestUtils toggleListSectionAtIndex:1];
  [GSCXScannerTestUtils toggleListSectionAtIndex:0];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:0];
  [GSCXScannerTestUtils assertListRowCount:3 inSection:1];
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:YES];
  [GSCXScannerTestUtils toggleListSectionAtIndex:1];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:0];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:1];
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:NO];
}

- (void)testListViewWithManySectionsSomeEmptyCanBeToggledIndependently {
  NSArray<NSString *> *allCheckNames =
      @[ kGSCXTestCheckName1, kGSCXTestCheckName2, kGSCXTestCheckName3, kGSCXTestCheckName4 ];
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  // Perform scans on multiple view controllers so the corresponding list sections have different
  // numbers of rows.
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:[GSCXTestViewController pageName]];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils openPage:[GSCXTestUIAccessibilityElementViewController class]];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapListButton];
  [GSCXScannerTestUtils assertListSectionCount:3];

  // The first row represents a scan with issues. It's expandable, so it should be a button. The
  // second row represents a scan without issues. It is not expandable and is not a button.
  [self gscxtest_assertListSectionAtIndex:0 hasButton:YES];
  [self gscxtest_assertListSectionAtIndex:1 hasButton:NO];

  [GSCXScannerTestUtils assertListRowCount:0 inSection:0];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:1];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:2];
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:NO];
  [GSCXScannerTestUtils toggleListSectionAtIndex:0];
  [GSCXScannerTestUtils assertListRowCount:3 inSection:0];
  // GSCXScannerTestViewController contains elements with all 4 issues.
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:YES];
  [GSCXScannerTestUtils toggleListSectionAtIndex:0];
  [GSCXScannerTestUtils toggleListSectionAtIndex:1];
  [GSCXScannerTestUtils assertListRowCount:0 inSection:1];
  // GSCXTestViewController contains no elements with issues.
  [self gscxtest_assertLabelsForCheckNames:allCheckNames areSufficientlyVisible:NO];
  [GSCXScannerTestUtils toggleListSectionAtIndex:2];
  [GSCXScannerTestUtils assertListRowCount:2 inSection:2];
  // GSCXTestUIAccessibilityElementViewController contains elements with issues kGSCXTestCheckName2
  // and kGSCXTestCheckName3.
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName1 isSufficientlyVisible:NO];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName2 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName3 isSufficientlyVisible:YES];
  [GSCXScannerTestUtils assertLabelForCheckNamed:kGSCXTestCheckName4 isSufficientlyVisible:NO];
}

- (void)testListViewWithManySectionsRowsOffScreen {
  [GSCXScannerTestUtils openPage:[GSCXTestUIAccessibilityElementViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  // Scan multiple times to overflow the list page.
  NSInteger overflowSectionCount = 3;
  for (NSInteger i = 0; i < overflowSectionCount; i++) {
    XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  }
  [GSCXScannerTestUtils tapNavButtonWithAccessibilityLabel:[GSCXTestViewController pageName]];
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapListButton];
  for (NSInteger i = 0; i < overflowSectionCount + 1; i++) {
    [GSCXScannerTestUtils toggleListSectionAtIndex:i];
  }
  [GSCXScannerTestUtils assertListSectionCount:overflowSectionCount + 1];
  for (NSInteger i = 0; i < overflowSectionCount; i++) {
    [GSCXScannerTestUtils assertListRowCount:2 inSection:i];
  }
  [GSCXScannerTestUtils assertListRowCount:3 inSection:overflowSectionCount];
}

#pragma mark - Private

/**
 * Asserts whether the label for each check name in @c checkNames is sufficiently visible.
 *
 * @param checkNames The text of each label to search for.
 * @param areSufficientlyVisible @c YES to assert all the elements are sufficiently visible, @c NO
 *   to assert none of the elements are sufficiently visible.
 */
- (void)gscxtest_assertLabelsForCheckNames:(NSArray<NSString *> *)checkNames
                    areSufficientlyVisible:(BOOL)areSufficientlyVisible {
  id<GREYMatcher> scrollMatcher =
      grey_accessibilityID(kGSCXContinuousScannerListTableViewAccessibilityIdentifier);
  for (NSString *checkName in checkNames) {
    [GSCXScannerTestUtils assertLabelForCheckNamed:checkName
                             isSufficientlyVisible:areSufficientlyVisible
                       scrollingElementWithMatcher:scrollMatcher];
  }
}

/**
 * Asserts that the header at @c sectionIndex does or does not represent or contain a button. Fails
 * the test if not.
 *
 * @param sectionIndex The index of the header to assert on.
 * @param hasButton @c YES to assert the header represents a button or contains a visible button,
 * @c NO to assert the header does not represent the button, does not contain a button, or contains
 * a button that is hidden.
 */
- (void)gscxtest_assertListSectionAtIndex:(NSInteger)sectionIndex hasButton:(BOOL)hasButton {
  // TODO: Use the non-iOS 13 behavior if the Switch Control bug is fixed and the
  // UI workaround is removed.
  if (@available(iOS 13.0, *)) {
    NSString *headerAccessibilityId = [GSCXScannerIssueExpandableTableViewDelegate
        gscx_accessibilityIdentifierForHeaderInSection:sectionIndex];
    id<GREYMatcher> buttonMatcher = grey_allOf(
        grey_kindOfClass([UIButton class]), grey_not([GSCXScannerTestUtils isHiddenMatcher]), nil);
    id<GREYMatcher> ancestorMatcher = grey_ancestor(grey_accessibilityID(headerAccessibilityId));
    id<GREYMatcher> existsMatcher = hasButton ? grey_notNil() : grey_nil();
    [[EarlGrey selectElementWithMatcher:grey_allOf(buttonMatcher, ancestorMatcher, nil)]
        assertWithMatcher:existsMatcher];
  } else {
    [GSCXScannerTestUtils assertListSectionAtIndex:sectionIndex
                                accessibilityTrait:UIAccessibilityTraitButton
                                            exists:hasButton];
  }
}

@end

NS_ASSUME_NONNULL_END
