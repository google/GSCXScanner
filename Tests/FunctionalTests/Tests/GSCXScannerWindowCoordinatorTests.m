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

#import "GSCXScannerTestCase.h"

#import <XCTest/XCTest.h>

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXScannerOverlayViewController.h"
#import "GSCXTestAppDelegate.h"
#import "GSCXTestScannerViewController.h"
#import "GSCXTestViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerWindowCoordinatorTests : GSCXScannerTestCase
@end

@implementation GSCXScannerWindowCoordinatorTests

- (void)testSystemAlertBlocksInteractionOverlay {
  [GSCXScannerTestUtils presentMockSystemAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:NO];
  [GSCXScannerTestUtils dismissMockSystemAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testSystemAlertBlocksInteractionResultsWindow {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils presentMockSystemAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:NO];
  [[EarlGrey selectElementWithMatcher:grey_text(kGSCXScannerOverlayDismissButtonText)]
      assertWithMatcher:grey_not(grey_interactable())];
  [GSCXScannerTestUtils dismissMockSystemAlert];
  [GSCXScannerTestUtils dismissScreenshotView];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testResultsWindowAppearsOverOverlay {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:NO];
  [GSCXScannerTestUtils dismissScreenshotView];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

@end

NS_ASSUME_NONNULL_END
