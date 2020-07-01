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

#import "GSCXContinuousScannerScreenshotViewController.h"

#import "GSCXContinuousScannerGalleryViewController.h"
#import "GSCXContinuousScannerGridViewController.h"
#import "GSCXContinuousScannerListTabBarItem.h"
#import "GSCXContinuousScannerListTabBarUtils.h"
#import "GSCXContinuousScannerListTabBarViewController.h"
#import "GSCXContinuousScannerListViewController.h"
#import "GSCXContinuousScannerResultViewController.h"
#import "GSCXImageNames.h"
#import "GSCXRingViewArranger.h"
#import "GSCXScannerResultCarousel.h"
#import "GSCXScannerScreenshotViewController.h"
#import "GSCXUtils.h"
#import "NSLayoutConstraint+GSCXUtilities.h"
#import "UIViewController+GSCXAppearance.h"
#import <GTXiLib/GTXiLib.h>
NS_ASSUME_NONNULL_BEGIN

NSString *const kGSCXScannerResultCarouselAccessibilityIdentifier =
    @"kGSCXScannerResultCarouselAccessibilityIdentifier";

NSString *const kGSCXContinuousScannerScreenshotGridButtonAccessibilityIdentifier =
    @"kGSCXContinuousScannerScreenshotGridButtonAccessibilityIdentifier";

NSString *const kGSCXContinuousScannerScreenshotNextButtonAccessibilityIdentifier =
    @"kGSCXContinuousScannerScreenshotNextButtonAccessibilityIdentifier";

NSString *const kGSCXContinuousScannerScreenshotBackButtonAccessibilityIdentifier =
    @"kGSCXContinuousScannerScreenshotBackButtonAccessibilityIdentifier";

NSString *const kGSCXContinuousScannerScreenshotListBarButtonAccessibilityIdentifier =
    @"kGSCXContinuousScannerScreenshotListBarButtonAccessibilityIdentifier";

NSString *const kGSCXContinuousScannerScreenshotListByScanTabBarItemTitle = @"By Scan";

NSString *const kGSCXContinuousScannerScreenshotListByCheckTabBarItemTitle = @"By Check";

/**
 * The padding between the edges of the screen and elements in
 * @c GSCXContinuousScannerScreenshotViewController.
 */
static const CGFloat kGSCXContinuousScannerScreenshotPadding = 8.0;

/**
 * The height of the carousel view. Without an explicit height for the carousel, autolayout may try
 * to expand it instead of letting the screenshot be full screen. 100 is an arbitrary value big
 * enough to make the cells easily interactable.
 */
static const CGFloat kGSCXContinuousScannerScreenshotCarouselHeight = 100.0;

/**
 * The minimum height of @c scanNumberLabel and @c issueCountLabel. Sometimes, in landscape mode,
 * autolayout sets the height of these labels to 0, despite their intrinsic content size. A height
 * greater than or equal to this value solves this.
 */
static const CGFloat kGSCXContinuousScannerScreenshotMinimumLabelHeight = 20.5;

@interface GSCXContinuousScannerScreenshotViewController () <UIScrollViewDelegate>

/**
 * The results of all scans.
 */
@property(strong, nonatomic) NSArray<GSCXScannerResult *> *scannerResults;

/**
 * Delegate for configuring the sharing process.
 */
@property(strong, nonatomic) id<GSCXSharingDelegate> sharingDelegate;

/**
 * Displays screenshots of all scans. Users may scroll through and tap on scans to change the
 * displayed scan.
 */
@property(strong, nonatomic) GSCXScannerResultCarousel *carousel;

/**
 * The index of the currently selected scan result.
 */
@property(assign, nonatomic) NSUInteger currentIndex;

/**
 * A screenshot of the currently displayed scan.
 */
@property(strong, nonatomic) UIImageView *currentScreenshot;

/**
 * The aspect ratio constraint for @c currentScreenshot. @c nil until a screenshot has been
 * presented.
 */
@property(strong, nonatomic, nullable) NSLayoutConstraint *currentAspectRatioConstraint;

/**
 * Rings highlighting which views have accessibility issues.
 */
@property(strong, nonatomic) GSCXRingViewArranger *ringViews;

