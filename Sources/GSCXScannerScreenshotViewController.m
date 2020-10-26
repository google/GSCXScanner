//
// Copyright 2018 Google Inc.
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

#import "GSCXScannerScreenshotViewController.h"

#import "GSCXContinuousScannerGalleryViewController.h"
#import "GSCXDefaultSharingDelegate.h"
#import "GSCXImageNames.h"
#import "GSCXReport.h"
#import "GSCXRingView.h"
#import "GSCXRingViewArranger.h"
#import "GSCXScannerResultTableViewController.h"
#import "NSLayoutConstraint+GSCXUtilities.h"
#import "UIViewController+GSCXAppearance.h"

NSString *const kGSCXShareReportButtonAccessibilityIdentifier =
    @"kGSCXShareReportButtonAccessibilityIdentifier";

/**
 * The padding between the screenshot and the edge of the screen.
 */
static const CGFloat kGSCXScannerScreenshotPadding = 0.0;

@interface GSCXScannerScreenshotViewController ()

/**
 * A view that adds black bars to the side of the screenshot. The controller's view cannot be made
 * black because that causes the navigation bar to look different than expected.
 */
@property(weak, nonatomic) IBOutlet UIView *blackBackgroundView;

/**
 * A copy of the screenshot so the original screenshot is not modified.
 */
@property(strong, nonatomic) UIView *screenshot;

/**
 * Manages the rings used to highlight UI elements with accessibility issues. @c nil until the rings
 * are added to the screen.
 */
@property(strong, nonatomic, nullable) GSCXRingViewArranger *ringViewArranger;

/**
 * Shares a report of the scan result.
 */
@property(strong, nonatomic) id<GSCXSharingDelegate> sharingDelegate;

/**
 * Adds constraints to the given screenshot and adds it to the view hierarchy.
 *
 * @param screenshot The screenshot to display.
 */
- (void)gscx_addScreenshotToScreen:(UIView *)screenshot;

/**
 * Adds constraints to the subviews of a screenshot (themselves screenshots of other views).
 *
 * @param screenshot The screenshot containing other screenshots as subviews.
 */
- (void)gscx_addConstraintsToScreenshotSubviews:(UIView *)screenshot;

/**
 * Multiplies all components of @c rect by @c factor.
 *
 * @param rect The CGRect instance to be scaled.
 * @param factor The factor to multiply each component by.
 * @return A CGRect instance with all components scaled.
 */
- (CGRect)gscx_scaleRect:(CGRect)rect byFactor:(CGFloat)factor;

/**
 * Adds ring views to highlight UI elements with accessibility issues in the screenshot.
 *
 * @param screenshot The screenshot of the view hierarchy that was scanned.
 */
- (void)gscx_addRingsToScreenshot:(UIView *)screenshot;

/**
 * Returns a GSCXScannerResult instance with only the issues at the given point, after converting
 * it to the correct coordinate system. @c point should be in @c scanResult.screenshot's
 * coordinates.
 *
 * @param point The point UI elements must contain for their issues to be included in the result.
 * @return A GSCXScannerResult object containing only issues whose frames contain the given point
 * when converted to screen coordinates.
 */
- (GSCXScannerResult *)gscx_resultWithIssuesAtPoint:(CGPoint)point;

@end

@implementation GSCXScannerScreenshotViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                     scanResult:(GSCXScannerResult *)scanResult
                sharingDelegate:(id<GSCXSharingDelegate>)sharingDelegate {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _scanResult = scanResult;
    _ringViewArranger = [[GSCXRingViewArranger alloc] initWithResult:scanResult];
    _sharingDelegate = sharingDelegate;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.screenshot = [[UIImageView alloc] initWithImage:self.scanResult.screenshot];
  [self gscx_addScreenshotToScreen:self.screenshot];
  NSBundle *shareImageBundle =
      [NSBundle bundleForClass:[GSCXScannerScreenshotViewController class]];
  UIImage *shareImage = [UIImage imageNamed:kGSCXShareIconImageName
                                   inBundle:shareImageBundle
                          withConfiguration:nil];
  UIBarButtonItem *shareButton =
      [[UIBarButtonItem alloc] initWithImage:shareImage
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(gscx_beginSharingIssues)];
  shareButton.accessibilityLabel = kGSCXShareIconAccessibilityLabel;
  shareButton.accessibilityIdentifier = kGSCXShareReportButtonAccessibilityIdentifier;
  self.navigationItem.rightBarButtonItem = shareButton;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  self.blackBackgroundView.backgroundColor = [self gscx_backgroundColorForCurrentAppearance];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self gscx_addRingsToScreenshot:self.screenshot];
}

