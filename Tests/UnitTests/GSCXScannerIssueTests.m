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

#import "GSCXScannerIssue.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GSCXScannerTestsUtils.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The name of a dummy check. Required because @c GSCXScannerIssue instances cannot contain an empty
 * array of check names.
 */
static NSString *const kGSCXScannerIssueDummyCheckName1 = @"kGSCXScannerIssueDummyCheckName1";

/**
 * The name of another dummy check. Used to test deduping.
 */
static NSString *const kGSCXScannerIssueDummyCheckName2 = @"kGSCXScannerIssueDummyCheckName1";

/**
 * The description of a dummy check. Required because @c GSCXScannerIssue instances cannot contain
 * an empty array of check descriptions.
 */
static NSString *const kGSCXScannerIssueDummyCheckDescription1 =
    @"kGSCXScannerIssueDummyCheckDescription1";

/**
 * The description of another dummy check. Used to test deduping.
 */
static NSString *const kGSCXScannerIssueDummyCheckDescription2 =
    @"kGSCXScannerIssueDummyCheckDescription1";

@interface GSCXScannerIssueTests : XCTestCase
@end

@implementation GSCXScannerIssueTests

/**
 * Tests hasEqualElementAsIssue for all possible states. There are currently 32 different possible
 * states. Having 32 nearly identical tests is less readable than a single test with a slight amount
 * of logic, so the tests are consolidated here.
 */
- (void)testHasEqualElementAsIssueReturnsExpectedBoolean {
  // Maps an integer to the expected result of hasEqualElementAsIssue. The integer's bits represent
  // which components of GSCXScannerIssue are the same and which are different. A 1 means the
  // components are the same, a 0 means they're different. The bits are ordered left-to-right:
  //   Bit 1: elementAddress
  //   Bit 2: elementClass
  //   Bit 3: frame
  //   Bit 4: accessibilityLabel
  //   Bit 5: accessibilityIdentifier
  BOOL expected[32] = {
      NO,   // 00000
      NO,   // 00001
      NO,   // 00010
      NO,   // 00011
      NO,   // 00100
      NO,   // 00101
      NO,   // 00110
      NO,   // 00111
      NO,   // 01000
      YES,  // 01001
      NO,   // 01010
      YES,  // 01011
      NO,   // 01100
      YES,  // 01101
      NO,   // 01110
      YES,  // 01111
      NO,   // 10000
      NO,   // 10001
      NO,   // 10010
      NO,   // 10011
      NO,   // 10100
      NO,   // 10101
      NO,   // 10110
      NO,   // 10111
      YES,  // 11000
      YES,  // 11001
      YES,  // 11010
      YES,  // 11011
      YES,  // 11100
      YES,  // 11101
      YES,  // 11110
      YES,  // 11111
  };
  for (NSUInteger i = 0; i < 32; i++) {
    GSCXScannerIssue *issue1 =
        [self gscxtest_issueWithElementAddress:1
                                  elementClass:[UIView class]
                           frameInScreenBounds:CGRectZero
                             accesibilityLabel:[self gscxtest_uninternedString:@"axLabel1"]
                       accessibilityIdentifier:[self gscxtest_uninternedString:@"axId1"]];
    NSUInteger address2 = (i & 0b10000) ? 1 : 2;
    Class class2 = (i & 0b01000) ? [UIView class] : [UIButton class];
    CGRect frame2 = (i & 0b00100) ? CGRectZero : CGRectMake(0, 0, 1, 1);
    NSString *label2 = (i & 0b00010) ? @"axLabel1" : @"axLabel2";
    NSString *id2 = (i & 0b00001) ? @"axId1" : @"axId2";
    GSCXScannerIssue *issue2 = [self gscxtest_issueWithElementAddress:address2
                                                         elementClass:class2
                                                  frameInScreenBounds:frame2
                                                    accesibilityLabel:label2
                                              accessibilityIdentifier:id2];
    BOOL hasEqual = [issue1 hasEqualElementAsIssue:issue2];
    BOOL hasEqualSymmetric = [issue2 hasEqualElementAsIssue:issue1];
    NSString *expectedText = expected[i] ? @"YES" : @"NO";
    NSString *hasEqualText = hasEqual ? @"YES" : @"NO";
    NSString *hasEqualSymmetricText = hasEqualSymmetric ? @"YES" : @"NO";
    XCTAssertEqual(hasEqual, expected[i],
                   @"hasEqualElementAsIssue test %lu failed. Expected %@. Actual: %@",
                   (unsigned long)i, expectedText, hasEqualText);
    XCTAssertEqual(hasEqualSymmetric, expected[i],
                   @"hasEqualElementAsIssue symmetric test %lu failed. Expected %@. Actual: %@",
                   (unsigned long)i, expectedText, hasEqualSymmetricText);
    // issue1 does not change per iteration, so it is not useful to check it. issue2 iterates over
    // each possible state, so asserting each iteration checks all the states for reflexivity.
    XCTAssert([issue2 hasEqualElementAsIssue:issue2],
              @"hasEqualElementAsIssue reflexive test %lu failed. Expected YES. Actual: NO",
              (unsigned long)i);
  }
}