/**
 * Container for the carousel view so Autolayout constraints can be added in the storyboard.
 */
@property(weak, nonatomic) IBOutlet UIView *carouselContainerView;

/**
 * Displays the current scan result's screenshot. Allows zooming and panning.
 */
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

/**
 * The button that displays the previous scan result.
 */
@property(weak, nonatomic) IBOutlet UIButton *backButton;

/**
 * The button that displays the next scan result.
 */
@property(weak, nonatomic) IBOutlet UIButton *nextButton;

/**
 * The stack view that contains the back button, next button, and the screenshot of the current
 * scan.
 */
@property(weak, nonatomic) IBOutlet UIStackView *screenshotStackView;

/**
 * Presents the grid view.
 */
@property(weak, nonatomic) IBOutlet UIButton *gridButton;

/**
 * Displays the index of the currently displayed scan.
 */
@property(weak, nonatomic) IBOutlet UILabel *scanNumberLabel;

/**
 * Displays the number of issues in the currently displayed scan.
 */
@property(weak, nonatomic) IBOutlet UILabel *issueCountLabel;

@end

@implementation GSCXContinuousScannerScreenshotViewController

- (instancetype)initWithScannerResults:(NSArray<GSCXScannerResult *> *)scannerResults
                       sharingDelegate:(id<GSCXSharingDelegate>)sharingDelegate {
  NSString *nibName = @"GSCXContinuousScannerScreenshotViewController";
  NSBundle *bundle =
      [NSBundle bundleForClass:[GSCXContinuousScannerScreenshotViewController class]];
  self = [super initWithNibName:nibName bundle:bundle];
  if (self) {
    GTX_ASSERT([scannerResults count] > 0, @"scannerResults must not be empty.");
    _scannerResults = scannerResults;
    _sharingDelegate = sharingDelegate;
    __weak __typeof__(self) weakSelf = self;
    _carousel = [[GSCXScannerResultCarousel alloc]
        initWithResults:scannerResults
         selectionBlock:^(NSUInteger index, GSCXScannerResult *result) {
           [weakSelf gscx_displayScannerResultAtIndex:index];
         }];
    _carousel.carouselAccessibilityElement.accessibilityIdentifier =
        kGSCXScannerResultCarouselAccessibilityIdentifier;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.automaticallyAdjustsScrollViewInsets = NO;
  self.view.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  [self gscx_setupRightBarButtonItems];
  self.carousel.carouselView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  self.scrollView.delegate = self;
  self.scrollView.minimumZoomScale = 1.0 / kGSCXContinuousScannerGalleryZoomScale;
  self.scrollView.maximumZoomScale = kGSCXContinuousScannerGalleryZoomScale;
  self.currentScreenshot = [[UIImageView alloc] init];
  self.currentScreenshot.translatesAutoresizingMaskIntoConstraints = NO;
  self.currentScreenshot.userInteractionEnabled = YES;
  [self.scrollView addSubview:self.currentScreenshot];
  [self gscx_displayScannerResultAtIndex:0];
  [self.carouselContainerView addSubview:self.carousel.carouselView];
  [NSLayoutConstraint gscx_constraintsToFillSuperviewWithView:self.carousel.carouselView
                                                    activated:YES];
  self.scanNumberLabel.textColor = [self gscx_textColorForCurrentAppearance];
  self.scanNumberLabel.adjustsFontSizeToFitWidth = YES;
  self.issueCountLabel.textColor = [self gscx_textColorForCurrentAppearance];
  self.issueCountLabel.adjustsFontSizeToFitWidth = YES;
  self.issueCountLabel.textAlignment = NSTextAlignmentRight;
  self.gridButton.accessibilityIdentifier =
      kGSCXContinuousScannerScreenshotGridButtonAccessibilityIdentifier;
  self.nextButton.accessibilityIdentifier =
      kGSCXContinuousScannerScreenshotNextButtonAccessibilityIdentifier;
  self.backButton.accessibilityIdentifier =
      kGSCXContinuousScannerScreenshotBackButtonAccessibilityIdentifier;
  self.gridButton.accessibilityLabel = kGSCXGridIconAccessibilityLabel;
  self.backButton.accessibilityLabel = kGSCXBackResultIconAccessibilityLabel;
  self.nextButton.accessibilityLabel = kGSCXNextResultIconAccessibilityLabel;
  [self gscx_initializeAllConstraints];

  self.view.accessibilityElements = @[
    self.carousel.carouselAccessibilityElement, self.gridButton, self.scrollView, self.backButton,
    self.nextButton
  ];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  // Update ring views when the user rotates the device. Subviews' bounds are not necessarily
  // finished by the time viewDidLayoutSubviews is called. Calling layoutIfNeeded on
  // currentScreenshot ensures its bounds are correct so the ring views are positioned correctly.
  // layoutIfNeeded must also be called on screenshotStackView, which is currentScreenshot's
  // superview. Otherwise, currentScreenshot might use stale information to lay itself out.
  [self.screenshotStackView layoutIfNeeded];
  [self.currentScreenshot layoutIfNeeded];
  [self gscx_addRingViewsToScreenshot];
  [self.carousel layoutSubviews];
}

- (void)focusResultAtIndex:(NSUInteger)index animated:(BOOL)animated {
  [self gscx_displayScannerResultAtIndex:index];
  [self.carousel focusResultAtIndex:index animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.currentScreenshot;
}

#pragma mark - UINavigationControllerDelegate

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:
    (UINavigationController *)navigationController {
  return 0;
}

#pragma mark - Private

/**
 * Sets @c translatesAutoresizingMaskIntoConstraints to @c NO to all views to avoid incompatible
 * constraints.
 */
- (void)gscx_disableAutoresizingMasks {
  self.carouselContainerView.translatesAutoresizingMaskIntoConstraints = NO;
  self.screenshotStackView.translatesAutoresizingMaskIntoConstraints = NO;
  self.scanNumberLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.issueCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
  self.currentScreenshot.translatesAutoresizingMaskIntoConstraints = NO;
  self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
  self.gridButton.translatesAutoresizingMaskIntoConstraints = NO;
}

/**
 * Initializes the autolayout constraints for @c scanNumberLabel and @c issueCountLabel.
 */
- (void)gscx_initializeScanLabelConstraints {
  [NSLayoutConstraint gscx_constrainAnchorsOfView:self.issueCountLabel
                            equalToSafeAreaOfView:self.view
                                          leading:NO
                                         trailing:YES
                                              top:YES
                                           bottom:NO
                                         constant:kGSCXContinuousScannerScreenshotPadding
                                        activated:YES];
  [NSLayoutConstraint gscx_constrainAnchorsOfView:self.scanNumberLabel
                            equalToSafeAreaOfView:self.view
                                          leading:YES
                                         trailing:NO
                                              top:YES
                                           bottom:NO
                                         constant:kGSCXContinuousScannerScreenshotPadding
                                        activated:YES];
  [NSLayoutConstraint gscx_constraintsCenteringView:self.issueCountLabel
                                           withView:self.scanNumberLabel
                                       horizontally:NO
                                         vertically:YES
                                          activated:YES];
}

/**
 * Initializes the autolayout constraints for @c carouselContainerView and @c gridButton.
 */
- (void)gscx_initializeCarouselAndGridButtonConstraints {
  [NSLayoutConstraint gscx_constrainAnchorsOfView:self.carouselContainerView
                            equalToSafeAreaOfView:self.view
                                          leading:YES
                                         trailing:NO
                                              top:NO
                                           bottom:NO
                                         constant:kGSCXContinuousScannerScreenshotPadding
                                        activated:YES];
  [NSLayoutConstraint gscx_constrainAnchorsOfView:self.gridButton
                            equalToSafeAreaOfView:self.view
                                          leading:NO
                                         trailing:YES
                                              top:NO
                                           bottom:NO
                                         constant:kGSCXContinuousScannerScreenshotPadding
                                        activated:YES];
  [NSLayoutConstraint gscx_constraintsCenteringView:self.carouselContainerView
                                           withView:self.gridButton
                                       horizontally:NO
                                         vertically:YES
                                          activated:YES];
}

/**
 * Initializes the autolayout constraints for @c screenshotStackView and its subviews:
 * @c currentScreenshot, @c backButton, and @c nextButton.
 */
- (void)gscx_initializeStackViewConstraints {
  NSDictionary<NSString *, id> *views = @{
    @"scrollView" : self.scrollView,
    @"currentScreenshot" : self.currentScreenshot,
    @"backButton" : self.backButton,
    @"nextButton" : self.nextButton,
  };
  NSDictionary<NSString *, NSNumber *> *metrics =
      @{@"controlSize" : @(kGSCXMinimumTouchTargetSize)};
  [NSLayoutConstraint gscx_constrainAnchorsOfView:self.screenshotStackView
                            equalToSafeAreaOfView:self.view
                                          leading:YES
                                         trailing:YES
                                              top:NO
                                           bottom:YES
                                         constant:kGSCXContinuousScannerScreenshotPadding
                                        activated:YES];
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"|[currentScreenshot(==scrollView)]|"
                                            verticalFormat:@"|[currentScreenshot(==scrollView)]"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"[backButton(>=controlSize)]"
                                            verticalFormat:@"[backButton(>=controlSize)]"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"[nextButton(>=controlSize)]"
                                            verticalFormat:@"[nextButton(>=controlSize)]"
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"[backButton(==nextButton)]"
                                            verticalFormat:nil
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
}

/**
 * Initializes the autolayout constraints for all views.
 */
- (void)gscx_initializeAllConstraints {
  NSDictionary<NSString *, id> *views = @{
    @"scanNumberLabel" : self.scanNumberLabel,
    @"issueCountLabel" : self.issueCountLabel,
    @"carousel" : self.carouselContainerView,
    @"gridButton" : self.gridButton,
    @"screenshotStackView" : self.screenshotStackView
  };
  NSDictionary<NSString *, NSNumber *> *metrics = @{
    @"carouselHeight" : @(kGSCXContinuousScannerScreenshotCarouselHeight),
    @"labelHeight" : @(kGSCXContinuousScannerScreenshotMinimumLabelHeight)
  };
  [self gscx_disableAutoresizingMasks];
  // There are a lot of constraints, so it's easier to break them up into separate methods. The
  // methods are organized by row. If a set of views are horizontally aligned, their constraints
  // are set in the same method. Constraints that touch multiple rows are set in this method.
  [self gscx_initializeScanLabelConstraints];
  [self gscx_initializeCarouselAndGridButtonConstraints];
  [self gscx_initializeStackViewConstraints];
  NSString *verticalSpacingConstraints =
      @"[issueCountLabel(>=labelHeight)][carousel(==carouselHeight)][screenshotStackView]";
  [NSLayoutConstraint gscx_constraintsWithHorizontalFormat:@"[carousel][gridButton]"
                                            verticalFormat:verticalSpacingConstraints
                                                   options:0
                                                   metrics:metrics
                                                     views:views
                                                 activated:YES];
  [NSLayoutConstraint
      gscx_constraintsWithHorizontalFormat:nil
                            verticalFormat:@"[scanNumberLabel(>=labelHeight)][carousel]"
                                   options:0
                                   metrics:metrics
                                     views:views
                                 activated:YES];
}

/**
 * Initializes the right bar button items in the navigation bar.
 */
- (void)gscx_setupRightBarButtonItems {
  NSBundle *imageBundle =
      [NSBundle bundleForClass:[GSCXContinuousScannerScreenshotViewController class]];
  UIImage *shareImage = [UIImage imageNamed:kGSCXShareIconImageName
                                   inBundle:imageBundle
              compatibleWithTraitCollection:nil];
  UIImage *listImage = [UIImage imageNamed:kGSCXListIconImageName
                                  inBundle:imageBundle
             compatibleWithTraitCollection:nil];
  UIBarButtonItem *shareButton =
      [[UIBarButtonItem alloc] initWithImage:shareImage
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(gscx_beginSharingIssues)];
  shareButton.accessibilityLabel = kGSCXShareIconAccessibilityLabel;
  shareButton.accessibilityIdentifier = kGSCXShareReportButtonAccessibilityIdentifier;
  UIBarButtonItem *listButton =
      [[UIBarButtonItem alloc] initWithImage:listImage
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(gscx_presentListView)];
  listButton.accessibilityLabel = kGSCXListIconAccessibilityLabel;
  listButton.accessibilityIdentifier =
      kGSCXContinuousScannerScreenshotListBarButtonAccessibilityIdentifier;
  self.navigationItem.rightBarButtonItems = @[ shareButton, listButton ];
}

/**
 * Displays the screenshot for the result at @c index in the scroll view.
 *
 * @param index The index of the scan result to display in the scroll view.
 */
- (void)gscx_displayScannerResultAtIndex:(NSUInteger)index {
  GSCXScannerResult *result = self.scannerResults[index];
  self.currentIndex = index;
  if (self.currentAspectRatioConstraint != nil) {
    [self.currentScreenshot removeConstraint:self.currentAspectRatioConstraint];
  }
  self.currentScreenshot.image = self.scannerResults[index].screenshot;
  CGSize screenshotSize = self.scannerResults[index].screenshot.size;
  CGFloat aspectRatio = screenshotSize.width / screenshotSize.height;
  self.currentAspectRatioConstraint =
      [NSLayoutConstraint gscx_constraintWithView:self.currentScreenshot
                                      aspectRatio:aspectRatio
                                        activated:YES];
  [self.ringViews removeRingViewsFromSuperview];
  self.ringViews = [[GSCXRingViewArranger alloc] initWithResult:result];
  [self.scrollView layoutIfNeeded];
  [self gscx_addRingViewsToScreenshot];
  self.scrollView.zoomScale = 1.0;
  self.scanNumberLabel.text =
      [GSCXContinuousScannerScreenshotViewController gscx_scanNumberTextForScanAtIndex:index];
  self.issueCountLabel.text = [GSCXContinuousScannerScreenshotViewController
      gscx_issueCountTextForIssueCount:[result issueCount]];
}

/**
 * Removes the currently displayed rings and adds ring views to @c currentScreenshot for the
 * currently displayed result.
 */
- (void)gscx_addRingViewsToScreenshot {
  CGRect originalCoordinates = self.scannerResults[self.currentIndex].originalScreenshotFrame;
  [self.ringViews removeRingViewsFromSuperview];
  [self.ringViews addRingViewsToSuperview:self.currentScreenshot
                          fromCoordinates:originalCoordinates];
  [self.ringViews addAccessibilityAttributesToRingViews];
  for (GSCXRingView *ringView in self.ringViews.ringViews) {
    UITapGestureRecognizer *gestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gscx_ringViewTapped:)];
    [ringView addGestureRecognizer:gestureRecognizer];
  }
}

