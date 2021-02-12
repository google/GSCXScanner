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

#import "GSCXContinuousScannerListTabBarUtils.h"

#import <XCTest/XCTest.h>

#import "GSCXTestCheckNames.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScannerListTabBarUtilsTests : XCTestCase

/**
 * An element containing an issue with check @c kGSCXTestAccessibilityLabelCheckName.
 */
@property(strong, nonatomic) GTXElementResultCollection *elementWithAccessibilityLabelCheck;

/**
 * An element containing issues with checks @c kGSCXTestAccessibilityLabelCheckName,
 * @c kGSCXTestTouchTargetSizeCheckName, and @c kGSCXTestContrastRatioCheckName.
 */
@property(strong, nonatomic) GTXElementResultCollection *elementWithThreeChecks;

/**
 * An element containing an issue with check @c kGSCXTestTouchTargetCheckName.
 */
@property(strong, nonatomic) GTXElementResultCollection *elementWithTouchTargetCheck;

/**
 * A blank image passed to @c GSCXScannerResult initializers.
 */
@property(strong, nonatomic) UIImage *dummyImage;

@end

@implementation GSCXContinuousScannerListTabBarUtilsTests

- (void)setUp {
  [super setUp];
  GTXElementReference *elementReference =
      [[GTXElementReference alloc] initWithElementAddress:0
                                             elementClass:[UIView class]
                                       accessibilityLabel:@"Label"
                                  accessibilityIdentifier:@"Identifier"
                                       accessibilityFrame:CGRectZero
                                       elementDescription:@"Description"];
  GTXCheckResult *accessibilityLabelCheck =
      [[GTXCheckResult alloc] initWithCheckName:kGSCXTestAccessibilityLabelCheckName
                               errorDescription:kGSCXTestAccessibilityLabelCheckDescription];
  GTXCheckResult *contrastRatioCheck =
      [[GTXCheckResult alloc] initWithCheckName:kGSCXTestContrastRatioCheckName
                               errorDescription:kGSCXTestContrastRatioCheckDescription];
  GTXCheckResult *touchTargetCheck =
      [[GTXCheckResult alloc] initWithCheckName:kGSCXTestTouchTargetSizeCheckName
                               errorDescription:kGSCXTestTouchTargetSizeCheckDescription];
  self.elementWithAccessibilityLabelCheck =
      [[GTXElementResultCollection alloc] initWithElement:elementReference
                                             checkResults:@[ accessibilityLabelCheck ]];
  self.elementWithThreeChecks = [[GTXElementResultCollection alloc]
      initWithElement:elementReference
         checkResults:@[ accessibilityLabelCheck, touchTargetCheck, contrastRatioCheck ]];
  self.elementWithTouchTargetCheck =
      [[GTXElementResultCollection alloc] initWithElement:elementReference
                                             checkResults:@[ touchTargetCheck ]];
  self.dummyImage = [[UIImage alloc] init];
}

- (void)testSectionsWithGroupedByScanResultsEmptyResults {
  [self gscxtest_assertSectionsWithGroupedByScanResultsEqualResults:@[]];
}

- (void)testSectionsWithGroupedByScanResultsOneResultOneIssue {
  NSArray<GTXHierarchyResultCollection *> *results = @[ [[GTXHierarchyResultCollection alloc]
      initWithElementResults:@[ self.elementWithAccessibilityLabelCheck ]
                  screenshot:self.dummyImage] ];
  [self gscxtest_assertSectionsWithGroupedByScanResultsEqualResults:results];
}

- (void)testSectionsWithGroupedByScanResultsOneResultManyIssues {
  NSArray<GTXHierarchyResultCollection *> *results = @[ [[GTXHierarchyResultCollection alloc]
      initWithElementResults:@[ self.elementWithThreeChecks ]
                  screenshot:self.dummyImage] ];
  [self gscxtest_assertSectionsWithGroupedByScanResultsEqualResults:results];
}

