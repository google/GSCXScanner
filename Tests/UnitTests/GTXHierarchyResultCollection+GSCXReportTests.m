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

#import "GTXHierarchyResultCollection+GSCXReport.h"

#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTXHierarchyResultCollectionGSCXReportTests : XCTestCase
@end

@implementation GTXHierarchyResultCollectionGSCXReportTests

- (void)testGTXHierarchyResultCollectionCanProvideHTMLDescription {
  GTXCheckResult *checkResult1 = [[GTXCheckResult alloc] initWithCheckName:@"Check 1"
                                                          errorDescription:@"Error Description 1"];
  GTXCheckResult *checkResult2 = [[GTXCheckResult alloc] initWithCheckName:@"Check 2"
                                                          errorDescription:@"Error Description 2"];
  GTXElementReference *elementReference1 =
      [[GTXElementReference alloc] initWithElementAddress:0
                                             elementClass:[UIView class]
                                       accessibilityLabel:@"Label 1"
                                  accessibilityIdentifier:nil
                                       accessibilityFrame:CGRectMake(0, 0, 10, 10)
                                       elementDescription:@"Element 1"];
  GTXElementReference *elementReference2 =
      [[GTXElementReference alloc] initWithElementAddress:0
                                             elementClass:[UIView class]
                                       accessibilityLabel:@"Label 2"
                                  accessibilityIdentifier:nil
                                       accessibilityFrame:CGRectMake(10, 10, 20, 20)
                                       elementDescription:@"Element 2"];
  GTXElementResultCollection *elementResult1 =
      [[GTXElementResultCollection alloc] initWithElement:elementReference1
                                             checkResults:@[ checkResult1 ]];
  GTXElementResultCollection *elementResult2 =
      [[GTXElementResultCollection alloc] initWithElement:elementReference2
                                             checkResults:@[ checkResult2 ]];
  UIGraphicsBeginImageContext(CGSizeMake(1, 1));
  UIImage *dummyImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  GTXHierarchyResultCollection *result = [[GTXHierarchyResultCollection alloc]
      initWithElementResults:@[ elementResult1, elementResult2 ]
                  screenshot:dummyImage];
  NSString *resultHTML = [result htmlDescription:[[GSCXReportContext alloc] init]];

  NSInteger assertionCount = 0;
  for (GTXElementResultCollection *elementResult in result.elementResults) {
    for (GTXCheckResult *checkResult in elementResult.checkResults) {
      XCTAssertTrue([resultHTML containsString:checkResult.checkName]);
      assertionCount += 1;
    }
  }
  XCTAssertGreaterThanOrEqual(assertionCount, 1, @"At least one HTML must be checked.");
}

@end

NS_ASSUME_NONNULL_END
