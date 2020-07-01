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

#import "GSCXScannerIssueTableViewRow.h"

#import <XCTest/XCTest.h>

#import "GSCXScannerIssue.h"
#import "GSCXTestCheckNames.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerIssueTableViewRowTests : XCTestCase

/**
 * The @c GSCXScannerIssueTableViewRow instance under test. Reset at the beginning of each test.
 */
@property(strong, nonatomic) GSCXScannerIssueTableViewRow *rowUnderTest;

@end

@implementation GSCXScannerIssueTableViewRowTests

- (void)setUp {
  [super setUp];
  GSCXScannerIssue *dummyIssue = [[GSCXScannerIssue alloc] initWithCheckNames:@[ @"Check" ]
                                                            checkDescriptions:@[ @"Description" ]
                                                               elementAddress:0
                                                                 elementClass:[UIView class]
                                                          frameInScreenBounds:CGRectZero
                                                           accessibilityLabel:nil
                                                      accessibilityIdentifier:nil
                                                           elementDescription:@"Element"];
  UIImage *image = [[UIImage alloc] init];
  GSCXScannerResult *dummyResult = [[GSCXScannerResult alloc] initWithIssues:@[ dummyIssue ]
                                                                  screenshot:image];
  self.rowUnderTest = [[GSCXScannerIssueTableViewRow alloc] initWithIssue:dummyIssue
                                                                    title:@""
                                                                 subtitle:@""
                                                           originalResult:dummyResult
                                                       originalIssueIndex:0];
}

- (void)testZeroSuggestionsExistWhenAddSuggestionIsNotCalled {
  XCTAssertEqual([self.rowUnderTest numberOfSuggestions], 0);
}

- (void)testOneSuggestionsExistsWhenAddSuggestionIsCalledOnce {
  [self.rowUnderTest addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                                   contents:kGSCXTestAccessibilityLabelCheckDescription];
  XCTAssertEqual([self.rowUnderTest numberOfSuggestions], 1);
  XCTAssertEqualObjects(self.rowUnderTest.suggestionTitles,
                        @[ kGSCXTestAccessibilityLabelCheckName ]);
  XCTAssertEqualObjects(self.rowUnderTest.suggestionContents,
                        @[ kGSCXTestAccessibilityLabelCheckDescription ]);
}

- (void)testManySuggestionsExistWhenAddSuggestionIsCalledManyTimes {
  [self.rowUnderTest addSuggestionWithTitle:kGSCXTestAccessibilityLabelCheckName
                                   contents:kGSCXTestAccessibilityLabelCheckDescription];
  [self.rowUnderTest addSuggestionWithTitle:kGSCXTestContrastRatioCheckName
                                   contents:kGSCXTestContrastRatioCheckDescription];
  [self.rowUnderTest addSuggestionWithTitle:kGSCXTestTouchTargetSizeCheckName
                                   contents:kGSCXTestTouchTargetSizeCheckDescription];
  XCTAssertEqual([self.rowUnderTest numberOfSuggestions], 3);
  NSArray<NSString *> *expectedTitles = @[
    kGSCXTestAccessibilityLabelCheckName, kGSCXTestContrastRatioCheckName,
    kGSCXTestTouchTargetSizeCheckName
  ];
  XCTAssertEqualObjects(self.rowUnderTest.suggestionTitles, expectedTitles);
  NSArray<NSString *> *expectedContents = @[
    kGSCXTestAccessibilityLabelCheckDescription, kGSCXTestContrastRatioCheckDescription,
    kGSCXTestTouchTargetSizeCheckDescription
  ];
  XCTAssertEqualObjects(self.rowUnderTest.suggestionContents, expectedContents);
}

@end

NS_ASSUME_NONNULL_END
