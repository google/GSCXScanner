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
#import "GSCXReport.h"
#import "GSCXRingView.h"
#import "GSCXRingViewArranger.h"
#import "GSCXScannerResultTableViewController.h"

NSString *const kGSCXShareReportButtonAccessibilityIdentifier =
    @"kGSCXShareReportButtonAccessibilityIdentifier";

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

/**
 * Returns the accessibility label for the ring view at the given index by determining the number
 * of issues associated with the corresponding UI element and the UI element's accessibility label.
 *
 * @param index The index of the ring view. Must be less than @c self.scanResult.issues.count.
 * @return The accessibility label of the ring view at the given index.
 */
- (NSString *)gscx_accessibilityLabelForRingAtIndex:(NSInteger)index;

@end

@implementation GSCXScannerScreenshotViewController {
  GSCXReport *_report;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                     scanResult:(GSCXScannerResult *)scanResult
                sharingDelegate:(id<GSCXSharingDelegate>)sharingDelegate {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _scanResult = scanResult;
    _sharingDelegate = sharingDelegate;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = [NSString stringWithFormat:@"%ld Issues", (unsigned long)self.scanResult.issueCount];
  self.screenshot = [self.scanResult.screenshot snapshotViewAfterScreenUpdates:YES];
  [self gscx_addScreenshotToScreen:self.screenshot];
  UIBarButtonItem *shareButton =
      [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(gscx_beginSharingIssues)];
  shareButton.accessibilityIdentifier = kGSCXShareReportButtonAccessibilityIdentifier;
  self.navigationItem.rightBarButtonItem = shareButton;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  if (@available(iOS 12.0, *)) {
    self.blackBackgroundView.backgroundColor =
        self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? [UIColor whiteColor]
                                                                            : [UIColor blackColor];
  }
}

- (void)gscx_beginSharingIssues {
  _report = [[GSCXReport alloc] initWithResults:@[ self.scanResult ]];
  [_sharingDelegate shareReport:_report inViewController:self];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  [self gscx_addRingsToScreenshot:self.screenshot];
}

+ (NSString *)accessibilityIdentifierForRingViewAtIndex:(NSInteger)index {
  return [NSString stringWithFormat:@"GSCXScannerScreenshotViewController_Ring_%ld", (long)index];
}

#pragma mark - UINavigationControllerDelegate

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:
    (UINavigationController *)navigationController {
  return 0;
}

#pragma mark - Private

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
  CGFloat aspectRatio = screenshot.frame.size.width / screenshot.frame.size.height;
  [self.view addSubview:screenshot];
  NSArray<NSLayoutConstraint *> *constraints = @[
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:screenshot
                                 attribute:NSLayoutAttributeHeight
                                multiplier:aspectRatio
                                  constant:0.0],
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.topLayoutGuide
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0],
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.bottomLayoutGuide
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0.0],
    [NSLayoutConstraint constraintWithItem:screenshot
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0.0],
  ];
  [NSLayoutConstraint activateConstraints:constraints];
  [self gscx_addConstraintsToScreenshotSubviews:screenshot];

  [NSLayoutConstraint constraintWithItem:self.blackBackgroundView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                                  toItem:screenshot
                               attribute:NSLayoutAttributeTop
                              multiplier:1.0
                                constant:0.0]
      .active = YES;
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
  if (self.ringViewArranger) {
    return;
  }
  self.ringViewArranger = [[GSCXRingViewArranger alloc] initWithResult:self.scanResult];
  [self.ringViewArranger addRingViewsToSuperview:screenshot
                                 fromCoordinates:[[UIScreen mainScreen] bounds]];
  NSInteger index = 0;
  for (GSCXRingView *ringView in self.ringViewArranger.ringViews) {
    ringView.accessibilityIdentifier =
        [GSCXScannerScreenshotViewController accessibilityIdentifierForRingViewAtIndex:index];
    ringView.accessibilityLabel = [self gscx_accessibilityLabelForRingAtIndex:index];
    index++;
  }
}

- (GSCXScannerResult *)gscx_resultWithIssuesAtPoint:(CGPoint)point {
  return [self.ringViewArranger resultWithIssuesAtPoint:point];
}

- (NSString *)gscx_accessibilityLabelForRingAtIndex:(NSInteger)index {
  NSParameterAssert((NSUInteger)index < self.scanResult.issues.count);
  NSUInteger count = self.scanResult.issues[(NSUInteger)index].gtxCheckNames.count;
  NSString *pluralModifier = (count == 1) ? @"" : @"s";
  NSString *accessibilityLabel = self.scanResult.issues[(NSUInteger)index].accessibilityLabel;
  if (accessibilityLabel == nil) {
    return [NSString stringWithFormat:@"%ld issue%@ for element without accessibility label.",
                                      (unsigned long)count, pluralModifier];
  } else {
    return [NSString stringWithFormat:@"%ld issue%@ for element with accessibility label %@",
                                      (unsigned long)count, pluralModifier, accessibilityLabel];
  }
}

@end
