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

#import "GSCXScannerResult.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kGSCXScannerResultTestsCheckName1 = @"kGSCXScannerResultTestsCheckName1";
static NSString *const kGSCXScannerResultTestsCheckName2 = @"kGSCXScannerResultTestsCheckName2";
static NSString *const kGSCXScannerResultTestsCheckName3 = @"kGSCXScannerResultTestsCheckName3";
static NSString *const kGSCXScannerResultTestsCheckDescription1 =
    @"kGSCXScannerResultTestsCheckDescription1";
static NSString *const kGSCXScannerResultTestsCheckDescription2 =
    @"kGSCXScannerResultTestsCheckDescription2";
static NSString *const kGSCXScannerResultTestsCheckDescription3 =
    @"kGSCXScannerResultTestsCheckDescription3";
static const CGRect kGSCXScannerResultTestsFrame1 = {{1, 2}, {3, 4}};
static const CGRect kGSCXScannerResultTestsFrame2 = {{5, 6}, {7, 8}};
static const CGRect kGSCXScannerResultTestsFrame3 = {{2, 3}, {4, 5}};
static const CGPoint kGSCXScannerResultTestsContainingPoint1 = {2, 3};
static const CGPoint kGSCXScannerResultTestsContainingPoint2 = {6, 7};
static const CGPoint kGSCXScannerResultTestsContainingPoint3 = {3, 4};
static NSString *const kGSCXScannerResultTestsAccessibilityLabel1 =
    @"kGSCXScannerResultTestsAccessibilityLabel1";
static NSString *const kGSCXScannerResultTestsAccessibilityLabel2 =
    @"kGSCXScannerResultTestsAccessibilityLabel2";
static NSString *const kGSCXScannerResultTestsAccessibilityLabel3 =
    @"kGSCXScannerResultTestsAccessibilityLabel3";

@interface GSCXScannerResultTests : XCTestCase
@end

@implementation GSCXScannerResultTests

- (void)testIssueCountIsZeroWithEmptyIssues {
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:@[] screenshot:nil];
  XCTAssertEqual(result.issueCount, 0ul);
}

- (void)testSingleGTXIssueInSingleScannerIssue {
  NSArray<GSCXScannerIssue *> *issues =
      @[ [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                             checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                           frameInScreenBounds:kGSCXScannerResultTestsFrame1
                            accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1] ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];

  XCTAssertEqual(result.issueCount, 1ul);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel1);
}

- (void)testSingleGTXIssueInMultipleScannerIssues {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2]
  ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];

  XCTAssertEqual(result.issueCount, 2ul);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel1);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:1], kGSCXScannerResultTestsCheckName2);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:1],
                        kGSCXScannerResultTestsCheckDescription2);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:1], kGSCXScannerResultTestsFrame2));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:1],
                        kGSCXScannerResultTestsAccessibilityLabel2);
}

- (void)testMultipleGTXIssuesInSingleScannerIssue {
  NSArray<GSCXScannerIssue *> *issues = @[ [GSCXScannerIssue
      issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2 ]
        checkDescriptions:@[
          kGSCXScannerResultTestsCheckDescription1, kGSCXScannerResultTestsCheckDescription2
        ]
      frameInScreenBounds:kGSCXScannerResultTestsFrame1
       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1] ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];

  XCTAssertEqual(result.issueCount, 2ul);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel1);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:1], kGSCXScannerResultTestsCheckName2);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:1],
                        kGSCXScannerResultTestsCheckDescription2);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:1], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:1],
                        kGSCXScannerResultTestsAccessibilityLabel1);
}

- (void)testMultipleGTXIssuesInMultipleScannerIssues {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue
        issueWithCheckNames:@[
          kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2
        ]
          checkDescriptions:@[
            kGSCXScannerResultTestsCheckDescription1, kGSCXScannerResultTestsCheckDescription2
          ]
        frameInScreenBounds:kGSCXScannerResultTestsFrame1
         accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1],
    [GSCXScannerIssue
        issueWithCheckNames:@[
          kGSCXScannerResultTestsCheckName2, kGSCXScannerResultTestsCheckName3
        ]
          checkDescriptions:@[
            kGSCXScannerResultTestsCheckDescription2, kGSCXScannerResultTestsCheckDescription3
          ]
        frameInScreenBounds:kGSCXScannerResultTestsFrame2
         accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2]
  ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];

  XCTAssertEqual(result.issueCount, 4ul);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel1);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:1], kGSCXScannerResultTestsCheckName2);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:1],
                        kGSCXScannerResultTestsCheckDescription2);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:1], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:1],
                        kGSCXScannerResultTestsAccessibilityLabel1);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:2], kGSCXScannerResultTestsCheckName2);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:2],
                        kGSCXScannerResultTestsCheckDescription2);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:2], kGSCXScannerResultTestsFrame2));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:2],
                        kGSCXScannerResultTestsAccessibilityLabel2);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:3], kGSCXScannerResultTestsCheckName3);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:3],
                        kGSCXScannerResultTestsCheckDescription3);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:3], kGSCXScannerResultTestsFrame2));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:3],
                        kGSCXScannerResultTestsAccessibilityLabel2);
}