#pragma mark - Private

- (void)gscx_beginSharingIssues {
  GSCXReport *report = [[GSCXReport alloc] initWithResults:@[ self.scanResult ]];
  [self.sharingDelegate shareReport:report inViewController:self completion:nil];
}

- (IBAction)gscx_tapRecognized:(id)sender {
  CGPoint location = [sender locationInView:self.screenshot];
  for (NSUInteger index = 0; index < [self.ringViewArranger.ringViews count]; index++) {
    if (CGRectContainsPoint(self.ringViewArranger.ringViews[index].frame, location)) {
      GSCXContinuousScannerGalleryViewController *galleryController =
          [[GSCXContinuousScannerGalleryViewController alloc]
              initWithNibName:@"GSCXContinuousScannerGalleryViewController"
                       bundle:[NSBundle
                                  bundleForClass:[GSCXContinuousScannerGalleryViewController class]]
                       result:self.scanResult];
      [galleryController focusIssueAtIndex:index animated:NO];
      [self.navigationController pushViewController:galleryController animated:YES];
      return;
    }
  }
}

- (void)gscx_addScreenshotToScreen:(UIView *)screenshot {
  screenshot.translatesAutoresizingMaskIntoConstraints = NO;
  screenshot.userInteractionEnabled = NO;
  [self.view addSubview:screenshot];
  NSDictionary<NSString *, NSNumber *> *metrics = @{@"padding" : @(kGSCXScannerScreenshotPadding)};
  NSDictionary<NSString *, id> *views = @{@"screenshot" : self.screenshot};
  [NSLayoutConstraint gscx_constraintToCurrentAspectRatioWithView:screenshot activated:YES];
  [NSLayoutConstraint
      gscx_constraintsWithHorizontalFormat:@"|-(>=padding)-[screenshot]-(>=padding)-|"
                            verticalFormat:@"|-(>=padding)-[screenshot]-(>=padding)-|"
                                   options:0
                                   metrics:metrics
                                     views:views
                                 activated:YES];
  [NSLayoutConstraint gscx_constraintsCenteringView:screenshot
                                           withView:screenshot.superview
                                       horizontally:YES
                                         vertically:YES
                                          activated:YES];
  [self gscx_addConstraintsToScreenshotSubviews:screenshot];
  [NSLayoutConstraint gscx_constraintsToFillSuperviewWithView:self.blackBackgroundView
                                                    activated:YES];
}

- (void)gscx_addConstraintsToScreenshotSubviews:(UIView *)screenshot {
  for (UIView *subview in screenshot.subviews) {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint
        activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{@"view" : subview}]];
    [NSLayoutConstraint
        activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{@"view" : subview}]];
  }
}

- (CGRect)gscx_scaleRect:(CGRect)rect byFactor:(CGFloat)factor {
  return CGRectMake(rect.origin.x * factor, rect.origin.y * factor, rect.size.width * factor,
                    rect.size.height * factor);
}

- (void)gscx_addRingsToScreenshot:(UIView *)screenshot {
  [self.ringViewArranger removeRingViewsFromSuperview];
  [self.ringViewArranger addRingViewsToSuperview:screenshot
                                 fromCoordinates:self.scanResult.originalScreenshotFrame];
  [self.ringViewArranger addAccessibilityAttributesToRingViews];
}

- (GSCXScannerResult *)gscx_resultWithIssuesAtPoint:(CGPoint)point {
  return [self.ringViewArranger resultWithIssuesAtPoint:point];
}

@end
