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
#import "NSLayoutConstraint+GSCXUtilities.h"
#import "UIView+NSLayoutConstraint.h"
#import "UIViewController+GSCXAppearance.h"

NSString *const kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier =
    @"kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier";

const CGFloat kGSCXContinuousScannerGalleryZoomScale = 10.0;

/**
 * The alpha value of the page indicators for noncurrent pages. This is the same as the default
 * alpha.
 */
static const CGFloat kGSCXContinuousScannerPageIndicatorAlpha = 0.2;

@interface GSCXContinuousScannerGalleryViewController () <UIScrollViewDelegate>

/**
 * The displayed scan result.
 */
@property(strong, nonatomic) GTXHierarchyResultCollection *result;

/**
 * A copy of the scan result's screenshot, so modifying it does not modify the original screenshot.
 */
@property(strong, nonatomic) UIImageView *screenshot;

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

/**
 * The index to focus when the view appears on screen. In some cases, the size of the view is
 * different when initialized and when displayed on screen (such as on iPad when the modal is not
 * full screen). In this case, the screenshot and detail scroll views are not centered properly.
 * Focusing it in @c viewWillAppear solves this, but this should only occur if the view controller
 * is not currently visible. Defaults to @c nil.
 */
@property(strong, nonatomic, nullable) NSNumber *indexToFocusOnAppear;

/**
 * @c YES if the view controller is visible, @c NO otherwise. This ensures focusing on specific
 * views can be deferred until the view controller is visible, if needed. The view controller is
 * considered visible from when @c viewWillAppear is called until @c viewDidDisappear is called.
 * Default is @c NO because the view controller is created before it appears on screen.
 */
@property(assign, nonatomic, getter=isViewControllerVisible) BOOL viewControllerVisible;

@end

@implementation GSCXContinuousScannerGalleryViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                         result:(GTXHierarchyResultCollection *)result {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self != nil) {
    _result = result;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  [self gscx_initializeScreenshot];
  [self gscx_initializeScreenshotScrollView];
  [self gscx_initializeDetailScrollView];
  [self gscx_initializeScrollViewConstraints];
  [self gscx_initializePageControl];
  [self gscx_initializeDetailViews];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  if (self.indexToFocusOnAppear != nil) {
    [self focusIssueAtIndex:[self.indexToFocusOnAppear integerValue] animated:NO];
    self.indexToFocusOnAppear = nil;
  }
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGFloat viewWidth = self.view.bounds.size.width;
  if (@available(iOS 11.0, *)) {
    viewWidth = self.view.safeAreaLayoutGuide.layoutFrame.size.width;
  }
  self.detailScrollView.contentSize = CGSizeMake(viewWidth * self.result.elementResults.count,
                                                 self.detailScrollView.frame.size.height);
  for (GSCXContinuousScannerGalleryDetailViewData *detailView in self.detailViews) {
    [detailView didLayoutSubviews];
  }
  [self gscx_centerScreenshotForIssueAtIndex:self.pageControl.currentPage animated:NO];
  [self gscx_displayDetailsForIssueAtIndex:self.pageControl.currentPage animated:NO];
  // Content insets let the scroll view zoom and center ring views correctly, even if the ring views
  // are on the edge of the screenshot or need to be zoomed out to see.
  CGSize contentSize = self.screenshotScrollView.contentSize;
  self.screenshotScrollView.contentInset =
      UIEdgeInsetsMake(contentSize.height / 2.0, contentSize.width / 2.0, contentSize.height / 2.0,
                       contentSize.width / 2.0);
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.viewControllerVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  self.viewControllerVisible = NO;
}