/**
 * Presents the gallery view for the current scan result, focused on the ring view that was tapped.
 *
 * @param sender The object initiating the request.
 */
- (void)gscx_ringViewTapped:(UITapGestureRecognizer *)sender {
  for (NSUInteger i = 0; i < [self.ringViews.ringViews count]; i++) {
    if (sender.view == self.ringViews.ringViews[i]) {
      [self gscx_presentGalleryViewResult:self.scannerResults[self.currentIndex] issueIndex:i];
      return;
    }
  }
}

/**
 * Presents the previous scan result. If the first scan result is the current scan result, presents
 * the last scan result.
 *
 * @param sender The object initiating the request.
 */
- (IBAction)gscx_backResultButtonPressed:(id)sender {
  if (self.currentIndex == 0) {
    self.currentIndex = [self.scannerResults count] - 1;
  } else {
    self.currentIndex--;
  }
  [self.carousel focusResultAtIndex:self.currentIndex animated:YES];
  [self gscx_displayScannerResultAtIndex:self.currentIndex];
}

/**
 * Presents the next scan result. If the last scan result is the current scan result, presents the
 * first scan result.
 *
 * @param sender The object initiating the request.
 */
- (IBAction)gscx_nextResultButtonPressed:(id)sender {
  if (self.currentIndex == [self.scannerResults count] - 1) {
    self.currentIndex = 0;
  } else {
    self.currentIndex++;
  }
  [self.carousel focusResultAtIndex:self.currentIndex animated:YES];
  [self gscx_displayScannerResultAtIndex:self.currentIndex];
}