- (void)testSectionsWithGroupedByScanResultsManyResultsOneIssue {
  NSArray<GTXHierarchyResultCollection *> *results =
      @[ [[GTXHierarchyResultCollection alloc] initWithElementResults:@[
        self.elementWithAccessibilityLabelCheck, self.elementWithAccessibilityLabelCheck
      ]
                                                           screenshot:self.dummyImage] ];
  [self gscxtest_assertSectionsWithGroupedByScanResultsEqualResults:results];
}

- (void)testSectionsWithGroupedByScanResultsManyResultsManyIssues {
  NSArray<GTXHierarchyResultCollection *> *results = @[ [[GTXHierarchyResultCollection alloc]
      initWithElementResults:@[ self.elementWithThreeChecks, self.elementWithThreeChecks ]
                  screenshot:self.dummyImage] ];
  [self gscxtest_assertSectionsWithGroupedByScanResultsEqualResults:results];
}

- (void)testSectionsWithGroupedByScanResultsManyResultsSomeOneIssueSomeManyIssues {
  NSArray<GTXHierarchyResultCollection *> *results =
      @[ [[GTXHierarchyResultCollection alloc] initWithElementResults:@[
        self.elementWithAccessibilityLabelCheck, self.elementWithThreeChecks
      ]
                                                           screenshot:self.dummyImage] ];
  [self gscxtest_assertSectionsWithGroupedByScanResultsEqualResults:results];
}

- (void)testSectionsWithGroupedByCheckResultsNameEmptyResults {
  NSArray<GSCXScannerIssueTableViewSection *> *sections =
      [GSCXContinuousScannerListTabBarUtils sectionsWithGroupedByCheckResults:@[]];
  XCTAssertEqual(sections.count, 0);
}

- (void)testSectionsWithGroupedByCheckResultsNameOneResultOneIssue {
  NSArray<GTXHierarchyResultCollection *> *results = @[ [[GTXHierarchyResultCollection alloc]
      initWithElementResults:@[ self.elementWithAccessibilityLabelCheck ]
                  screenshot:self.dummyImage] ];
  NSArray<NSString *> *expectedCheckNames = @[ kGSCXTestAccessibilityLabelCheckName ];
  NSArray<NSArray<NSString *> *> *expectedRowTitles =
      @[ @[ self.elementWithAccessibilityLabelCheck.elementReference.elementDescription ] ];
  [self gscxtest_assertSectionsWithGroupedByCheckResults:results
                                        equalsCheckNames:expectedCheckNames
                                               rowTitles:expectedRowTitles];
}

- (void)testSectionsWithGroupedByCheckResultsNameOneResultManyIssues {
  NSArray<GTXHierarchyResultCollection *> *results = @[ [[GTXHierarchyResultCollection alloc]
      initWithElementResults:@[ self.elementWithThreeChecks ]
                  screenshot:self.dummyImage] ];
  NSArray<NSString *> *expectedCheckNames = @[
    kGSCXTestAccessibilityLabelCheckName, kGSCXTestContrastRatioCheckName,
    kGSCXTestTouchTargetSizeCheckName
  ];
  NSArray<NSArray<NSString *> *> *expectedRowTitles = @[
    @[ self.elementWithThreeChecks.elementReference.elementDescription ],
    @[ self.elementWithThreeChecks.elementReference.elementDescription ],
    @[ self.elementWithThreeChecks.elementReference.elementDescription ]
  ];
  [self gscxtest_assertSectionsWithGroupedByCheckResults:results
                                        equalsCheckNames:expectedCheckNames
                                               rowTitles:expectedRowTitles];
}

