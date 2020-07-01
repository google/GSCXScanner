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
#import "GSCXContinuousScannerGridViewController.h"
#import "GSCXContinuousScannerListViewController.h"
#import "GSCXContinuousScannerScreenshotViewController.h"
#import "GSCXRingViewArranger.h"
#import "GSCXScanner.h"
#import "GSCXScannerIssueExpandableTableViewDelegate.h"
#import "GSCXScannerOverlayViewController.h"
#import "GSCXScannerScreenshotViewController.h"
#import "GSCXScannerSettingsViewController.h"
#import "GSCXTestAppDelegate.h"
#import "GSCXTestSharingDelegate.h"
#import "GSCXTestViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The percentage of the screen's height to scroll in a single scroll action.
 */
static const CGFloat kGSCXScannerTestUtilsScreenHeightScrollFactor = 0.5;

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

/**
 * The number of seconds between scheduled scans. This must be greater than the default because the
 * default does not allow enough time for some tests to pass. Depending on the animation
 * synchronization, a scan may or may not occur in between certain actions. This causes flakiness.
 * Increasing the time interval between scans solves this.
 */
static const NSTimeInterval kGSCXContinuousScannerTestsTimeInterval = 4.0;

/**
 * The number of seconds to wait between polls when waiting on a condition. This prevents the main
 * thread from slowing due to repeated polls.
 */
static const NSTimeInterval kGSCXContinuousScannerTestsPollInterval = 0.5;

/**
 * The name of the @c GREYCondition instance waiting for the settings page to be dismissed.
 */
static NSString *const kGSCXContinuousScannerDismissSettingsConditionName = @"dismiss settings";

@interface GSCXScannerIssueExpandableTableViewDelegate (ExposedForTesting)

+ (NSString *)gscx_accessibilityIdentifierForHeaderInSection:(NSInteger)section;

+ (NSString *)gscx_accessibilityIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GSCXScannerResultCarousel (ExposedForTesting)

+ (NSString *)gscx_accessibilityValueAtSelectedIndex:(NSUInteger)index;

@end

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
  [[GSCXScannerTestUtils scrollElementWithMatcher:grey_kindOfClass([UITableView class])
                             toElementWithMatcher:grey_accessibilityID(accessibilityId)]
      performAction:grey_tap()];
}

+ (GREYElementInteraction *)scrollElementWithMatcher:(id<GREYMatcher>)scrollMatcher
                                toElementWithMatcher:(id<GREYMatcher>)elementMatcher {
  // Matches scrollable elements whose content size is greater than its frame in at least one
  // dimension. If not, the element cannot scroll, because all of its content is already visible.
  // In this case, there's no reason to trigger a scroll interaction, and elementMatcher can be
  // matched directly.
  id<GREYMatcher> canScrollMatcher = [GREYElementMatcherBlock
      matcherWithMatchesBlock:^BOOL(id element) {
        if (![element respondsToSelector:@selector(bounds)] ||
            ![element respondsToSelector:@selector(contentSize)]) {
          return NO;
        }
        CGRect bounds = [element bounds];
        CGSize contentSize = [element contentSize];
        if ([element respondsToSelector:@selector(contentInset)]) {
          bounds = UIEdgeInsetsInsetRect(bounds, [element contentInset]);
        }
        return CGRectGetWidth(bounds) < contentSize.width ||
               CGRectGetWidth(bounds) < contentSize.height;
      }
      descriptionBlock:^(id<GREYDescription> description) {
        [description appendText:@"Content size is not greater than frame."];
      }];
  NSError *scrollError = nil;
  [[EarlGrey selectElementWithMatcher:scrollMatcher] assertWithMatcher:canScrollMatcher
                                                                 error:&scrollError];
  if (scrollError != nil) {
    return [EarlGrey selectElementWithMatcher:elementMatcher];
  }
  NSError *error = nil;
  [[EarlGrey selectElementWithMatcher:elementMatcher] assertWithMatcher:elementMatcher
                                                                  error:&error];
  if (error == nil) {
    // The element could be found without scrolling, no need to continue.
    return [EarlGrey selectElementWithMatcher:elementMatcher];
  }
  // The view is probably not visible, scroll to bottom of the table view and go searching for it.
  // Start at the bottom instead of the top because tests often assert on items sequentially in
  // navigation order. If this went top to bottom, the next item would always be barely off screen,
  // causing the tests to have to scroll all the way to the top and all the way down to the desired
  // element each search. If the desired element is beneath the previous element, it's more likely
  // to be found quickly by the search, and it's more likely the next element will already be on
  // screen. This isn't faster in all cases, but it's a good hueristic.
  //
  // Scroll a percentage of the screen to scale scroll amount with screen size without skipping
  // portions of the scroll view contents.
  CGFloat scrollAmount =
      [[UIScreen mainScreen] bounds].size.height * kGSCXScannerTestUtilsScreenHeightScrollFactor;
  [[EarlGrey selectElementWithMatcher:scrollMatcher]
      performAction:grey_scrollToContentEdge(kGREYContentEdgeBottom)];
  return [[EarlGrey selectElementWithMatcher:elementMatcher]
         usingSearchAction:grey_scrollInDirection(kGREYDirectionUp, scrollAmount)
      onElementWithMatcher:scrollMatcher];
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

+ (void)tapStartContinuousScanningButton {
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXSettingsContinuousScanButtonAccessibilityIdentifier)]
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

