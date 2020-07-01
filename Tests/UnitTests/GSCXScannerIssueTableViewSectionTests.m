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

#import "GSCXScannerIssueTableViewSection.h"

#import <XCTest/XCTest.h>

#import "GSCXScannerIssue.h"
#import "GSCXScannerIssueTableViewRow.h"
#import "GSCXTestCheckNames.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The default name of the check used for @c GSCXScannerIssue instances wrapped by
 * @c GSCXScannerIssueTableViewRow instances.
 */
static NSString *const kGSCXScannerIssueDefaultCheckName = @"Check";

/**
 * The default description of the check used for @c GSCXScannerIssue instances wrapped by
 * @c GSCXScannerIssueTableViewRow instances.
 */
static NSString *const kGSCXScannerIssueDefaultCheckDescription = @"Description";

/**
 * The default element description used for @c GSCXScannerIssue instances wrapped by
 * @c GSCXScannerIssueTableViewRow instances.
 */
static NSString *const kGSCXScannerIssueElementDescription = @"Element";

/**
 * The title of @c GSCXScannerIssueTableViewSection instances.
 */
static NSString *const kGSCXScannerIssueTableViewSectionTitle = @"Scan 1";

@interface GSCXScannerIssueTableViewSectionTests : XCTestCase
@end

@implementation GSCXScannerIssueTableViewSectionTests

- (void)testSectionWithZeroRows {
  NSArray<GSCXScannerIssueTableViewRow *> *testRows = @[];
  GSCXScannerIssueTableViewSection *section =
      [[GSCXScannerIssueTableViewSection alloc] initWithTitle:kGSCXScannerIssueTableViewSectionTitle
                                                     subtitle:nil
                                                         rows:testRows];
  XCTAssertEqual([section numberOfRows], testRows.count);
  XCTAssertEqual([section numberOfSuggestions], 0);
}

- (void)testSectionWithOneRowOneSuggestion {
  GSCXScannerIssueTableViewRow *row = [self gscxtest_dummyRow];
  [row addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                     contents:kGSCXTestAccessibilityLabelCheckDescription];
  NSArray<GSCXScannerIssueTableViewRow *> *testRows = @[ row ];
  GSCXScannerIssueTableViewSection *section =
      [[GSCXScannerIssueTableViewSection alloc] initWithTitle:kGSCXScannerIssueTableViewSectionTitle
                                                     subtitle:nil
                                                         rows:testRows];
  XCTAssertEqual([section numberOfRows], testRows.count);
  XCTAssertEqual([section numberOfSuggestions], [row numberOfSuggestions]);
}

- (void)testSectionWithOneRowManySuggestions {
  GSCXScannerIssueTableViewRow *row = [self gscxtest_dummyRow];
  [row addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                     contents:kGSCXTestAccessibilityLabelCheckDescription];
  [row addSuggestionWithTitle:kGSCXTestContrastRatioCheckName
                     contents:kGSCXTestContrastRatioCheckDescription];
  [row addSuggestionWithTitle:kGSCXTestTouchTargetSizeCheckName
                     contents:kGSCXTestTouchTargetSizeCheckDescription];
  NSArray<GSCXScannerIssueTableViewRow *> *testRows = @[ row ];
  GSCXScannerIssueTableViewSection *section =
      [[GSCXScannerIssueTableViewSection alloc] initWithTitle:kGSCXScannerIssueTableViewSectionTitle
                                                     subtitle:nil
                                                         rows:testRows];
  XCTAssertEqual([section numberOfRows], testRows.count);
  XCTAssertEqual([section numberOfSuggestions], [row numberOfSuggestions]);
}

- (void)testSectionWithManyRowsOneSuggestion {
  GSCXScannerIssueTableViewRow *row1 = [self gscxtest_dummyRow];
  GSCXScannerIssueTableViewRow *row2 = [self gscxtest_dummyRow];
  GSCXScannerIssueTableViewRow *row3 = [self gscxtest_dummyRow];
  [row1 addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                      contents:kGSCXTestAccessibilityLabelCheckDescription];
  [row2 addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                      contents:kGSCXTestAccessibilityLabelCheckDescription];
  [row3 addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                      contents:kGSCXTestAccessibilityLabelCheckDescription];
  NSArray<GSCXScannerIssueTableViewRow *> *testRows = @[ row1, row2, row3 ];
  GSCXScannerIssueTableViewSection *section =
      [[GSCXScannerIssueTableViewSection alloc] initWithTitle:kGSCXScannerIssueTableViewSectionTitle
                                                     subtitle:nil
                                                         rows:testRows];
  XCTAssertEqual([section numberOfRows], testRows.count);
  XCTAssertEqual([section numberOfSuggestions], 3);
}

- (void)testSectionWithManyRowsSomeOneSuggestionSomeManySuggestions {
  GSCXScannerIssueTableViewRow *row1 = [self gscxtest_dummyRow];
  GSCXScannerIssueTableViewRow *row2 = [self gscxtest_dummyRow];
  GSCXScannerIssueTableViewRow *row3 = [self gscxtest_dummyRow];
  [row1 addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                      contents:kGSCXTestAccessibilityLabelCheckDescription];
  [row1 addSuggestionWithTitle:kGSCXTestContrastRatioCheckName
                      contents:kGSCXTestContrastRatioCheckDescription];
  [row2 addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                      contents:kGSCXTestAccessibilityLabelCheckDescription];
  [row3 addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                      contents:kGSCXTestAccessibilityLabelCheckDescription];
  [row3 addSuggestionWithTitle:kGSCXTestContrastRatioCheckName
                      contents:kGSCXTestContrastRatioCheckDescription];
  [row3 addSuggestionWithTitle:kGSCXTestTouchTargetSizeCheckName
                      contents:kGSCXTestTouchTargetSizeCheckDescription];
  NSArray<GSCXScannerIssueTableViewRow *> *testRows = @[ row1, row2, row3 ];
  GSCXScannerIssueTableViewSection *section =
      [[GSCXScannerIssueTableViewSection alloc] initWithTitle:kGSCXScannerIssueTableViewSectionTitle
                                                     subtitle:nil
                                                         rows:testRows];
  XCTAssertEqual([section numberOfRows], testRows.count);
  XCTAssertEqual([section numberOfSuggestions], 6);
}

#pragma mark - Private

/**
 * Constructs a new @c GSCXScannerIssueTableViewRow instance with default properties.
 */
- (GSCXScannerIssueTableViewRow *)gscxtest_dummyRow {
  GSCXScannerIssue *dummyIssue =
      [[GSCXScannerIssue alloc] initWithCheckNames:@[ kGSCXScannerIssueDefaultCheckName ]
                                 checkDescriptions:@[ kGSCXScannerIssueDefaultCheckDescription ]
                                    elementAddress:0
                                      elementClass:[UIView class]
                               frameInScreenBounds:CGRectZero
                                accessibilityLabel:nil
                           accessibilityIdentifier:nil
                                elementDescription:kGSCXScannerIssueElementDescription];
  UIImage *dummyImage = [[UIImage alloc] init];
  GSCXScannerResult *dummyResult = [[GSCXScannerResult alloc] initWithIssues:@[ dummyIssue ]
                                                                  screenshot:dummyImage];
  return [[GSCXScannerIssueTableViewRow alloc] initWithIssue:dummyIssue
                                                       title:@""
                                                    subtitle:@""
                                              originalResult:dummyResult
                                          originalIssueIndex:0];
}

@end

NS_ASSUME_NONNULL_END