- (void)testSectionsWithGroupedByCheckResultsNameManyResultsOneIssueSameChecks {
  NSArray<GTXHierarchyResultCollection *> *results = @[
    [[GTXHierarchyResultCollection alloc]
        initWithElementResults:@[ self.elementWithAccessibilityLabelCheck ]
                    screenshot:self.dummyImage],
    [[GTXHierarchyResultCollection alloc]
        initWithElementResults:@[ self.elementWithAccessibilityLabelCheck ]
                    screenshot:self.dummyImage]
  ];
  NSArray<NSString *> *expectedCheckNames = @[ kGSCXTestAccessibilityLabelCheckName ];
  NSArray<NSArray<NSString *> *> *expectedRowTitles = @[ @[
    self.elementWithAccessibilityLabelCheck.elementReference.elementDescription,
    self.elementWithAccessibilityLabelCheck.elementReference.elementDescription
  ] ];
  [self gscxtest_assertSectionsWithGroupedByCheckResults:results
                                        equalsCheckNames:expectedCheckNames
                                               rowTitles:expectedRowTitles];
}

- (void)testSectionsWithGroupedByCheckResultsNameManyResultsOneIssueDifferentChecks {
  NSArray<GTXHierarchyResultCollection *> *results = @[
    [[GTXHierarchyResultCollection alloc]
        initWithElementResults:@[ self.elementWithAccessibilityLabelCheck ]
                    screenshot:self.dummyImage],
    [[GTXHierarchyResultCollection alloc]
        initWithElementResults:@[ self.elementWithTouchTargetCheck ]
                    screenshot:self.dummyImage]
  ];
  NSArray<NSString *> *expectedCheckNames =
      @[ kGSCXTestAccessibilityLabelCheckName, kGSCXTestTouchTargetSizeCheckName ];
  NSArray<NSArray<NSString *> *> *expectedRowTitles = @[
    @[ self.elementWithAccessibilityLabelCheck.elementReference.elementDescription ],
    @[ self.elementWithTouchTargetCheck.elementReference.elementDescription ],
  ];
  [self gscxtest_assertSectionsWithGroupedByCheckResults:results
                                        equalsCheckNames:expectedCheckNames
                                               rowTitles:expectedRowTitles];
}

- (void)testSectionsWithGroupedByCheckResultsNameManyResultsOneIssueDifferentChecksOutOfOrder {
  NSArray<GTXHierarchyResultCollection *> *results = @[
    [[GTXHierarchyResultCollection alloc]
        initWithElementResults:@[ self.elementWithTouchTargetCheck ]
                    screenshot:self.dummyImage],
    [[GTXHierarchyResultCollection alloc]
        initWithElementResults:@[ self.elementWithAccessibilityLabelCheck ]
                    screenshot:self.dummyImage]
  ];
  NSArray<NSString *> *expectedCheckNames =
      @[ kGSCXTestAccessibilityLabelCheckName, kGSCXTestTouchTargetSizeCheckName ];
  NSArray<NSArray<NSString *> *> *expectedRowTitles = @[
    @[ self.elementWithAccessibilityLabelCheck.elementReference.elementDescription ],
    @[ self.elementWithTouchTargetCheck.elementReference.elementDescription ],
  ];
  [self gscxtest_assertSectionsWithGroupedByCheckResults:results
                                        equalsCheckNames:expectedCheckNames
                                               rowTitles:expectedRowTitles];
}

- (void)testSectionsWithGroupedByCheckResultsNameManyResultsManyOverlappingIssues {
  NSArray<GTXHierarchyResultCollection *> *results = @[
    [[GTXHierarchyResultCollection alloc] initWithElementResults:@[
      self.elementWithTouchTargetCheck,
      self.elementWithThreeChecks,
    ]
                                                      screenshot:self.dummyImage],
    [[GTXHierarchyResultCollection alloc]
        initWithElementResults:@[ self.elementWithAccessibilityLabelCheck ]
                    screenshot:self.dummyImage]
  ];
  NSArray<NSString *> *expectedCheckNames = @[
    kGSCXTestAccessibilityLabelCheckName, kGSCXTestContrastRatioCheckName,
    kGSCXTestTouchTargetSizeCheckName
  ];
  NSArray<NSArray<NSString *> *> *expectedRowTitles = @[
    @[
      self.elementWithThreeChecks.elementReference.elementDescription,
      self.elementWithAccessibilityLabelCheck.elementReference.elementDescription
    ],
    @[ self.elementWithThreeChecks.elementReference.elementDescription ],
    @[
      self.elementWithTouchTargetCheck.elementReference.elementDescription,
      self.elementWithThreeChecks.elementReference.elementDescription
    ]
  ];
  [self gscxtest_assertSectionsWithGroupedByCheckResults:results
                                        equalsCheckNames:expectedCheckNames
                                               rowTitles:expectedRowTitles];
}

