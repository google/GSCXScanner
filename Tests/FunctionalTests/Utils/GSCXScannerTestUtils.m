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

#import "third_party/objective_c/GSCXScanner/Tests/FunctionalTests/Utils/GSCXScannerTestUtils.h"

#import "third_party/objective_c/EarlGreyV2/TestLib/EarlGreyImpl/EarlGrey.h"
#import "GSCXScanner.h"
#import "GSCXScannerOverlayViewController.h"
#import "GSCXScannerSettingsViewController.h"
#import "GSCXTestViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The title of the cancel button for the mock system alert.
 */
static NSString *const kGSCXScannerWindowCoordinatorTestsSystemAlertCancelTitle = @"Cancel";

/**
 * The name of the condition waiting for the no issues found alert to appear.
 */
static NSString *const kGSCXScannerNoIssuesAlertConditionName =
    @"kGSCXScannerNoIssuesAlertConditionName";

/**
 * The number of seconds tests should wait for the no issues found alert to appear before failing.
 */
static const NSTimeInterval kGSCXScannerNoIssuesAlertConditionTimeout = 5.0;

/**
 * The number of seconds between polls when waiting for the no issues found alert to appear.
 */
static const NSTimeInterval kGSCXScannerNoIssuesAlertConditionPollInterval = 0.5;

@implementation GSCXScannerTestUtils

+ (void)navigateToRootPage {
  UIWindow *delegateWindow =
      [GREY_REMOTE_CLASS_IN_APP(UIApplication) sharedApplication].delegate.window;
  UINavigationController *navController;
  if ([delegateWindow.rootViewController
          isKindOfClass:GREY_REMOTE_CLASS_IN_APP(UINavigationController)]) {
    navController = (UINavigationController *)delegateWindow.rootViewController;
  } else {
    navController = delegateWindow.rootViewController.navigationController;
  }
  [navController popToRootViewControllerAnimated:YES];
  [[GREYConfiguration sharedConfiguration] reset];
}

+ (void)openPage:(Class<GSCXTestPage>)pageClass {
  NSString *accessibilityId =
      [GSCXTestViewController accessibilityIdentifierOfCellForPage:pageClass];
  // Attempt to open the named view. The views are listed as a rows of a UITableView and tapping it
  // opens the view.
  NSError *error;
  id<GREYMatcher> cellMatcher = grey_accessibilityID(accessibilityId);
  [[EarlGrey selectElementWithMatcher:cellMatcher] performAction:grey_tap() error:&error];
  if (!error) {
    return;
  }
  // The view is probably not visible, scroll to top of the table view and go searching for it.
  [[EarlGrey selectElementWithMatcher:grey_kindOfClass([UITableView class])]
      performAction:grey_scrollToContentEdge(kGREYContentEdgeTop)];
  // Scroll to the cell we need and tap it.
  [[[EarlGrey selectElementWithMatcher:grey_allOf(cellMatcher, grey_interactable(), nil)]
         usingSearchAction:grey_scrollInDirection(kGREYDirectionDown, 200)
      onElementWithMatcher:grey_kindOfClass([UITableView class])] performAction:grey_tap()];
}

+ (void)tapSettingsButton {
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)dismissSettingsPage {
  [[EarlGrey
      selectElementWithMatcher:grey_accessibilityID(kGSCXDismissSettingsAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)tapPerformScanButton {
  [self tapSettingsButton];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(kGSCXPerformScanAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)toggleContinuousScanSwitch {
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXSettingsContinuousScanSwitchAccessibilityIdentifier)]
      performAction:grey_longPress()];
}

+ (void)tapReportButton {
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXSettingsReportButtonAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)dismissNoIssuesAlert {
  id<GREYMatcher> alertMatcher =
      grey_allOf(grey_text(kGSCXNoIssuesDismissButtonText), grey_interactable(), nil);
  GREYCondition *waitToDismissSettings = [GREYCondition
      conditionWithName:kGSCXScannerNoIssuesAlertConditionName
                  block:^BOOL {
                    id<GREYMatcher> assertion =
                        [GSCXScannerTestUtils gscxtest_matcherForInteractable:YES];
                    NSError *error;
                    [[EarlGrey selectElementWithMatcher:alertMatcher] assertWithMatcher:assertion
                                                                                  error:&error];
                    return error == nil;
                  }];
  BOOL hasAlertAppeared =
      [waitToDismissSettings waitWithTimeout:kGSCXScannerNoIssuesAlertConditionTimeout
                                pollInterval:kGSCXScannerNoIssuesAlertConditionPollInterval];
  // Usually, XCTAssert(hasAlertAppeared) would be used, but XCTAssert cannot be used in a
  // non-XCTestCase subclass. If it did not appear, trying to tap it will fail the test anyways.
  // Assigning it to NO silences the unused return value warning.
  hasAlertAppeared = NO;
  [[EarlGrey selectElementWithMatcher:alertMatcher] performAction:grey_tap()];
}

+ (void)dismissScreenshotView {
  [[EarlGrey selectElementWithMatcher:grey_allOf(grey_text(kGSCXScannerOverlayDismissButtonText),
                                                 grey_interactable(), nil)]
      performAction:grey_tap()];
}

+ (void)dismissContinuousScanReport {
  [GSCXScannerTestUtils dismissScreenshotView];
}

+ (void)presentMockSystemAlert {
  CGRect bounds = [[GREY_REMOTE_CLASS_IN_APP(UIScreen) mainScreen] bounds];
  UIWindow *window = [[GREY_REMOTE_CLASS_IN_APP(UIWindow) alloc] initWithFrame:bounds];
  window.rootViewController = [[GREY_REMOTE_CLASS_IN_APP(UIViewController) alloc] init];
  // The window's background color must be fully opaque, or else tapping the perform scan button
  // succeeds even if the alert is displayed. Normally, only views with alpha < 0.1 forward touch
  // events, but the way EarlGrey selects and performs actions is not consistent with this. EarlGrey
  // allows the button to be tapped anyways. Setting the background color to black fixes this. This
  // is not aesthetically identical to system alerts, but it does have identical behavior.
  window.rootViewController.view.backgroundColor = [UIColor blackColor];
  UIAlertController *alert = [GREY_REMOTE_CLASS_IN_APP(UIAlertController)
      alertControllerWithTitle:@"Alert"
                       message:@"Alert message."
                preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[GREY_REMOTE_CLASS_IN_APP(UIAlertAction)
                       actionWithTitle:kGSCXScannerWindowCoordinatorTestsSystemAlertCancelTitle
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action) {
                                 window.hidden = YES;
                                 [window resignKeyWindow];
                               }]];
  window.windowLevel = UIWindowLevelAlert;
  [window makeKeyAndVisible];
  [window.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (void)dismissMockSystemAlert {
  [[EarlGrey
      selectElementWithMatcher:grey_text(kGSCXScannerWindowCoordinatorTestsSystemAlertCancelTitle)]
      performAction:grey_tap()];
}

+ (void)assertSettingsButtonIsInteractable:(BOOL)interactable {
  id<GREYMatcher> assertion = [GSCXScannerTestUtils gscxtest_matcherForInteractable:interactable];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier)]
      assertWithMatcher:assertion];
}

