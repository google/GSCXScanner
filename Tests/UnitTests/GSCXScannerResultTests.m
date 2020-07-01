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

/**
 * A blank image to pass to @c GSCXScannerResult initializers.
 */
@property(strong, nonatomic) UIImage *dummyImage;

@end

@implementation GSCXScannerResultTests

- (void)setUp {
  [super setUp];
  self.dummyImage = [[UIImage alloc] init];
}

/**
 * Constructs a @c GSCXScannerIssue instance with the given check names, corresponding descriptions,
 * and element address. All other properties are set to their default.
 *
 * @param checkNames An array of check names. The corresponding check descriptions are automatically
 * used. A default description is set if the corresponding description cannot be found for a check
 * name.
 * @param elementAddress The address of the UI element associated with the check as an integer.
 * @return A @c GSCXScannerIssue instance with the given check names, corresponding descriptions,
 * element address, and default remaining parameters.
 */
- (GSCXScannerIssue *)defaultIssueWithCheckNames:(NSArray<NSString *> *)checkNames
                                  elementAddress:(NSUInteger)elementAddress {
  NSMutableArray<NSString *> *checkDescriptions = [NSMutableArray array];
  for (NSString *checkName in checkNames) {
    if ([checkName isEqualToString:kGSCXScannerResultTestsCheckName1]) {
      [checkDescriptions addObject:kGSCXScannerResultTestsCheckDescription1];
    } else if ([checkName isEqualToString:kGSCXScannerResultTestsCheckName2]) {
      [checkDescriptions addObject:kGSCXScannerResultTestsCheckDescription2];
    } else if ([checkName isEqualToString:kGSCXScannerResultTestsCheckName3]) {
      [checkDescriptions addObject:kGSCXScannerResultTestsCheckDescription3];
    } else {
      [checkDescriptions addObject:@"Description for unknown check name"];
    }
  }
  return [[GSCXScannerIssue alloc] initWithCheckNames:checkNames
                                    checkDescriptions:checkDescriptions
                                       elementAddress:elementAddress
                                         elementClass:[UIView class]
                                  frameInScreenBounds:CGRectZero
                                   accessibilityLabel:nil
                              accessibilityIdentifier:nil
                                   elementDescription:@"Unknown"];
}

- (void)testIssueCountIsZeroWithEmptyIssues {
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                             screenshot:self.dummyImage];
  XCTAssertEqual(result.issueCount, 0ul);
}

- (void)testSingleGTXIssueInSingleScannerIssue {
  NSArray<GSCXScannerIssue *> *issues =
      @[ [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                             checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                                elementAddress:0
                                  elementClass:[UIView class]
                           frameInScreenBounds:kGSCXScannerResultTestsFrame1
                            accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                       accessibilityIdentifier:nil] ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];

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
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
                  accessibilityIdentifier:nil]
  ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];

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
          issueWithCheckNames:@[
            kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2
          ]
            checkDescriptions:@[
              kGSCXScannerResultTestsCheckDescription1, kGSCXScannerResultTestsCheckDescription2
            ]
               elementAddress:0
                 elementClass:[UIView class]
          frameInScreenBounds:kGSCXScannerResultTestsFrame1
           accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
      accessibilityIdentifier:nil] ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];

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
                 elementAddress:0
                   elementClass:[UIView class]
            frameInScreenBounds:kGSCXScannerResultTestsFrame1
             accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
        accessibilityIdentifier:nil],
    [GSCXScannerIssue
            issueWithCheckNames:@[
              kGSCXScannerResultTestsCheckName2, kGSCXScannerResultTestsCheckName3
            ]
              checkDescriptions:@[
                kGSCXScannerResultTestsCheckDescription2, kGSCXScannerResultTestsCheckDescription3
              ]
                 elementAddress:0
                   elementClass:[UIView class]
            frameInScreenBounds:kGSCXScannerResultTestsFrame2
             accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
        accessibilityIdentifier:nil]
  ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];

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
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue
            issueWithCheckNames:@[
              kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2
            ]
              checkDescriptions:@[
                kGSCXScannerResultTestsCheckDescription1, kGSCXScannerResultTestsCheckDescription2
              ]
                 elementAddress:0
                   elementClass:[UIView class]
            frameInScreenBounds:kGSCXScannerResultTestsFrame2
             accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
        accessibilityIdentifier:nil]
  ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];

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
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                             screenshot:self.dummyImage];
  GSCXScannerResult *filteredResult = [result resultWithIssuesAtPoint:CGPointZero];
  XCTAssertEqual(filteredResult.issueCount, 0ul);
}