+ (void)tapNavButtonWithAccessibilityLabel:(NSString *)accessibilityLabel {
  id<GREYMatcher> matcher = grey_allOf(
      grey_ancestor(grey_keyWindow()), grey_ancestor(grey_kindOfClass([UINavigationBar class])),
      grey_ancestor(grey_accessibilityTrait(UIAccessibilityTraitButton)),
      grey_text(accessibilityLabel), nil);
  [[EarlGrey selectElementWithMatcher:matcher] performAction:grey_tap()];
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

+ (void)tapShareReportButton {
  [[EarlGrey
      selectElementWithMatcher:grey_accessibilityID(kGSCXShareReportButtonAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)tapCancelMockShareReportButton {
  [[EarlGrey selectElementWithMatcher:grey_text(kGSCXTestSharingDelegateAlertDismissTitle)]
      performAction:grey_tap()];
}

+ (void)tapGridButton {
  id<GREYMatcher> gridButtonMatcher =
      grey_accessibilityID(kGSCXContinuousScannerScreenshotGridButtonAccessibilityIdentifier);
  [[EarlGrey selectElementWithMatcher:gridButtonMatcher] performAction:grey_tap()];
}

+ (void)tapGridCellAtIndex:(NSUInteger)index {
  NSString *cellAXId =
      [GSCXContinuousScannerGridViewController accessibilityIdentifierForCellAtIndex:index];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(cellAXId)] performAction:grey_tap()];
}

+ (void)tapListButton {
  [[EarlGrey selectElementWithMatcher:
                 grey_accessibilityID(
                     kGSCXContinuousScannerScreenshotListBarButtonAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)tapNextContinuousScanResultButton {
  [[EarlGrey
      selectElementWithMatcher:
          grey_accessibilityID(kGSCXContinuousScannerScreenshotNextButtonAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)tapBackContinuousScanResultButton {
  [[EarlGrey
      selectElementWithMatcher:
          grey_accessibilityID(kGSCXContinuousScannerScreenshotBackButtonAccessibilityIdentifier)]
      performAction:grey_tap()];
}

+ (void)toggleListSectionAtIndex:(NSInteger)sectionIndex {
  id<GREYMatcher> scrollMatcher =
      grey_accessibilityID(kGSCXContinuousScannerListTableViewAccessibilityIdentifier);
  NSString *accessibilityID = [GSCXScannerIssueExpandableTableViewDelegate
      gscx_accessibilityIdentifierForHeaderInSection:sectionIndex];
  id<GREYMatcher> headerMatcher = grey_accessibilityID(accessibilityID);
  [[GSCXScannerTestUtils
      scrollElementWithMatcher:scrollMatcher
          toElementWithMatcher:grey_allOf(headerMatcher, grey_sufficientlyVisible(), nil)]
      performAction:grey_tap()];
}

+ (void)assertListSectionAtIndex:(NSInteger)sectionIndex
              accessibilityTrait:(UIAccessibilityTraits)accessibilityTrait
                          exists:(BOOL)exists {
  NSString *headerAccessibilityId = [GSCXScannerIssueExpandableTableViewDelegate
      gscx_accessibilityIdentifierForHeaderInSection:sectionIndex];
  id<GREYMatcher> traitMatcher = grey_accessibilityTrait(accessibilityTrait);
  if (!exists) {
    traitMatcher = grey_not(traitMatcher);
  }
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(headerAccessibilityId)]
      assertWithMatcher:traitMatcher];
}

+ (void)tapTabBarButtonWithTitle:(NSString *)title {
  Class tabBarButtonClass =
      NSClassFromString([GSCXScannerTestUtils gscxtest_UITabBarButtonClassName]);
  id<GREYMatcher> ancestorMatcher = grey_ancestor(grey_kindOfClass(tabBarButtonClass));
  id<GREYMatcher> titleMatcher = grey_text(title);
  [[EarlGrey selectElementWithMatcher:grey_allOf(ancestorMatcher, titleMatcher, nil)]
      performAction:grey_tap()];
}

+ (GREYElementInteraction *)selectRingViewAtIndex:(NSInteger)index {
  NSString *ringViewAXId = [GSCXRingViewArranger accessibilityIdentifierForRingViewAtIndex:index];
  return [EarlGrey selectElementWithMatcher:grey_accessibilityID(ringViewAXId)];
}

+ (void)assertCarouselSelectedCellAtIndex:(NSInteger)index {
  NSString *value = [GSCXScannerResultCarousel gscx_accessibilityValueAtSelectedIndex:index];
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXScannerResultCarouselAccessibilityIdentifier)]
      assertWithMatcher:grey_accessibilityValue(value)];
}

+ (void)assertRingViewCount:(NSInteger)count {
  for (NSInteger i = 0; i < count; i++) {
    [[GSCXScannerTestUtils selectRingViewAtIndex:i] assertWithMatcher:grey_notNil()];
  }
  [[GSCXScannerTestUtils selectRingViewAtIndex:count] assertWithMatcher:grey_nil()];
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

+ (void)assertContinuousScanButtonIsInteractable:(BOOL)interactable {
  // UISwitch elements have interactable UIView subviews. This causes
  // gscxtest_matcherForInteractable to match the wrong element. Using grey_interactable matches the
  // switch itself.
  id<GREYMatcher> assertion = interactable ? grey_interactable() : grey_not(grey_interactable());
  [[EarlGrey selectElementWithMatcher:grey_accessibilityID(
                                          kGSCXSettingsContinuousScanButtonAccessibilityIdentifier)]
      assertWithMatcher:assertion];
}

+ (void)assertLabelForCheckNamed:(NSString *)checkName
           isSufficientlyVisible:(BOOL)isSufficientlyVisible {
  id<GREYMatcher> isVisibleMatcher =
      isSufficientlyVisible ? grey_sufficientlyVisible() : grey_not(grey_sufficientlyVisible());
  id<GREYMatcher> isHiddenMatcher =
      [GSCXScannerTestUtils gscxtest_elementOrAncestorIsHiddenMatcher];
  // In some cases, such as expanding and collapsing sections in the list view, labels are not
  // actually removed from the view hierarchy. The label or an ancestor is made hidden. This causes
  // an ambiguous selection error, because multiple labels with the same text exist in the view
  // hierarchy, even though users can only access one. Ignoring elements that are hidden solves
  // this.
  id<GREYMatcher> labelMatcher = grey_allOf(grey_text(checkName), grey_not(isHiddenMatcher), nil);
  [[EarlGrey selectElementWithMatcher:labelMatcher] assertWithMatcher:isVisibleMatcher];
}

+ (void)assertLabelForCheckNamed:(NSString *)checkName
           isSufficientlyVisible:(BOOL)isSufficientlyVisible
     scrollingElementWithMatcher:(id<GREYMatcher>)scrollMatcher {
  id<GREYMatcher> isVisibleMatcher =
      isSufficientlyVisible ? grey_sufficientlyVisible() : grey_not(grey_sufficientlyVisible());
  id<GREYMatcher> isHiddenMatcher =
      [GSCXScannerTestUtils gscxtest_elementOrAncestorIsHiddenMatcher];
  id<GREYMatcher> labelMatcher =
      grey_allOf(grey_text(checkName), grey_not(isHiddenMatcher), grey_sufficientlyVisible(), nil);
  [[GSCXScannerTestUtils scrollElementWithMatcher:scrollMatcher
                             toElementWithMatcher:labelMatcher] assertWithMatcher:isVisibleMatcher];
}

+ (void)assertListSectionCount:(NSInteger)sectionCount {
  id<GREYMatcher> scrollMatcher =
      grey_accessibilityID(kGSCXContinuousScannerListTableViewAccessibilityIdentifier);
  for (NSInteger section = 0; section < sectionCount; section++) {
    NSString *currentAccessibilityID = [GSCXScannerIssueExpandableTableViewDelegate
        gscx_accessibilityIdentifierForHeaderInSection:section];
    [[GSCXScannerTestUtils scrollElementWithMatcher:scrollMatcher
                               toElementWithMatcher:grey_accessibilityID(currentAccessibilityID)]
        assertWithMatcher:grey_notNil()];
  }
  NSString *finalAccessibilityID = [GSCXScannerIssueExpandableTableViewDelegate
      gscx_accessibilityIdentifierForHeaderInSection:sectionCount];
  [[GSCXScannerTestUtils scrollElementWithMatcher:scrollMatcher
                             toElementWithMatcher:grey_accessibilityID(finalAccessibilityID)]
      assertWithMatcher:grey_nil()];
}

+ (void)assertListRowCount:(NSInteger)rowCount inSection:(NSInteger)section {
  for (NSInteger row = 0; row < rowCount; row++) {
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    [GSCXScannerTestUtils gscxtest_assertListRowAtIndexPath:currentIndexPath exists:YES];
  }
  NSIndexPath *finalIndexPath = [NSIndexPath indexPathForRow:rowCount inSection:section];
  [GSCXScannerTestUtils gscxtest_assertListRowAtIndexPath:finalIndexPath exists:NO];
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

+ (BOOL)waitForContinuousScan {
  GREYCondition *waitToDismissSettings = [GREYCondition
      conditionWithName:kGSCXContinuousScannerDismissSettingsConditionName
                  block:^BOOL {
                    NSError *error;
                    [GSCXScannerTestUtils assertSettingsButtonIsInteractable:YES error:&error];
                    return error == nil;
                  }];
  BOOL wasSettingsDismissed =
      [waitToDismissSettings waitWithTimeout:kGSCXContinuousScannerTestsTimeInterval
                                pollInterval:kGSCXContinuousScannerTestsPollInterval];
  if (wasSettingsDismissed) {
    [(GSCXTestAppDelegate *)[[GREY_REMOTE_CLASS_IN_APP(UIApplication) sharedApplication] delegate]
        triggerScheduleScanEvent];
  }
  return wasSettingsDismissed;
}

+ (id<GREYMatcher>)isHiddenMatcher {
  return [GREYElementMatcherBlock
      matcherWithMatchesBlock:^BOOL(id element) {
        return [element respondsToSelector:@selector(isHidden)] && [element isHidden];
      }
      descriptionBlock:^(id<GREYDescription> description) {
        [description appendText:@"isHidden is NO, expected YES"];
      }];
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

/**
 * Asserts that the row in the list view at @c indexPath exists or does not exist. Fails the test if
 * @c exists is @c YES but the row does not exist or @c exists is @c NO but the row does exist.
 *
 * @param indexPath The index path of the row to check if it exists.
 * @param exists @c YES to assert the row exists, @c NO to assert the row does not exist.
 */
+ (void)gscxtest_assertListRowAtIndexPath:(NSIndexPath *)indexPath exists:(BOOL)exists {
  NSString *accessibilityID = [GSCXScannerIssueExpandableTableViewDelegate
      gscx_accessibilityIdentifierForRowAtIndexPath:indexPath];
  // Sometimes, when toggling the section, the rows are not removed from the view hierarchy, but
  // merely made hidden. That should still count as not existing, because as far
  // as the user is concerned, they aren't there. This needs to be included in elementMatcher
  // to avoid disambiguation errors, since sometimes a hidden cell will still be in the view
  // hierarchy alongside an identical non-hidden cell. It needs to be in the assertion matcher
  // because scrollElementWithMatcher returns an interaction instance that doesn't do anything
  // until an assertion is performed.
  id<GREYMatcher> isHiddenMatcher =
      [GSCXScannerTestUtils gscxtest_elementOrAncestorIsHiddenMatcher];
  id<GREYMatcher> disambiguationMatcher = exists ? grey_notNil() : grey_nil();
  id<GREYMatcher> elementMatcher = grey_allOf(
      grey_accessibilityID(accessibilityID), grey_not(isHiddenMatcher), disambiguationMatcher, nil);
  id<GREYMatcher> scrollMatcher =
      grey_accessibilityID(kGSCXContinuousScannerListTableViewAccessibilityIdentifier);
  [[GSCXScannerTestUtils scrollElementWithMatcher:scrollMatcher toElementWithMatcher:elementMatcher]
      assertWithMatcher:disambiguationMatcher];
}

/**
 * @return A matcher for elements whose @c isHidden value or the @c isHidden value of one of their
 * ancestors is @c YES.
 */
+ (id<GREYMatcher>)gscxtest_elementOrAncestorIsHiddenMatcher {
  id<GREYMatcher> isHiddenMatcher = [GSCXScannerTestUtils isHiddenMatcher];
  return grey_anyOf(isHiddenMatcher, grey_ancestor(isHiddenMatcher), nil);
}

/**
 * @return The name of the class of the button that toggles which view controller is visible in a
 * tab bar controller for the current iOS version. This is a private class, so it must be referred
 * to by @c NSClassFromString.
 */
+ (NSString *)gscxtest_UITabBarButtonClassName {
  return @"UITabBarButton";
}

@end

NS_ASSUME_NONNULL_END