- (void)testHasEqualElementAsIssueAccessibilityLabelNilIsTrue {
  GSCXScannerIssue *issue1 = [self gscxtest_issueWithElementAddress:0
                                                       elementClass:[UIView class]
                                                frameInScreenBounds:CGRectZero
                                                  accesibilityLabel:nil
                                            accessibilityIdentifier:@"axId1"];
  GSCXScannerIssue *issue2 =
      [self gscxtest_issueWithElementAddress:1
                                elementClass:[UIView class]
                         frameInScreenBounds:CGRectZero
                           accesibilityLabel:[self gscxtest_uninternedString:@"axLabel1"]
                     accessibilityIdentifier:[self gscxtest_uninternedString:@"axId1"]];
  XCTAssert([issue1 hasEqualElementAsIssue:issue2]);
  XCTAssert([issue2 hasEqualElementAsIssue:issue1]);
  XCTAssert([issue1 hasEqualElementAsIssue:issue1]);
  XCTAssert([issue2 hasEqualElementAsIssue:issue2]);
}

- (void)testHasEqualElementAsIssueAccessibilityIdentifierNilIsTrue {
  GSCXScannerIssue *issue1 = [self gscxtest_issueWithElementAddress:0
                                                       elementClass:[UIView class]
                                                frameInScreenBounds:CGRectZero
                                                  accesibilityLabel:@"axLabel1"
                                            accessibilityIdentifier:nil];
  GSCXScannerIssue *issue2 =
      [self gscxtest_issueWithElementAddress:1
                                elementClass:[UIView class]
                         frameInScreenBounds:CGRectZero
                           accesibilityLabel:[self gscxtest_uninternedString:@"axLabel1"]
                     accessibilityIdentifier:[self gscxtest_uninternedString:@"axId1"]];
  XCTAssert([issue1 hasEqualElementAsIssue:issue2]);
  XCTAssert([issue2 hasEqualElementAsIssue:issue1]);
  XCTAssert([issue1 hasEqualElementAsIssue:issue1]);
  XCTAssert([issue2 hasEqualElementAsIssue:issue2]);
}

- (void)testHasEqualElementAsIssueAccessibilityLabelAndIdentifierNilIsFalse {
  GSCXScannerIssue *issue1 = [self gscxtest_issueWithElementAddress:0
                                                       elementClass:[UIView class]
                                                frameInScreenBounds:CGRectZero
                                                  accesibilityLabel:nil
                                            accessibilityIdentifier:nil];
  GSCXScannerIssue *issue2 =
      [self gscxtest_issueWithElementAddress:1
                                elementClass:[UIView class]
                         frameInScreenBounds:CGRectZero
                           accesibilityLabel:[self gscxtest_uninternedString:@"axLabel1"]
                     accessibilityIdentifier:[self gscxtest_uninternedString:@"axId1"]];
  XCTAssertFalse([issue1 hasEqualElementAsIssue:issue2]);
  XCTAssertFalse([issue2 hasEqualElementAsIssue:issue1]);
  XCTAssert([issue1 hasEqualElementAsIssue:issue1]);
  XCTAssert([issue2 hasEqualElementAsIssue:issue2]);
}