- (void)testResultWithIssuesAtPointWithSingleIssueContainingPoint {
  NSArray<GSCXScannerIssue *> *issues =
      @[ [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                             checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                                elementAddress:0
                                  elementClass:[UIView class]
                           frameInScreenBounds:kGSCXScannerResultTestsFrame1
                            accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                       accessibilityIdentifier:nil] ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];
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
                                elementAddress:0
                                  elementClass:[UIView class]
                           frameInScreenBounds:kGSCXScannerResultTestsFrame1
                            accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                       accessibilityIdentifier:nil] ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];
  GSCXScannerResult *filteredResult = [result resultWithIssuesAtPoint:CGPointZero];

  XCTAssertEqual(filteredResult.issueCount, 0ul);
}

- (void)testResultWithIssuesAtPointWithMultipleIssuesSingleIssueContainingPoint {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
                  accessibilityIdentifier:nil]
  ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];
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
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription3 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame3
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel3
                  accessibilityIdentifier:nil]
  ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];
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
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription3 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame3
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel3
                  accessibilityIdentifier:nil]
  ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];
  GSCXScannerResult *filteredResult = [result resultWithIssuesAtPoint:CGPointZero];

  XCTAssertEqual(filteredResult.issueCount, 0ul);
}

- (void)testGSCXIssueCanProvideHTMLDescriptions {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
                  accessibilityIdentifier:nil]
  ];

  NSInteger assertionCount = 0;
  for (GSCXScannerIssue *issue in issues) {
    NSString *htmlDescription = [issue htmlDescription];
    for (NSString *name in issue.gtxCheckNames) {
      XCTAssertTrue([htmlDescription containsString:name]);
      assertionCount += 1;
    }
  }
  XCTAssertGreaterThanOrEqual(assertionCount, 1, @"At least one HTML must be checked.");
}

- (void)testGSCXResultCanProvideHTMLDescription {
  NSArray<GSCXScannerIssue *> *issues = @[
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription1 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame1
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel1
                  accessibilityIdentifier:nil],
    [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                        checkDescriptions:@[ kGSCXScannerResultTestsCheckDescription2 ]
                           elementAddress:0
                             elementClass:[UIView class]
                      frameInScreenBounds:kGSCXScannerResultTestsFrame2
                       accessibilityLabel:kGSCXScannerResultTestsAccessibilityLabel2
                  accessibilityIdentifier:nil]
  ];
  GSCXScannerResult *result = [[GSCXScannerResult alloc] initWithIssues:issues
                                                             screenshot:self.dummyImage];
  NSString *resultHTML = [result htmlDescription:[[GSCXReportContext alloc] init]];

  NSInteger assertionCount = 0;
  for (GSCXScannerIssue *issue in issues) {
    for (NSString *name in issue.gtxCheckNames) {
      XCTAssertTrue([resultHTML containsString:name]);
      assertionCount += 1;
    }
  }
  XCTAssertGreaterThanOrEqual(assertionCount, 1, @"At least one HTML must be checked.");
}

- (void)testDedupeWithEmptyResultsEmptyisEmpty {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 0);
  XCTAssertEqual([result2.issues count], 0);
}

