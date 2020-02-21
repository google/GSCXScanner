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

#import "GSCXContinuousScannerGalleryViewController.h"

#import "GSCXContinuousScannerGalleryDetailViewData.h"
#import "GSCXRingViewArranger.h"
#import "GSCXScannerScreenshotViewController.h"
#import "UIViewController+GSCXAppearance.h"

NSString *const kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier =
    @"kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier";

/**
 * Maximum zoom scale the screenshot can have. The minimum zoom is the reciprocal of this value.
 */
static const CGFloat kGSCXContinuousScannerGalleryZoomScale = 10.0;

/**
 * The alpha value of the page indicators for noncurrent pages. This is the same as the default
 * alpha.
 */
static const CGFloat kGSCXContinuousScannerPageIndicatorAlpha = 0.2;

@interface GSCXContinuousScannerGalleryViewController () <UIScrollViewDelegate>

/**
 * The displayed scan result.
 */
@property(strong, nonatomic) GSCXScannerResult *result;

/**
 * A copy of the scan result's screenshot, so modifying it does not modify the original screenshot.
 */
@property(strong, nonatomic) UIView *screenshot;

/**
 * Highlights all elements with accessibility issues in the screenshot.
 */
@property(strong, nonatomic) GSCXRingViewArranger *ringViewArranger;

/**
 * Contains the screenshot and allows zooming and panning to focus on issues.
 */
@property(weak, nonatomic) IBOutlet UIScrollView *screenshotScrollView;

/**
 * Contains detailed information on accessibility issues for the currently focused element.
 */
@property(weak, nonatomic) IBOutlet UIScrollView *detailScrollView;

/**
 * Displays how many pages exist in the detail scroll view and which page is currently visible.
 */
@property(weak, nonatomic) IBOutlet UIPageControl *pageControl;

/**
 * Encapsulate detailed information on accessibility issues for individual elements.
 */
@property(strong, nonatomic) NSArray<GSCXContinuousScannerGalleryDetailViewData *> *detailViews;

@end

@implementation GSCXContinuousScannerGalleryViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                         result:(GSCXScannerResult *)result {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self != nil) {
    _result = result;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Can't set self.view.backgroundColor because it would be the opposite color of the navigation
  // bar. Since the navigation bar is partially transparent, this reduces contrast of the navigation
  // bar items to an unacceptable level. At some point we may override the navigation bar style
  // (so it appears light in dark mode and vice versa) to match the rest of the overlay UI, at which
  // point it will be safe to set the view's background.
  self.screenshot = [self.result.screenshot snapshotViewAfterScreenUpdates:YES];
  self.ringViewArranger = [[GSCXRingViewArranger alloc] initWithResult:self.result];
  [self.ringViewArranger addRingViewsToSuperview:self.screenshot
                                 fromCoordinates:self.screenshot.bounds];
  for (NSUInteger i = 0; i < [self.ringViewArranger.ringViews count]; i++) {
    self.ringViewArranger.ringViews[i].accessibilityIdentifier =
        [GSCXScannerScreenshotViewController accessibilityIdentifierForRingViewAtIndex:i];
  }
  self.screenshotScrollView.scrollEnabled = NO;
  self.screenshotScrollView.contentSize = self.result.screenshot.bounds.size;
  [self.screenshotScrollView addSubview:self.screenshot];
  self.screenshotScrollView.minimumZoomScale = 1.0 / kGSCXContinuousScannerGalleryZoomScale;
  self.screenshotScrollView.maximumZoomScale = kGSCXContinuousScannerGalleryZoomScale;
  self.screenshotScrollView.delegate = self;
  self.detailScrollView.pagingEnabled = YES;
  self.detailScrollView.delegate = self;
  self.detailScrollView.showsHorizontalScrollIndicator = NO;
  self.detailScrollView.accessibilityIdentifier =
      kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier;
  self.pageControl.numberOfPages = [self.result.issues count];
  self.pageControl.currentPageIndicatorTintColor = [self gscx_textColorForCurrentAppearance];
  self.pageControl.pageIndicatorTintColor = [[self gscx_textColorForCurrentAppearance]
      colorWithAlphaComponent:kGSCXContinuousScannerPageIndicatorAlpha];
  [self.pageControl addTarget:self
                       action:@selector(gscx_pageControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
  [self gscx_initializeDetailViews];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  self.screenshotScrollView.contentSize = self.screenshot.frame.size;
  self.detailScrollView.contentSize =
      CGSizeMake(self.view.bounds.size.width * [self.result.issues count],
                 self.detailScrollView.frame.size.height);
  for (GSCXContinuousScannerGalleryDetailViewData *detailView in self.detailViews) {
    [detailView didLayoutSubviews];
  }
}

- (void)focusIssueAtIndex:(NSInteger)index animated:(BOOL)animated {
  [self loadViewIfNeeded];
  [self.view layoutIfNeeded];
  [self.pageControl setCurrentPage:index];
  [self gscx_centerScreenshotForIssueAtIndex:index animated:animated];
  [self gscx_displayDetailsForIssueAtIndex:index animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (scrollView != self.detailScrollView) {
    return;
  }
  NSInteger page = (NSInteger)floor(scrollView.contentOffset.x / scrollView.frame.size.width);
  [self.pageControl setCurrentPage:page];
  [self gscx_centerScreenshotForIssueAtIndex:page animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return scrollView == self.screenshotScrollView ? self.screenshot : nil;
}

#pragma mark - Private

/**
 * Initializes the detail views for each element with accessibility issues.
 */
- (void)gscx_initializeDetailViews {
  NSMutableArray<GSCXContinuousScannerGalleryDetailViewData *> *detailViews =
      [NSMutableArray array];
  UIView *previousView = self.detailScrollView;
  for (GSCXScannerIssue *issue in self.result.issues) {
    GSCXContinuousScannerGalleryDetailViewData *detailView =
        [[GSCXContinuousScannerGalleryDetailViewData alloc] init];
    detailView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
    detailView.textColor = [self gscx_textColorForCurrentAppearance];
    for (NSUInteger i = 0; i < issue.underlyingIssueCount; i++) {
      [detailView addIssueWithTitle:issue.gtxCheckNames[i] contents:issue.gtxCheckDescriptions[i]];
    }
    [self.detailScrollView addSubview:detailView.containerView];
    [detailViews addObject:detailView];
    [self gscx_constrainDetailView:detailView toPreviousView:previousView];
    previousView = detailView.containerView;
  }
  self.detailViews = detailViews;
}

/**
 * Adds constraints to the detail views.
 */
- (void)gscx_constrainDetailView:(GSCXContinuousScannerGalleryDetailViewData *)detailView
                  toPreviousView:(UIView *)previousView {
  id safeAreaView = self.view;
  if (@available(iOS 11.0, *)) {
    safeAreaView = self.view.safeAreaLayoutGuide;
  }
  NSDictionary<NSString *, id> *views = @{
    @"previousView" : previousView,
    @"stackView" : detailView.stackView,
    @"nextView" : detailView.containerView,
    @"superview" : self.detailScrollView,
    @"view" : safeAreaView
  };
  [NSLayoutConstraint
      activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"[previousView][nextView(==view)]"
                                                  options:0
                                                  metrics:nil
                                                    views:views]];
  [NSLayoutConstraint
      activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[stackView(==view)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];
  [NSLayoutConstraint
      activateConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|[nextView(==superview)]"
                                                  options:0
                                                  metrics:nil
                                                    views:views]];
}

/**
 * Invoked when @c pageControl changes value. Updates the detail view and screenshot to display the
 * issue for the new page.
 *
 * @param pageControl The @c UIPageControl instance whose value changed.
 */
- (void)gscx_pageControlValueChanged:(UIPageControl *)pageControl {
  [self gscx_centerScreenshotForIssueAtIndex:pageControl.currentPage animated:YES];
  [self gscx_displayDetailsForIssueAtIndex:pageControl.currentPage animated:YES];
}

/**
 * Updates the screenshot scroll view to center the element corresponding to the accessibility issue
 * at @c index.
 *
 * @param index The index of the accessibility issue whose corresponding UI element should be
 * centered.
 * @param animated @c YES if the transition should be animated, @c NO if it should occur
 * immediately. If @c UIAccessibilityIsReduceMotionEnabled is @c YES, the animation does not occur.
 */
- (void)gscx_centerScreenshotForIssueAtIndex:(NSUInteger)index animated:(BOOL)animated {
  animated = animated && !UIAccessibilityIsReduceMotionEnabled();
  [self.screenshotScrollView zoomToRect:self.ringViewArranger.ringViews[index].frame
                               animated:animated];
}

/**
 * Updates the details scroll view to display the details for the accessibility issue at @c index.
 *
 * @param index The index of the accessibility issue whose details should be displayed.
 * @param animated @c YES if the transition should be animated, @c NO if it should occur
 * immediately. If @c UIAccessibilityIsReduceMotionEnabled is @c YES, the animation does not occur.
 */
- (void)gscx_displayDetailsForIssueAtIndex:(NSUInteger)index animated:(BOOL)animated {
  animated = animated && !UIAccessibilityIsReduceMotionEnabled();
  [self.detailScrollView scrollRectToVisible:self.detailViews[index].containerView.frame
                                    animated:animated];
}

@end