- (void)testArrayByDedupingArrayEmpty {
  NSArray<GSCXScannerIssue *> *issues = @[];
  NSArray<GSCXScannerIssue *> *expected = @[];
  NSArray<GSCXScannerIssue *> *result = [GSCXScannerIssue arrayByDedupingArray:issues];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testArrayByDedupingArrayOne {
  NSArray<GSCXScannerIssue *> *issues = @[ [self gscxtest_issueWithElementAddress:0
                                                                     elementClass:[UIView class]
                                                              frameInScreenBounds:CGRectZero
                                                                accesibilityLabel:@"axLabel"
                                                          accessibilityIdentifier:@"axId"] ];
  NSArray<GSCXScannerIssue *> *expected = @[ [self gscxtest_issueWithElementAddress:0
                                                                       elementClass:[UIView class]
                                                                frameInScreenBounds:CGRectZero
                                                                  accesibilityLabel:@"axLabel"
                                                            accessibilityIdentifier:@"axId"] ];
  NSArray<GSCXScannerIssue *> *result = [GSCXScannerIssue arrayByDedupingArray:issues];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testArrayByDedupingArrayManyDistinct {
  NSArray<GSCXScannerIssue *> *issues = @[
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId2"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId1"]
  ];
  NSArray<GSCXScannerIssue *> *expected = @[
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId1"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId2"]
  ];
  NSArray<GSCXScannerIssue *> *result = [GSCXScannerIssue arrayByDedupingArray:issues];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testArrayByDedupingArrayManyEqual {
  NSArray<GSCXScannerIssue *> *issues = @[
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId"]
  ];
  NSArray<GSCXScannerIssue *> *expected = @[ [self gscxtest_issueWithElementAddress:0
                                                                       elementClass:[UIView class]
                                                                frameInScreenBounds:CGRectZero
                                                                  accesibilityLabel:@"axLabel"
                                                            accessibilityIdentifier:@"axId"] ];
  NSArray<GSCXScannerIssue *> *result = [GSCXScannerIssue arrayByDedupingArray:issues];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testArrayByDedupingArrayManySomeEqualSomeDistinct {
  NSArray<GSCXScannerIssue *> *issues = @[
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId1"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId2"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId3"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId2"]
  ];
  NSArray<GSCXScannerIssue *> *expected = @[
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId1"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId2"],
    [self gscxtest_issueWithElementAddress:0
                              elementClass:[UIView class]
                       frameInScreenBounds:CGRectZero
                         accesibilityLabel:@"axLabel"
                   accessibilityIdentifier:@"axId3"]
  ];
  NSArray<GSCXScannerIssue *> *result = [GSCXScannerIssue arrayByDedupingArray:issues];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testArrayByDedupingArrayManyEqualDifferentNames {
  NSArray<GSCXScannerIssue *> *issues = @[
    [[GSCXScannerIssue alloc] initWithCheckNames:@[ kGSCXScannerIssueDummyCheckName1 ]
                               checkDescriptions:@[ kGSCXScannerIssueDummyCheckDescription1 ]
                                  elementAddress:0
                                    elementClass:[UIView class]
                             frameInScreenBounds:CGRectZero
                              accessibilityLabel:@"axLabel"
                         accessibilityIdentifier:@"axId"
                              elementDescription:@"Unknown"],
    [[GSCXScannerIssue alloc] initWithCheckNames:@[ kGSCXScannerIssueDummyCheckName2 ]
                               checkDescriptions:@[ kGSCXScannerIssueDummyCheckDescription2 ]
                                  elementAddress:0
                                    elementClass:[UIView class]
                             frameInScreenBounds:CGRectZero
                              accessibilityLabel:@"axLabel"
                         accessibilityIdentifier:@"axId"
                              elementDescription:@"Unknown"]
  ];
  NSArray<GSCXScannerIssue *> *expected = @[ [[GSCXScannerIssue alloc]
           initWithCheckNames:@[
             kGSCXScannerIssueDummyCheckName1, kGSCXScannerIssueDummyCheckName2
           ]
            checkDescriptions:@[
              kGSCXScannerIssueDummyCheckDescription1, kGSCXScannerIssueDummyCheckDescription2
            ]
               elementAddress:0
                 elementClass:[UIView class]
          frameInScreenBounds:CGRectZero
           accessibilityLabel:@"axLabel"
      accessibilityIdentifier:@"axId"
           elementDescription:@"Unknown"] ];
  NSArray<GSCXScannerIssue *> *result = [GSCXScannerIssue arrayByDedupingArray:issues];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

- (void)testArrayByDedupingArrayManyEqualOverlappingNames {
  NSArray<GSCXScannerIssue *> *issues = @[
    [[GSCXScannerIssue alloc] initWithCheckNames:@[ kGSCXScannerIssueDummyCheckName1 ]
                               checkDescriptions:@[ kGSCXScannerIssueDummyCheckDescription1 ]
                                  elementAddress:0
                                    elementClass:[UIView class]
                             frameInScreenBounds:CGRectZero
                              accessibilityLabel:@"axLabel"
                         accessibilityIdentifier:@"axId"
                              elementDescription:@"Unknown"],
    [[GSCXScannerIssue alloc]
             initWithCheckNames:@[
               kGSCXScannerIssueDummyCheckName1, kGSCXScannerIssueDummyCheckName2
             ]
              checkDescriptions:@[
                kGSCXScannerIssueDummyCheckDescription1, kGSCXScannerIssueDummyCheckDescription2
              ]
                 elementAddress:0
                   elementClass:[UIView class]
            frameInScreenBounds:CGRectZero
             accessibilityLabel:@"axLabel"
        accessibilityIdentifier:@"axId"
             elementDescription:@"Unknown"]
  ];
  NSArray<GSCXScannerIssue *> *expected = @[ [[GSCXScannerIssue alloc]
           initWithCheckNames:@[
             kGSCXScannerIssueDummyCheckName2, kGSCXScannerIssueDummyCheckName1
           ]
            checkDescriptions:@[
              kGSCXScannerIssueDummyCheckDescription2, kGSCXScannerIssueDummyCheckDescription1
            ]
               elementAddress:0
                 elementClass:[UIView class]
          frameInScreenBounds:CGRectZero
           accessibilityLabel:@"axLabel"
      accessibilityIdentifier:@"axId"
           elementDescription:@"Unknown"] ];
  NSArray<GSCXScannerIssue *> *result = [GSCXScannerIssue arrayByDedupingArray:issues];
  XCTAssert([GSCXScannerTestsUtils issues:result equalIssuesUnordered:expected]);
}

#pragma mark - Private

/**
 * Constructs a @c GSCXScannerIssue instance using dummy values for the check names and
 * descriptions.
 *
 * @param elementClass The class of the element associated with the issue.
 * @param frame The frame of the element associated with the issue in screen coordinates.
 * @param accessibilityLabel Optional. The accessibility label of the element associated with the
 * issue.
 * @param accessibilityIdentifier Optional. The accessibility identifier of the element associated
 * with the issue.
 * @return A @c GSCXScannerIssue instance initialized with dummy values for the check names and
 * check descriptions and the given parameters for all other values.
 */
- (GSCXScannerIssue *)gscxtest_issueWithElementAddress:(NSUInteger)elementAddress
                                          elementClass:(Class)elementClass
                                   frameInScreenBounds:(CGRect)frame
                                     accesibilityLabel:(nullable NSString *)accessibilityLabel
                               accessibilityIdentifier:
                                   (nullable NSString *)accessibilityIdentifier {
  return [GSCXScannerIssue issueWithCheckNames:@[ kGSCXScannerIssueDummyCheckName1 ]
                             checkDescriptions:@[ kGSCXScannerIssueDummyCheckDescription1 ]
                                elementAddress:elementAddress
                                  elementClass:elementClass
                           frameInScreenBounds:frame
                            accessibilityLabel:accessibilityLabel
                       accessibilityIdentifier:accessibilityIdentifier];
}

/**
 * Returns a copy of @c string guaranteed to be a unique instance.
 *
 * @note String interning could cause tests to pass when they shouldn't. For example, if a method
 * accidentally used @c == instead of @c isEqual: to compare strings, this should fail. But if the
 * strings are interned, it would pass. Creating a copy of a constant string just returns the same
 * string. A mutable copy is made first to force the memory to be copied.
 *
 * @param string A string to copy into a unique instance.
 * @return A unique copy of @c string.
 */
- (NSString *)gscxtest_uninternedString:(NSString *)string {
  return [[string mutableCopy] copy];
}

@end

NS_ASSUME_NONNULL_END