#pragma mark - Private

/**
 * Constructs an array of @c GSCXScannerIssueTableViewSection instances using
 * @c sectionsWithGroupedByScanResults and compares its structure to @c results. If the sections,
 * rows, and suggestions in @c sections do not correspond to the hierarchy results, element results,
 * and check results in @c results, the test fails.
 *
 * @param results An array of @c GTXHierarchyResultCollection instances to convert to
 *  @c GSCXScannerIssueTableViewSection instances.
 */
- (void)gscxtest_assertSectionsWithGroupedByScanResultsEqualResults:
    (NSArray<GTXHierarchyResultCollection *> *)results {
  NSArray<GSCXScannerIssueTableViewSection *> *sections =
      [GSCXContinuousScannerListTabBarUtils sectionsWithGroupedByScanResults:results];
  XCTAssertEqual(sections.count, results.count);
  for (NSUInteger i = 0; i < sections.count; i++) {
    XCTAssertEqual([sections[i] numberOfRows], results[i].elementResults.count);
    XCTAssertEqual([sections[i] numberOfSuggestions], [results[i] checkResultCount]);
  }
}

/**
 * Constructs an array of @c GSCXScannerIssueTableViewSection instances using
 * @c sectionsWithGroupedByCheckResults and compares its structure to @c results. The sections
 * correspond to the underlying checks in the issues in the results. The rows correspond to
 * individual UI elements failing the checks associated with their sections. The suggestion
 * corresponds to the underlying check. If any of these do not match, the test fails.
 *
 * @param results An array of @c GTXHierarchyResultCollection objects to convert to an array of
 *  @c GSCXScannerIssueTableViewSection objects.
 * @param checkNames The expected check names associated with the converted sections, in order.
 * @param rowTitles The expected row titles for each row in each section, in the same order as
 *  @c checkNames.
 */
- (void)gscxtest_assertSectionsWithGroupedByCheckResults:
            (NSArray<GTXHierarchyResultCollection *> *)results
                                        equalsCheckNames:(NSArray<NSString *> *)checkNames
                                               rowTitles:
                                                   (NSArray<NSArray<NSString *> *> *)rowTitles {
  NSArray<GSCXScannerIssueTableViewSection *> *sections =
      [GSCXContinuousScannerListTabBarUtils sectionsWithGroupedByCheckResults:results];
  XCTAssertEqual(sections.count, checkNames.count);
  [self gscxtest_assertElementsAreUnique:checkNames];
  for (NSUInteger i = 0; i < checkNames.count; i++) {
    NSString *checkName = checkNames[i];
    NSArray<NSString *> *rowTitlesForCheck = rowTitles[i];
    XCTAssertEqualObjects(sections[i].title, checkName);
    XCTAssertEqual([sections[i] numberOfRows], rowTitlesForCheck.count);
    for (NSUInteger j = 0; j < rowTitlesForCheck.count; j++) {
      XCTAssertEqualObjects(sections[i].rows[j].rowTitle, rowTitlesForCheck[j]);
      XCTAssertEqual([sections[i].rows[j] numberOfSuggestions], 1);
      XCTAssertEqualObjects(sections[i].rows[j].suggestionTitles[0], checkName);
    }
  }
}

/**
 * Asserts @c elements contains only unique objects. Fails the test if @c elements contains a
 * duplicate element.
 *
 * @param elements An array of elements to assert for uniqueness.
 */
- (void)gscxtest_assertElementsAreUnique:(NSArray<NSString *> *)elements {
  NSSet<NSString *> *uniqueCheckNames = [NSSet setWithArray:elements];
  XCTAssertEqual(uniqueCheckNames.count, elements.count);
}

@end

NS_ASSUME_NONNULL_END