/**
 * Presents the grid view, allowing easier access to individual scans.
 */
- (IBAction)gscx_gridButtonPressed:(id)sender {
  __weak __typeof__(self) weakSelf = self;
  GSCXContinuousScannerGridViewController *gridController =
      [[GSCXContinuousScannerGridViewController alloc]
          initWithResults:self.scannerResults
           selectionBlock:^(NSUInteger index, GSCXScannerResult *_Nonnull result) {
             __typeof__(self) strongSelf = weakSelf;
             if (strongSelf == nil) {
               return;
             }
             [strongSelf focusResultAtIndex:index animated:NO];
             [strongSelf.navigationController popViewControllerAnimated:YES];
           }];
  [self.navigationController pushViewController:gridController animated:YES];
}

/**
 * Presents the gallery view for the given scan result focusing on the issue at @c issueIndex.
 *
 * @param result The scan result to display.
 * @param issueIndex The index of the issue in @c result to focus on.
 */
- (void)gscx_presentGalleryViewResult:(GSCXScannerResult *)result
                           issueIndex:(NSUInteger)issueIndex {
  GSCXContinuousScannerGalleryViewController *galleryController =
      [[GSCXContinuousScannerGalleryViewController alloc]
          initWithNibName:@"GSCXContinuousScannerGalleryViewController"
                   bundle:[NSBundle
                              bundleForClass:[GSCXContinuousScannerGalleryViewController class]]
                   result:result];
  [galleryController focusIssueAtIndex:(NSInteger)issueIndex animated:NO];
  [self.navigationController pushViewController:galleryController animated:YES];
}

