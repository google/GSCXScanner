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

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXScannerSettingsViewController.h"
#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

@interface GSCXScannerSettingsViewControllerTests : GSCXScannerTestCase

@end

@implementation GSCXScannerSettingsViewControllerTests

- (void)testTappingSettingsButtonPresentsSettingsPage {
  [GSCXScannerTestUtils assertPerformScanButtonIsInteractable:NO];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
  [GSCXScannerTestUtils tapSettingsButton];
  [GSCXScannerTestUtils assertPerformScanButtonIsInteractable:YES];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:NO];
  [GSCXScannerTestUtils dismissSettingsPage];
  [GSCXScannerTestUtils assertPerformScanButtonIsInteractable:NO];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testTappingSettingsInsideBackgroundDismissesSettings {
  [GSCXScannerTestUtils tapSettingsButton];
  // Tapping somewhere in the middle of the table view risks accidentally tapping on a subview.
  // If that happens, that element would receive the touch instead of the background, which would
  // not trigger dismissal.
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXScannerSettingsTableAccessibilityIdentifier)]
      performAction:grey_tapAtPoint(CGPointZero)];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

- (void)testTappingSettingsOutsideBackgroundDismissesSettings {
  [GSCXScannerTestUtils tapSettingsButton];
  [[EarlGrey selectElementWithMatcher:grey_keyWindow()] performAction:grey_tapAtPoint(CGPointZero)];
  [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES];
}

@end