- (void)testDedupeWithEmptyAndNonEmptyResultsIsNonEmpty {
  GSCXScannerIssue *issue1 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                               elementAddress:1];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue1 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 1);
  XCTAssertEqual([result1.issues[0].gtxCheckNames count], 1);
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames[0], kGSCXScannerResultTestsCheckName1);
  XCTAssertEqual([result2.issues count], 0);
}

- (void)testDedupeWithNonEmptyAndEmptyResultsIsEmpty {
  GSCXScannerIssue *issue2 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                               elementAddress:1];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue2 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 0);
  XCTAssertEqual([result2.issues count], 1);
  XCTAssertEqualObjects(result2.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
}

- (void)testDedupeWithOneIssueAndOneIssueEqualDoesDedupe {
  GSCXScannerIssue *issue1 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                               elementAddress:1];
  GSCXScannerIssue *issue2 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                               elementAddress:1];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue1 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue2 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 1);
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
  XCTAssertEqual([result2.issues count], 0);
}

- (void)testDedupeWithOneIssueAndOneIssueNotEqualDoesNotDedupe {
  GSCXScannerIssue *issue1 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                               elementAddress:1];
  GSCXScannerIssue *issue2 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                                               elementAddress:2];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue1 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue2 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 1);
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
  XCTAssertEqual([result2.issues count], 1);
  XCTAssertEqualObjects(result2.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName2 ]);
}

- (void)testDedupeWithOneIssueAndOneIssueEqualOverlappingGTXChecksCombinesChecks {
  GSCXScannerIssue *issue1 = [self defaultIssueWithCheckNames:@[
    kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2
  ]
                                               elementAddress:1];
  GSCXScannerIssue *issue2 = [self defaultIssueWithCheckNames:@[
    kGSCXScannerResultTestsCheckName2, kGSCXScannerResultTestsCheckName3
  ]
                                               elementAddress:1];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue1 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue2 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 1);
  NSArray<NSString *> *expectedNames = @[
    kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2,
    kGSCXScannerResultTestsCheckName3
  ];
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, expectedNames);
  XCTAssertEqual([result2.issues count], 0);
}

- (void)testDedupeWithOneIssueAndManyIssuesNotEqualDoesNotDedupe {
  GSCXScannerIssue *issue1 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                               elementAddress:1];
  GSCXScannerIssue *issue21 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:2];
  GSCXScannerIssue *issue22 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ] elementAddress:3];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue1 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue21, issue22 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 1);
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
  XCTAssertEqual([result2.issues count], 2);
  XCTAssertEqualObjects(result2.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName2 ]);
  XCTAssertEqualObjects(result2.issues[1].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName3 ]);
}

- (void)testDedupeWithOneIssueAndManyIssuesOverlappingChecksCombinesChecks {
  GSCXScannerIssue *issue1 = [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                               elementAddress:1];
  GSCXScannerIssue *issue21 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:1];
  GSCXScannerIssue *issue22 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ] elementAddress:3];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue1 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue21, issue22 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 1);
  XCTAssertEqual([result1.issues[0].gtxCheckNames count], 2);
  NSArray<NSString *> *expectedNames1 =
      @[ kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2 ];
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, expectedNames1);
  XCTAssertEqual([result2.issues count], 1);
  XCTAssertEqualObjects(result2.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName3 ]);
}

- (void)testDedupeWithManyIssuesAndManyIssuesEqualDedupes {
  GSCXScannerIssue *issue11 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:1];
  GSCXScannerIssue *issue12 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:2];
  GSCXScannerIssue *issue21 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:2];
  GSCXScannerIssue *issue22 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:1];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue11, issue12 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue21, issue22 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 2);
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
  XCTAssertEqualObjects(result1.issues[1].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName2 ]);
  XCTAssertEqual([result2.issues count], 0);
}

