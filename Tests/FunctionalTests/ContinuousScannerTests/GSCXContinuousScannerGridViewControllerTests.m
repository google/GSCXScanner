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

#import "GSCXContinuousScannerGridViewController.h"

#import <XCTest/XCTest.h>

#import "GSCXContinuousScannerScreenshotViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/ContinuousScannerTests/GSCXContinuousScannerTestCase.h"
#import "GSCXTestScannerViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXContinuousScannerGridViewControllerTests : GSCXContinuousScannerTestCase
@end

@implementation GSCXContinuousScannerGridViewControllerTests

- (void)testGridViewContainsMultipleCellsForMultipleScans {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils tapStartContinuousScanningButton];
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  XCTAssert([GSCXScannerTestUtils waitForContinuousScan]);
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertCarouselSelectedCellAtIndex:0];
  [GSCXScannerTestUtils assertRingViewCount:3];
  [GSCXScannerTestUtils tapGridButton];
  [GSCXScannerTestUtils tapGridCellAtIndex:1];
  [GSCXScannerTestUtils assertCarouselSelectedCellAtIndex:1];
  [GSCXScannerTestUtils assertRingViewCount:3];
  [GSCXScannerTestUtils tapGridButton];
  [GSCXScannerTestUtils tapGridCellAtIndex:0];
  [GSCXScannerTestUtils assertCarouselSelectedCellAtIndex:0];
  [GSCXScannerTestUtils assertRingViewCount:3];
}

@end

NS_ASSUME_NONNULL_END
