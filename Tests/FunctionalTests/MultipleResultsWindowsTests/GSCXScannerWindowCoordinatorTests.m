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

#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/MultipleResultsWindowsTests/GSCXMultipleResultsWindowsTestCase.h"

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXScannerOverlayViewController.h"
#import "GSCXTestScannerViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSCXScannerWindowCoordinatorTests : GSCXMultipleResultsWindowsTestCase

@end

@implementation GSCXScannerWindowCoordinatorTests

- (void)testScannerCanBeInvokedWithOneNoIssuesScreen {
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils dismissNoIssuesAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testScannerCanBeInvokedWithMultipleNoIssuesScreens {
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils dismissNoIssuesAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils dismissNoIssuesAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testScannerCanBeInvokedWithOneScreenshotResultsScreen {
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils dismissScreenshotView];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testScannerCanBeInvokedWithOneScreenshotResultsAndOneNoIssuesScreen {
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [self _assertDismissScreenshotViewButtonIsInteractable:NO];
  [GSCXScannerTestUtils dismissNoIssuesAlert];
  [GSCXScannerTestUtils dismissScreenshotView];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testOverlayAppearsBelowSystemAlert {
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils presentMockSystemAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:NO];
  [GSCXScannerTestUtils dismissMockSystemAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testResultsWindowAppearsBelowSystemAlert {
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils openPage:[GSCXTestScannerViewController class]];
  [GSCXScannerTestUtils tapPerformScanButton];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils presentMockSystemAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:NO];
  [[EarlGrey selectElementWithMatcher:grey_text(kGSCXScannerOverlayDismissButtonText)]
      assertWithMatcher:grey_not(grey_interactable())];
  [GSCXScannerTestUtils dismissMockSystemAlert];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils dismissScreenshotView];
}

- (void)_assertDismissScreenshotViewButtonIsInteractable:(BOOL)isInteractable {
  // Normally, elements are not considered interactable underneath user presented alerts. However,
  // grey_interactable()'s behavior considers elements interactable unless they are completely
  // covered by an opaque element, so it would return YES even if an alert were presented over it.
  // When an alert is presented by the results window coordinator, the new window becomes the key
  // window, and the window with the dismiss button resigns the key window. Thus, whether or not
  // the dismiss button is a descendant of the key window is a proxy for whether it can be
  // interacted with or not.
  id<GREYMatcher> assertion = grey_ancestor(grey_keyWindow());
  if (!isInteractable) {
    assertion = grey_not(assertion);
  }
  [[EarlGrey selectElementWithMatcher:grey_text(kGSCXScannerOverlayDismissButtonText)]
      assertWithMatcher:assertion];
}

@end

NS_ASSUME_NONNULL_END