- (void)testDedupeWithManyIssuesAndManyIssuesDifferentChecksCombinesChecks {
  GSCXScannerIssue *issue11 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:1];
  GSCXScannerIssue *issue12 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:2];
  GSCXScannerIssue *issue21 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:2];
  GSCXScannerIssue *issue22 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:1];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue11, issue12 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue21, issue22 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 2);
  NSArray<NSString *> *expectedNames1 =
      @[ kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2 ];
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, expectedNames1);
  NSArray<NSString *> *expectedNames2 =
      @[ kGSCXScannerResultTestsCheckName2, kGSCXScannerResultTestsCheckName1 ];
  XCTAssertEqualObjects(result1.issues[1].gtxCheckNames, expectedNames2);
  XCTAssertEqual([result2.issues count], 0);
}

- (void)testDedupeWithManyIssuesAndManyIssuesOverlappingChecksCombinesChecks {
  GSCXScannerIssue *issue11 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:1];
  GSCXScannerIssue *issue12 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:2];
  GSCXScannerIssue *issue21 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ] elementAddress:3];
  GSCXScannerIssue *issue22 =
      [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:2];
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[ issue11, issue12 ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[ issue21, issue22 ]
                                                              screenshot:self.dummyImage];
  [result1 moveIssuesWithExistingElementsFromResult:result2];
  XCTAssertEqual([result1.issues count], 2);
  XCTAssertEqualObjects(result1.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
  NSArray<NSString *> *expectedNames1 =
      @[ kGSCXScannerResultTestsCheckName2, kGSCXScannerResultTestsCheckName1 ];
  XCTAssertEqualObjects(result1.issues[1].gtxCheckNames, expectedNames1);
  XCTAssertEqual([result2.issues count], 1);
  XCTAssertEqualObjects(result2.issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName3 ]);
}

- (void)testArrayByDedupingEmptyArray {
  NSArray<GSCXScannerResult *> *actual = [GSCXScannerResult resultsArrayByDedupingResultsArray:@[]];
  XCTAssertEqualObjects(actual, @[]);
}

- (void)testArrayByDedupingOneElementArray {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                          elementAddress:1] ]
          screenshot:self.dummyImage];
  NSArray<GSCXScannerResult *> *results = @[ result1 ];
  NSArray<GSCXScannerResult *> *actual =
      [GSCXScannerResult resultsArrayByDedupingResultsArray:results];
  XCTAssertEqual([actual count], 1);
  XCTAssertEqual([actual[0].issues count], 1);
  XCTAssertEqualObjects(actual[0].issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
}

- (void)testArrayByDedupingMultipleNotEqualElementsArray {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                          elementAddress:1] ]
          screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                                          elementAddress:2] ]
          screenshot:self.dummyImage];
  NSArray<GSCXScannerResult *> *results = @[ result1, result2 ];
  NSArray<GSCXScannerResult *> *actual =
      [GSCXScannerResult resultsArrayByDedupingResultsArray:results];
  XCTAssertEqual([actual count], 2);
  XCTAssertEqual([actual[0].issues count], 1);
  XCTAssertEqualObjects(actual[0].issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
  XCTAssertEqual([actual[1].issues count], 1);
  XCTAssertEqualObjects(actual[1].issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName2 ]);
}

- (void)testArrayByDedupingMultipleFirstHasNoIssues {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                                          elementAddress:2] ]
          screenshot:self.dummyImage];
  NSArray<GSCXScannerResult *> *results = @[ result1, result2 ];
  NSArray<GSCXScannerResult *> *actual =
      [GSCXScannerResult resultsArrayByDedupingResultsArray:results];
  XCTAssertEqual([actual count], 1);
  XCTAssertEqual([actual[0].issues count], 1);
  XCTAssertEqualObjects(actual[0].issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName2 ]);
}

- (void)testArrayByDedupingMultipleLastHasNoIssues {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                          elementAddress:1] ]
          screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[]
                                                              screenshot:self.dummyImage];
  NSArray<GSCXScannerResult *> *results = @[ result1, result2 ];
  NSArray<GSCXScannerResult *> *actual =
      [GSCXScannerResult resultsArrayByDedupingResultsArray:results];
  XCTAssertEqual([actual count], 1);
  XCTAssertEqual([actual[0].issues count], 1);
  XCTAssertEqualObjects(actual[0].issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
}