- (void)focusIssueAtIndex:(NSInteger)index animated:(BOOL)animated {
  if (!self.isViewControllerVisible) {
    self.indexToFocusOnAppear = @(index);
    return;
  }
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
 * Initializes @c screenshot based on @c result. Sets constraints and adds ring views to highlight
 * accessibility issues.
 */
- (void)gscx_initializeScreenshot {
  self.screenshot = [[UIImageView alloc] initWithImage:self.result.screenshot];
  CGRect originalCoordinates =
      CGRectMake(0, 0, self.result.screenshot.size.width, self.result.screenshot.size.height);
  self.ringViewArranger = [[GSCXRingViewArranger alloc] initWithResult:self.result];
  [self.ringViewArranger addRingViewsToSuperview:self.screenshot
                                 fromCoordinates:originalCoordinates];
  [self.ringViewArranger addAccessibilityAttributesToRingViews];
  self.screenshot.translatesAutoresizingMaskIntoConstraints = NO;
  [self.screenshotScrollView addSubview:self.screenshot];
  CGFloat aspectRatio = self.result.screenshot.size.width / self.result.screenshot.size.height;
  [NSLayoutConstraint gscx_constraintWithView:self.screenshot
                                  aspectRatio:aspectRatio
                                    activated:YES];
  [NSLayoutConstraint gscx_constraintsToFillSuperviewWithView:self.screenshot activated:YES];
}

/**
 * Initializes @c screenshotScrollView. Configures zooming behavior.
 */
- (void)gscx_initializeScreenshotScrollView {
  self.screenshotScrollView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  self.screenshotScrollView.scrollEnabled = NO;
  self.screenshotScrollView.minimumZoomScale = 1.0 / kGSCXContinuousScannerGalleryZoomScale;
  self.screenshotScrollView.maximumZoomScale = kGSCXContinuousScannerGalleryZoomScale;
  self.screenshotScrollView.delegate = self;
}

/**
 * Initializes @c detailScrollView based on @c result. Configures paging behavior.
 */
- (void)gscx_initializeDetailScrollView {
  self.detailScrollView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
  self.detailScrollView.pagingEnabled = YES;
  self.detailScrollView.delegate = self;
  self.detailScrollView.showsHorizontalScrollIndicator = NO;
  self.detailScrollView.accessibilityIdentifier =
      kGSCXContinuousScannerGalleryDetailViewAccessibilityIdentifier;
  if (@available(iOS 11.0, *)) {
    // Safe areas cannot be used in the Storyboard because it fails compilation pre-iOS 11. However,
    // the scroll view still adjusts content insets as if they exist, which incorrectly positions
    // subviews. Never adjusting the content inset fixes this.
    self.detailScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
  }
}

/**
 * Adds constraints to @c detailScrollView and @c screenshotScrollView.
 */
- (void)gscx_initializeScrollViewConstraints {
  self.screenshotScrollView.translatesAutoresizingMaskIntoConstraints = NO;
  self.detailScrollView.translatesAutoresizingMaskIntoConstraints = NO;
  NSArray<UIScrollView *> *horizontallyConstrainedScrollViews =
      @[ self.screenshotScrollView, self.detailScrollView ];
  // The visual constraint format does not support the safe area, so all constraints that may
  // involve it must use the explicit API.
  //
  // Both scroll views are constrained to both horizontal edges. They are constrained to different
  // vertical edges.
  for (UIScrollView *scrollView in horizontallyConstrainedScrollViews) {
    [NSLayoutConstraint gscx_constrainAnchorsOfView:scrollView
                              equalToSafeAreaOfView:self.view
                                            leading:YES
                                           trailing:YES
                                                top:NO
                                             bottom:NO
                                           constant:0.0
                                          activated:YES];
  }
  [NSLayoutConstraint gscx_constrainAnchorsOfView:self.screenshotScrollView
                            equalToSafeAreaOfView:self.view
                                          leading:NO
                                         trailing:NO
                                              top:YES
                                           bottom:NO
                                         constant:0.0
                                        activated:YES];
  [NSLayoutConstraint gscx_constrainAnchorsOfView:self.detailScrollView
                            equalToSafeAreaOfView:self.view
                                          leading:NO
                                         trailing:NO
                                              top:NO
                                           bottom:YES
                                         constant:0.0
                                        activated:YES];
  NSDictionary<NSString *, id> *views = @{
    @"screenshotScrollView" : self.screenshotScrollView,
    @"detailScrollView" : self.detailScrollView,
  };
  [NSLayoutConstraint
      gscx_constraintsWithHorizontalFormat:nil
                            verticalFormat:
                                @"[screenshotScrollView(==detailScrollView)][detailScrollView]"
                                   options:0
                                   metrics:nil
                                     views:views
                                 activated:YES];
  [NSLayoutConstraint gscx_constraintsCenteringView:self.screenshotScrollView
                                           withView:self.view.gscx_safeAreaLayoutGuide
                                       horizontally:YES
                                         vertically:NO
                                          activated:YES];
}

/**
 * Initializes @c pageControl based on @c result.
 */
- (void)gscx_initializePageControl {
  self.pageControl.numberOfPages = self.result.elementResults.count;
  self.pageControl.currentPageIndicatorTintColor = [self gscx_textColorForCurrentAppearance];
  self.pageControl.pageIndicatorTintColor = [[self gscx_textColorForCurrentAppearance]
      colorWithAlphaComponent:kGSCXContinuousScannerPageIndicatorAlpha];
  [self.pageControl addTarget:self
                       action:@selector(gscx_pageControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
}

/**
 * Initializes the detail views for each element with accessibility issues.
 */
- (void)gscx_initializeDetailViews {
  NSMutableArray<GSCXContinuousScannerGalleryDetailViewData *> *detailViews =
      [NSMutableArray array];
  UIView *previousView = self.detailScrollView;
  for (GTXElementResultCollection *elementResult in self.result.elementResults) {
    GSCXContinuousScannerGalleryDetailViewData *detailView =
        [[GSCXContinuousScannerGalleryDetailViewData alloc] init];
    detailView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
    detailView.textColor = [self gscx_textColorForCurrentAppearance];
    for (GTXCheckResult *checkResult in elementResult.checkResults) {
      [detailView addCheckWithTitle:checkResult.checkName contents:checkResult.errorDescription];
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