- (void)testSingleAndMultipleGTXIssuesInMultipleScannerIssues {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1],
    [GSCXScannerIssue
        issueWithCheckNames:@[
          kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2
        ]
          checkDescriptions:@[
            kGSCXScannerResultTestsCheckDescription1, kGSCXScannerResultTestsCheckDescription2
          ]
        frameInScreenBounds:kGSCXScannerResultTestsFrame2
         accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2]
  ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];

  XCTAssertEqual(result.issueCount, 3ul);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:0], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel1);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:1], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:1],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:1], kGSCXScannerResultTestsFrame2));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:1],
                        kGSCXScannerResultTestsAccessibilityLabel2);

  XCTAssertEqualObjects([result gtxCheckNameAtIndex:2], kGSCXScannerResultTestsCheckName2);
  XCTAssertEqualObjects([result gtxCheckDescriptionAtIndex:2],
                        kGSCXScannerResultTestsCheckDescription2);
  XCTAssert(CGRectEqualToRect([result frameAtIndex:2], kGSCXScannerResultTestsFrame2));
  XCTAssertEqualObjects([result accessibilityLabelAtIndex:2],
                        kGSCXScannerResultTestsAccessibilityLabel2);
}

- (void)testResultWithIssuesAtPointWithEmptyIssues {
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:@[] screenshot:nil];
  GSCXScannerResult *filteredResult = [result resultWithIssuesAtPoint:CGPointZero];
  XCTAssertEqual(filteredResult.issueCount, 0ul);
}

- (void)testResultWithIssuesAtPointWithSingleIssueContainingPoint {
  NSArray<GSCXScannerIssue *> *issues =
      @[ [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                             checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                           frameInScreenBounds:kGSCXScannerResultTestsFrame1
                            accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1] ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];
  GSCXScannerResult *filteredResult =
      [result resultWithIssuesAtPoint:kGSCXScannerResultTestsContainingPoint1];

  XCTAssertEqual(filteredResult.issueCount, 1ul);

  XCTAssertEqualObjects([filteredResult gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([filteredResult gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([filteredResult frameAtIndex:0], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([filteredResult accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel1);
}

- (void)testResultWithIssuesAtPointWithSingleIssueNotContainingPoint {
  NSArray<GSCXScannerIssue *> *issues =
      @[ [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                             checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                           frameInScreenBounds:kGSCXScannerResultTestsFrame1
                            accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1] ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];
  GSCXScannerResult *filteredResult = [result resultWithIssuesAtPoint:CGPointZero];

  XCTAssertEqual(filteredResult.issueCount, 0ul);
}

- (void)testResultWithIssuesAtPointWithMultipleIssuesSingleIssueContainingPoint {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2]
  ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];
  GSCXScannerResult *filteredResult =
      [result resultWithIssuesAtPoint:kGSCXScannerResultTestsContainingPoint2];

  XCTAssertEqual(filteredResult.issueCount, 1ul);

  XCTAssertEqualObjects([filteredResult gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName2);
  XCTAssertEqualObjects([filteredResult gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription2);
  XCTAssert(CGRectEqualToRect([filteredResult frameAtIndex:0], kGSCXScannerResultTestsFrame2));
  XCTAssertEqualObjects([filteredResult accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel2);
}

- (void)testResultWithIssuesAtPointWithMultipleIssuesMultipleContainingPoint {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription3 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame3
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel3]
  ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];
  GSCXScannerResult *filteredResult =
      [result resultWithIssuesAtPoint:kGSCXScannerResultTestsContainingPoint3];

  XCTAssertEqual(filteredResult.issueCount, 2ul);

  XCTAssertEqualObjects([filteredResult gtxCheckNameAtIndex:0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqualObjects([filteredResult gtxCheckDescriptionAtIndex:0],
                        kGSCXScannerResultTestsCheckDescription1);
  XCTAssert(CGRectEqualToRect([filteredResult frameAtIndex:0], kGSCXScannerResultTestsFrame1));
  XCTAssertEqualObjects([filteredResult accessibilityLabelAtIndex:0],
                        kGSCXScannerResultTestsAccessibilityLabel1);

  XCTAssertEqualObjects([filteredResult gtxCheckNameAtIndex:1], kGSCXScannerResultTestsCheckName3);
  XCTAssertEqualObjects([filteredResult gtxCheckDescriptionAtIndex:1],
                        kGSCXScannerResultTestsCheckDescription3);
  XCTAssert(CGRectEqualToRect([filteredResult frameAtIndex:1], kGSCXScannerResultTestsFrame3));
  XCTAssertEqualObjects([filteredResult accessibilityLabelAtIndex:1],
                        kGSCXScannerResultTestsAccessibilityLabel3);
}

- (void)testResultWithIssuesAtPointWithMultipleIssuesNoneContainingPoint {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription3 ]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame3
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel3]
  ];
  GSCXScannerResult *result = [GSCXScannerResult resultWithIssues:issues screenshot:nil];
  GSCXScannerResult *filteredResult = [result resultWithIssuesAtPoint:CGPointZero];

  XCTAssertEqual(filteredResult.issueCount, 0ul);
}

@end

NS_ASSUME_NONNULL_END