- (void)testArrayByDedupingMultipleEqualElementsArray {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                          elementAddress:1] ]
          screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                          elementAddress:1] ]
          screenshot:self.dummyImage];
  NSArray<GSCXScannerResult *> *results = @[ result1, result2 ];
  NSArray<GSCXScannerResult *> *actual =
      [GSCXScannerResult resultsArrayByDedupingResultsArray:results];
  XCTAssertEqual([actual count], 1);
  XCTAssertEqual([actual[0].issues count], 1);
  XCTAssertEqualObjects(actual[0].issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName1 ]);
}

- (void)testArrayByDedupingMultipleSomeEqualSomeNotEqualElementsArray {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ]
                                          elementAddress:1] ]
          screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ]
                                          elementAddress:2] ]
          screenshot:self.dummyImage];
  GSCXScannerResult *result3 = [[GSCXScannerResult alloc]
      initWithIssues:@[ [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ]
                                          elementAddress:1] ]
          screenshot:self.dummyImage];
  NSArray<GSCXScannerResult *> *results = @[ result1, result2, result3 ];
  NSArray<GSCXScannerResult *> *actual =
      [GSCXScannerResult resultsArrayByDedupingResultsArray:results];
  XCTAssertEqual([actual count], 2);
  XCTAssertEqual([actual[0].issues count], 1);
  NSArray<NSString *> *expectedNames1 =
      @[ kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName3 ];
  XCTAssertEqualObjects(actual[0].issues[0].gtxCheckNames, expectedNames1);
  XCTAssertEqual([actual[1].issues count], 1);
  XCTAssertEqualObjects(actual[1].issues[0].gtxCheckNames, @[ kGSCXScannerResultTestsCheckName2 ]);
}

- (void)testArrayByDedupingMultipleEqualElementsMultipleIssuesArray {
  GSCXScannerResult *result1 = [[GSCXScannerResult alloc] initWithIssues:@[
    [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:1],
    [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName1 ] elementAddress:2]
  ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result2 = [[GSCXScannerResult alloc] initWithIssues:@[
    [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:3],
    [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:1],
    [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName2 ] elementAddress:2]
  ]
                                                              screenshot:self.dummyImage];
  GSCXScannerResult *result3 = [[GSCXScannerResult alloc] initWithIssues:@[
    [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ] elementAddress:3],
    [self defaultIssueWithCheckNames:@[ kGSCXScannerResultTestsCheckName3 ] elementAddress:2]
  ]
                                                              screenshot:self.dummyImage];
  NSArray<GSCXScannerResult *> *results = @[ result1, result2, result3 ];
  NSArray<GSCXScannerResult *> *actual =
      [GSCXScannerResult resultsArrayByDedupingResultsArray:results];
  XCTAssertEqual([actual count], 2);
  XCTAssertEqual([actual[0].issues count], 2);
  NSArray<NSString *> *expectedNames11 =
      @[ kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2 ];
  XCTAssertEqualObjects(actual[0].issues[0].gtxCheckNames, expectedNames11);
  NSArray<NSString *> *expectedNames12 = @[
    kGSCXScannerResultTestsCheckName1, kGSCXScannerResultTestsCheckName2,
    kGSCXScannerResultTestsCheckName3
  ];
  XCTAssertEqualObjects(actual[0].issues[1].gtxCheckNames, expectedNames12);
  XCTAssertEqual([actual[1].issues count], 1);
  NSArray<NSString *> *expectedNames21 =
      @[ kGSCXScannerResultTestsCheckName2, kGSCXScannerResultTestsCheckName3 ];
  XCTAssertEqualObjects(actual[1].issues[0].gtxCheckNames, expectedNames21);
}

@end

NS_ASSUME_NONNULL_END