+ (void)assertSettingsButtonIsInteractable:(BOOL)interactable
                                     error:(NSError *__autoreleasing *)error {
  id<GREYMatcher> assertion = [GSCXScannerTestUtils gscxtest_matcherForInteractable:interactable];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXScannerOverlaySettingsButtonAccessibilityIdentifier)]
      assertWithMatcher:assertion
                  error:error];
}

+ (void)assertPerformScanButtonIsInteractable:(BOOL)interactable {
  id<GREYMatcher> assertion = [GSCXScannerTestUtils gscxtest_matcherForInteractable:interactable];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(kGSCXPerformScanAccessibilityIdentifier)]
      assertWithMatcher:assertion];
}

+ (void)assertContinuousScanSwitchIsInteractable:(BOOL)interactable {
  // UISwitch elements have interactable UIView subviews. This causes
  // gscxtest_matcherForInteractable to match the wrong element. Using grey_interactable matches the
  // switch itself.
  id<GREYMatcher> assertion = interactable ? grey_interactable() : grey_not(grey_interactable());
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXSettingsContinuousScanSwitchAccessibilityIdentifier)]
      assertWithMatcher:assertion];
}

+ (void)assertContinuousScanSwitchIsOn:(BOOL)isOn {
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXSettingsContinuousScanSwitchAccessibilityIdentifier)]
      assertWithMatcher:grey_switchWithOnState(isOn)];
}

+ (BOOL)noIssuesFoundItemExists {
  NSError *error = nil;
  [[EarlGrey selectElementWithMatcher:grey_text(kGSCXSettingsNoIssuesFoundText)]
      assertWithMatcher:grey_interactable()
                  error:&error];
  return ![GSCXScannerTestUtils gscxtest_isElementNotFoundError:error];
}

+ (BOOL)reportButtonItemExists {
  NSError *error = nil;
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXSettingsReportButtonAccessibilityIdentifier)]
      assertWithMatcher:grey_interactable()
                  error:&error];
  return ![GSCXScannerTestUtils gscxtest_isElementNotFoundError:error];
}

#pragma mark - Private

/**
 * Returns a @c GREYMatcher instance matching interactable elements if @c interactable is @c YES and
 * non-interactable elements otherwise.
 *
 * @param interactable @c YES if the matcher should match interactable elements, @c NO otherwise.
 * @return A @c GREYMatcher instance matching interactable or non-interactable elements, depending
 * on @c interactable.
 */
+ (id<GREYMatcher>)gscxtest_matcherForInteractable:(BOOL)interactable {
  id<GREYMatcher> interactableHitTestMatcher = [GREYElementMatcherBlock
      matcherWithMatchesBlock:^BOOL(id element) {
        if (![element respondsToSelector:@selector(accessibilityActivationPoint)]) {
          return NO;
        }
        CGPoint activationPoint = [element accessibilityActivationPoint];
        NSArray<UIWindow *> *windows =
            [[GREY_REMOTE_CLASS_IN_APP(UIApplication) sharedApplication] windows];
        // Iterate backwards because the windows are ordered front-to-back. Check the topmost window
        // first, then the second topmost, etc.
        for (NSInteger i = [windows count] - 1; i >= 0; i--) {
          UIView *hitElement = [windows[i] hitTest:activationPoint withEvent:nil];
          if (hitElement != nil) {
            return hitElement == element;
          }
        }
        return NO;
      }
      descriptionBlock:^(id<GREYDescription> description) {
        [description appendText:@"interactable via hitTest:withEvent:"];
      }];
  return (interactable) ? interactableHitTestMatcher : grey_not(interactableHitTestMatcher);
}

/**
 * Determines if an error represents an Earl Grey element not found error.
 *
 * @param error An @c NSError instance. May be @c nil.
 * @return @c YES if the error is not @c nil and represents an Earl Grey element not found error, @c
 * NO otherwise.
 */
+ (BOOL)gscxtest_isElementNotFoundError:(nullable NSError *)error {
  return error && [error.domain isEqualToString:kGREYInteractionErrorDomain] &&
         error.code == kGREYInteractionElementNotFoundErrorCode;
}

@end

NS_ASSUME_NONNULL_END