/**
 * Presents the list view, displaying an expandable list of issues and suggestions for a more
 * concise view of the scan results.
 */
- (void)gscx_presentListView {
  NSArray<GSCXScannerIssueTableViewSection *> *byScanSections =
      [GSCXContinuousScannerListTabBarUtils sectionsWithGroupedByScanResults:self.scannerResults];
  NSArray<GSCXScannerIssueTableViewSection *> *byCheckSections =
      [GSCXContinuousScannerListTabBarUtils sectionsWithGroupedByCheckResults:self.scannerResults];
  NSArray<GSCXContinuousScannerListTabBarItem *> *items = @[
    [[GSCXContinuousScannerListTabBarItem alloc]
        initWithSections:byScanSections
                   title:kGSCXContinuousScannerScreenshotListByScanTabBarItemTitle],
    [[GSCXContinuousScannerListTabBarItem alloc]
        initWithSections:byCheckSections
                   title:kGSCXContinuousScannerScreenshotListByCheckTabBarItemTitle]
  ];
  GSCXContinuousScannerListTabBarViewController *tabBarController =
      [[GSCXContinuousScannerListTabBarViewController alloc] initWithItems:items];
  [self.navigationController pushViewController:tabBarController animated:YES];
}

/**
 * Shares all issues found across all scans.
 */
- (void)gscx_beginSharingIssues {
  GSCXReport *report = [[GSCXReport alloc] initWithResults:self.scannerResults];
  [self.sharingDelegate shareReport:report inViewController:self completion:nil];
}

/**
 * Returns text describing the scan at @c scanIndex.
 *
 * @param scanIndex The index of the scan to describe.
 * @return A textual description of the scan at @c scanIndex.
 */
+ (NSString *)gscx_scanNumberTextForScanAtIndex:(NSUInteger)scanIndex {
  // TODO: Localize this and load it from an external resource instead of hardcoding.
  return [NSString stringWithFormat:@"Screen %ld", (long)(scanIndex + 1)];
}

/**
 * Returns text describing @c issueCount.
 *
 * @param issueCount The number of issues to describe.
 * @return A textual description of @c issueCount.
 */
+ (NSString *)gscx_issueCountTextForIssueCount:(NSUInteger)issueCount {
  // TODO: Localize this and load it from an external resource instead of hardcoding.
  if (issueCount == 1) {
    return @"1 Issue";
  } else {
    return [NSString stringWithFormat:@"%lu Issues", (unsigned long)issueCount];
  }
}

@end

NS_ASSUME_NONNULL_END
